"""Rutas (endpoints) del módulo de venta y comercio electrónico.

El pago es SIMULADO: se valida la tarjeta (formato, algoritmo de Luhn,
fecha de vencimiento y CVV) pero no se hace ningún cobro real.
De la tarjeta solo se guardan los últimos 4 dígitos.

Tarjetas de prueba:
    4242 4242 4242 4242  -> pago aprobado
    4000 0000 0000 0002  -> pago rechazado por el banco
"""

from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Usuario
from models_tienda import DetallePedido, Pedido, Producto
from schemas_tienda import (
    DatosPago,
    PedidoCrear,
    PedidoRespuesta,
    ProductoActualizar,
    ProductoCrear,
    ProductoRespuesta,
)
from seguridad import obtener_usuario_actual, requerir_admin

router = APIRouter(tags=["Tienda"])

TARJETA_RECHAZADA = "4000000000000002"


# ---------------------------------------------------------
# Validación del pago simulado
# ---------------------------------------------------------

def _pasa_luhn(numero: str) -> bool:
    """Algoritmo de Luhn: detecta números de tarjeta mal escritos."""
    total = 0
    for posicion, caracter in enumerate(reversed(numero)):
        digito = int(caracter)
        if posicion % 2 == 1:
            digito *= 2
            if digito > 9:
                digito -= 9
        total += digito
    return total % 10 == 0


def validar_pago(pago: DatosPago) -> str:
    """Valida la tarjeta y devuelve sus últimos 4 dígitos."""
    numero = pago.numero.replace(" ", "").replace("-", "")

    if not numero.isdigit() or not 13 <= len(numero) <= 19 or not _pasa_luhn(numero):
        raise HTTPException(status_code=400, detail="Número de tarjeta inválido")

    if not pago.cvv.isdigit() or len(pago.cvv) not in (3, 4):
        raise HTTPException(status_code=400, detail="CVV inválido")

    try:
        mes_texto, anio_texto = pago.vencimiento.strip().split("/")
        mes = int(mes_texto)
        anio = 2000 + int(anio_texto[-2:])
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="La fecha de vencimiento debe tener el formato MM/AA",
        )

    if not 1 <= mes <= 12:
        raise HTTPException(status_code=400, detail="Mes de vencimiento inválido")

    hoy = date.today()
    if (anio, mes) < (hoy.year, hoy.month):
        raise HTTPException(status_code=400, detail="La tarjeta está vencida")

    if numero == TARJETA_RECHAZADA:
        raise HTTPException(
            status_code=402,
            detail="Pago rechazado por el banco. Intenta con otra tarjeta.",
        )

    return numero[-4:]


def _armar_respuesta(
    db: Session,
    pedido: Pedido,
    cliente: str | None = None,
    correo: str | None = None,
) -> dict:
    """Junta el pedido con sus productos para devolverlo a la app."""
    filas = db.execute(
        select(DetallePedido, Producto.nombre)
        .join(Producto, Producto.id_prod == DetallePedido.prod_id)
        .where(DetallePedido.ped_id == pedido.id_ped)
        .order_by(DetallePedido.id_det)
    ).all()

    detalles = [
        {
            "prod_id": detalle.prod_id,
            "nombre": nombre,
            "cantidad": detalle.cantidad,
            "precio_unit": detalle.precio_unit,
            "subtotal": detalle.precio_unit * detalle.cantidad,
        }
        for detalle, nombre in filas
    ]

    return {
        "id_ped": pedido.id_ped,
        "usr_id": pedido.usr_id,
        "cliente": cliente,
        "correo": correo,
        "fecha": pedido.fecha,
        "total": pedido.total,
        "estatus": pedido.estatus,
        "ultimos4": pedido.ultimos4,
        "detalles": detalles,
    }


# ---------------------------------------------------------
# Productos
# ---------------------------------------------------------

