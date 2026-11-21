from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from pwdlib import PasswordHash
from pwdlib.exceptions import UnknownHashError

from database import obtener_sesion
from models import Usuario, Blog, Comentario
from seguridad import (
    crear_token_acceso,
    obtener_usuario_actual,
    obtener_usuario_opcional,
    requerir_admin,
)
from tienda import router as tienda_router
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    LoginRespuesta,
    BlogRespuesta,
    BlogCrear,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

password_hash = PasswordHash.recommended()


def _blog_con_autor(publicacion: Blog, autor: str) -> dict:
    return {
        "id_blog": publicacion.id_blog,
        "titulo": publicacion.titulo,
        "descripcion": publicacion.descripcion,
        "img": publicacion.img,
        "tags": publicacion.tags,
        "usr_id": publicacion.usr_id,
        "autor": autor,
    }


def _comentario_con_autor(comentario: Comentario, autor: str) -> dict:
    return {
        "id_com": comentario.id_com,
        "comentario": comentario.comentario,
        "fecha": comentario.fecha,
        "estatus": comentario.estatus,
        "usr_id": comentario.usr_id,
        "blog_id": comentario.blog_id,
        "autor": autor,
    }


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title="API de aplicación móvil · Respawn",
    lifespan=lifespan,
)

# Permitir la comunicación con Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:60450",
        "http://127.0.0.1:60450",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(tienda_router)


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


# AUTENTICACIÓN

@app.post("/login", response_model=LoginRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    valido = False
    if usuario is not None:
        try:
            valido = password_hash.verify(datos.password, usuario.pass_hash)
        except UnknownHashError:
            valido = False

    # Se utiliza el mismo mensaje para no revelar si el correo está registrado.
    if not valido or usuario is None:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    token = crear_token_acceso(usuario)
    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "dir_usr": usuario.dir_usr,
        "tip_usu": usuario.tip_usu,
        "access_token": token,
        "token_type": "bearer",
    }


@app.get("/me", response_model=UsuarioRespuesta)
def perfil_actual(actual: Usuario = Depends(obtener_usuario_actual)):
    return actual


# USUARIOS

@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    actual: Usuario | None = Depends(obtener_usuario_opcional),
    db: Session = Depends(obtener_sesion),
):
    es_admin = actual is not None and actual.tip_usu == 1

    if not es_admin and datos.tip_usu != 2:
        raise HTTPException(
            status_code=403,
            detail="Solo un administrador puede asignar un rol distinto a General",
        )

    rol_asignado = datos.tip_usu if es_admin else 2

    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr.strip() if datos.dir_usr and datos.dir_usr.strip() else None,
        tip_usu=rol_asignado,
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.put(
    "/usuarios/{usuario_id}",
    response_model=UsuarioRespuesta,
)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    if actual.tip_usu != 1 and actual.id_usr != usuario_id:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para actualizar este usuario",
        )

    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    if actual.tip_usu != 1 and datos.tip_usu is not None and datos.tip_usu != usuario.tip_usu:
        raise HTTPException(
            status_code=403,
            detail="Solo un administrador puede cambiar el tipo de usuario",
        )

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr.strip() if datos.dir_usr and datos.dir_usr.strip() else None
    if actual.tip_usu == 1 and datos.tip_usu is not None:
        usuario.tip_usu = datos.tip_usu

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.delete("/usuarios/{usuario_id}")
def eliminar_usuario(
    usuario_id: int,
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    db.delete(usuario)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se puede eliminar un usuario con registros asociados",
        )

    return {"mensaje": "Usuario eliminado correctamente"}


# BLOG

@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(
    solo_mios: bool = Query(default=False),
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    consulta = (
        select(Blog, Usuario.nom_usr)
        .join(Usuario, Usuario.id_usr == Blog.usr_id)
    )
    if solo_mios:
        consulta = consulta.where(Blog.usr_id == actual.id_usr)

    filas = db.execute(consulta.order_by(Blog.id_blog.desc())).all()
    return [_blog_con_autor(pub, autor) for pub, autor in filas]


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
def crear_blog(
    datos: BlogCrear,
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    publicacion = Blog(
        titulo=datos.titulo.strip(),
        descripcion=datos.descripcion.strip(),
        img=datos.img.strip() if datos.img and datos.img.strip() else None,
        tags=datos.tags.strip() if datos.tags and datos.tags.strip() else None,
        usr_id=actual.id_usr,
    )
    db.add(publicacion)
    db.commit()
    db.refresh(publicacion)
    return _blog_con_autor(publicacion, actual.nom_usr)


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(
    blog_id: int,
    _: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    fila = db.execute(
        select(Blog, Usuario.nom_usr)
        .join(Usuario, Usuario.id_usr == Blog.usr_id)
        .where(Blog.id_blog == blog_id)
    ).first()

    if fila is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    publicacion, autor = fila
    return _blog_con_autor(publicacion, autor)


# COMENTARIOS

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(
    blog_id: int | None = Query(default=None),
    _: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    consulta = (
        select(Comentario, Usuario.nom_usr)
        .join(Usuario, Usuario.id_usr == Comentario.usr_id)
    )
    if blog_id is not None:
        consulta = consulta.where(Comentario.blog_id == blog_id)

    filas = db.execute(consulta.order_by(Comentario.id_com.desc())).all()
    return [_comentario_con_autor(com, autor) for com, autor in filas]


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=actual.id_usr,
        blog_id=datos.blog_id,
        estatus=1,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return _comentario_con_autor(nuevo, actual.nom_usr)
