"""Esquemas de validación del módulo de venta y comercio electrónico."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ProductoCrear(BaseModel):
    nombre: str = Field(min_length=2, max_length=150)
    descripcion: str | None = None
    precio: float = Field(gt=0)
    stock: int = Field(ge=0)
    img: str | None = Field(default=None, max_length=500)


class ProductoRespuesta(BaseModel):
    id_prod: int
    nombre: str
    descripcion: str | None = None
    precio: float
    stock: int
    img: str | None = None

    model_config = ConfigDict(from_attributes=True)


class ItemCarrito(BaseModel):
    prod_id: int
    cantidad: int = Field(ge=1, le=99)


class DatosPago(BaseModel):
    """Datos de la tarjeta. Solo se validan; nunca se guardan completos."""

    titular: str = Field(min_length=3, max_length=100)
    numero: str = Field(min_length=13, max_length=23)
    vencimiento: str = Field(min_length=4, max_length=7)  # MM/AA
    cvv: str = Field(min_length=3, max_length=4)


class PedidoCrear(BaseModel):
    usr_id: int
    items: list[ItemCarrito] = Field(min_length=1)
    pago: DatosPago


class DetalleRespuesta(BaseModel):
    prod_id: int
    nombre: str
    cantidad: int
    precio_unit: float
    subtotal: float


class PedidoRespuesta(BaseModel):
    id_ped: int
    fecha: datetime
    total: float
    estatus: str
    ultimos4: str
    detalles: list[DetalleRespuesta]