@router.get("/productos", response_model=list[ProductoRespuesta])
def listar_productos(
    q: str | None = None,
    solo_disponibles: bool = False,
    _: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    consulta = select(Producto)
    if q and q.strip():
        patron = f"%{q.strip()}%"
        consulta = consulta.where(
            or_(
                Producto.nombre.ilike(patron),
                Producto.descripcion.ilike(patron),
            )
        )
    if solo_disponibles:
        consulta = consulta.where(Producto.stock > 0)
    return db.scalars(consulta.order_by(Producto.id_prod)).all()


@router.post("/productos", response_model=ProductoRespuesta, status_code=201)
def crear_producto(
    datos: ProductoCrear,
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    producto = Producto(
        nombre=datos.nombre.strip(),
        descripcion=datos.descripcion.strip() if datos.descripcion else None,
        precio=Decimal(str(datos.precio)),
        stock=datos.stock,
        img=datos.img.strip() if datos.img and datos.img.strip() else None,
    )
    db.add(producto)
    db.commit()
    db.refresh(producto)
    return producto


@router.put("/productos/{prod_id}", response_model=ProductoRespuesta)
def actualizar_producto(
    prod_id: int,
    datos: ProductoActualizar,
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    producto = db.get(Producto, prod_id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    producto.nombre = datos.nombre.strip()
    producto.descripcion = datos.descripcion.strip() if datos.descripcion else None
    producto.precio = Decimal(str(datos.precio))
    producto.stock = datos.stock
    producto.img = datos.img.strip() if datos.img and datos.img.strip() else None
    db.commit()
    db.refresh(producto)
    return producto


@router.delete("/productos/{prod_id}")
def eliminar_producto(
    prod_id: int,
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    producto = db.get(Producto, prod_id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    tiene_ventas = (
        db.scalar(
            select(func.count(DetallePedido.id_det)).where(
                DetallePedido.prod_id == prod_id
            )
        )
        or 0
    )
    if tiene_ventas > 0:
        raise HTTPException(
            status_code=409,
            detail="El producto tiene pedidos registrados; ajusta el stock a 0 para pausar su venta",
        )

    db.delete(producto)
    db.commit()
    return {"mensaje": "Producto eliminado correctamente"}


# ---------------------------------------------------------
# Pedidos (compra con pago simulado)
# ---------------------------------------------------------

@router.post("/pedidos", response_model=PedidoRespuesta, status_code=201)
def crear_pedido(
    datos: PedidoCrear,
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    # Junta cantidades si el mismo producto viene repetido.
    cantidades: dict[int, int] = {}
    for item in datos.items:
        cantidades[item.prod_id] = cantidades.get(item.prod_id, 0) + item.cantidad

    # El total se calcula con los precios de la BD, nunca con los de la app.
    productos: dict[int, Producto] = {}
    total = Decimal("0")
    for prod_id, cantidad in cantidades.items():
        producto = db.get(Producto, prod_id)
        if producto is None:
            raise HTTPException(status_code=404, detail=f"Producto {prod_id} no encontrado")
        if producto.stock < cantidad:
            raise HTTPException(
                status_code=400,
                detail=f"No hay suficiente stock de '{producto.nombre}' "
                       f"(disponibles: {producto.stock})",
            )
        productos[prod_id] = producto
        total += producto.precio * cantidad

    ultimos4 = validar_pago(datos.pago)

    pedido = Pedido(
        usr_id=actual.id_usr,
        total=total,
        estatus="PAGADO",
        ultimos4=ultimos4,
    )
    db.add(pedido)
    db.flush()  # obtiene el id_ped antes de guardar los detalles

    for prod_id, cantidad in cantidades.items():
        producto = productos[prod_id]
        producto.stock -= cantidad
        db.add(
            DetallePedido(
                ped_id=pedido.id_ped,
                prod_id=prod_id,
                cantidad=cantidad,
                precio_unit=producto.precio,
            )
        )

    db.commit()
    db.refresh(pedido)
    return _armar_respuesta(db, pedido)


@router.get("/pedidos", response_model=list[PedidoRespuesta])
def listar_todos_los_pedidos(
    _: Usuario = Depends(requerir_admin),
    db: Session = Depends(obtener_sesion),
):
    filas = db.execute(
        select(Pedido, Usuario.nom_usr, Usuario.mail)
        .join(Usuario, Usuario.id_usr == Pedido.usr_id)
        .order_by(Pedido.id_ped.desc())
    ).all()
    return [
        _armar_respuesta(db, pedido, cliente=nombre, correo=correo)
        for pedido, nombre, correo in filas
    ]


@router.get("/pedidos/usuario/{usr_id}", response_model=list[PedidoRespuesta])
def pedidos_de_usuario(
    usr_id: int,
    actual: Usuario = Depends(obtener_usuario_actual),
    db: Session = Depends(obtener_sesion),
):
    if actual.tip_usu != 1 and actual.id_usr != usr_id:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para consultar los pedidos de otro usuario",
        )

    pedidos = db.scalars(
        select(Pedido)
        .where(Pedido.usr_id == usr_id)
        .order_by(Pedido.id_ped.desc())
    ).all()
    return [_armar_respuesta(db, pedido) for pedido in pedidos]
