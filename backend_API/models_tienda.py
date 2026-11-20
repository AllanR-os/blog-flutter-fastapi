"""Modelos (tablas) del módulo de venta y comercio electrónico."""

from sqlalchemy import Column, DateTime, Integer, Numeric, String, Text, func

from database import Base


class Producto(Base):
    __tablename__ = "producto"

    id_prod = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(150), nullable=False)
    descripcion = Column(Text)
    precio = Column(Numeric(10, 2), nullable=False)
    stock = Column(Integer, nullable=False, default=0)
    img = Column(String(500))


class Pedido(Base):
    __tablename__ = "pedido"

    id_ped = Column(Integer, primary_key=True, autoincrement=True)
    usr_id = Column(Integer, nullable=False)
    fecha = Column(DateTime, nullable=False, server_default=func.now())
    total = Column(Numeric(10, 2), nullable=False)
    estatus = Column(String(30), nullable=False, default="PAGADO")
    ultimos4 = Column(String(4), nullable=False)


class DetallePedido(Base):
    __tablename__ = "detalle_pedido"

    id_det = Column(Integer, primary_key=True, autoincrement=True)
    ped_id = Column(Integer, nullable=False)
    prod_id = Column(Integer, nullable=False)
    cantidad = Column(Integer, nullable=False)
    precio_unit = Column(Numeric(10, 2), nullable=False)
