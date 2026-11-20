"""Autenticación con JWT (HS256) y control de acceso por rol (RBAC)."""

from datetime import datetime, timedelta, timezone
import os

from dotenv import load_dotenv
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import jwt
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Usuario

load_dotenv()

JWT_ALGORITHM = "HS256"
JWT_SECRET = os.getenv(
    "JWT_SECRET",
    "respawn_clave_desarrollo_local_cambiar_en_env_32chars",
)
JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", "1440"))

esquema_bearer = HTTPBearer(auto_error=False)


def crear_token_acceso(usuario: Usuario) -> str:
    """Genera un JWT firmado con identificador, rol y expiración."""
    ahora = datetime.now(timezone.utc)
    payload = {
        "sub": str(usuario.id_usr),
        "tip_usu": usuario.tip_usu,
        "iat": ahora,
        "exp": ahora + timedelta(minutes=JWT_EXPIRE_MINUTES),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def _usuario_desde_token(token: str, db: Session) -> Usuario:
    """Decodifica el JWT y valida que el usuario siga activo en MySQL."""
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM],
        )
        usuario_id = int(payload["sub"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=401,
            detail="La sesión ha expirado. Inicia sesión nuevamente",
        )
    except (jwt.InvalidTokenError, KeyError, TypeError, ValueError):
        raise HTTPException(
            status_code=401,
            detail="Token de sesión inválido",
        )

    usuario = db.get(Usuario, usuario_id)
    if usuario is None:
        raise HTTPException(
            status_code=401,
            detail="Usuario de la sesión no encontrado",
        )
    return usuario


def obtener_usuario_actual(
    credenciales: HTTPAuthorizationCredentials | None = Depends(esquema_bearer),
    db: Session = Depends(obtener_sesion),
) -> Usuario:
    """Exige un token Bearer válido en el encabezado Authorization."""
    if credenciales is None or credenciales.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=401,
            detail="Se requiere iniciar sesión para acceder a este recurso",
        )
    return _usuario_desde_token(credenciales.credentials, db)


def obtener_usuario_opcional(
    credenciales: HTTPAuthorizationCredentials | None = Depends(esquema_bearer),
    db: Session = Depends(obtener_sesion),
) -> Usuario | None:
    """Permite acceso público; si llega Authorization, valida el JWT."""
    if credenciales is None:
        return None
    if credenciales.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=401,
            detail="Esquema de autenticación inválido",
        )
    return _usuario_desde_token(credenciales.credentials, db)


def requerir_admin(
    actual: Usuario = Depends(obtener_usuario_actual),
) -> Usuario:
    """Restringe la operación exclusivamente a usuarios Administrador (tip_usu = 1)."""
    if actual.tip_usu != 1:
        raise HTTPException(
            status_code=403,
            detail="Se requieren permisos de administrador",
        )
    return actual
