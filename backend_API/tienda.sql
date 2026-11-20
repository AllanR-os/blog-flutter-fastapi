-- =========================================================
-- MÓDULO DE VENTA Y COMERCIO ELECTRÓNICO
-- Catálogo de productos, pedidos y detalle de pedidos.
-- Ejecutar DESPUÉS de bd.sql (necesita la tabla usuario).
-- =========================================================

USE bd_aplicacion_movil;

CREATE TABLE IF NOT EXISTS producto (
    id_prod INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    img VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS pedido (
    id_ped INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    estatus VARCHAR(30) NOT NULL DEFAULT 'PAGADO',
    ultimos4 CHAR(4) NOT NULL,

    CONSTRAINT fk_pedido_usuario
        FOREIGN KEY (usr_id)
        REFERENCES usuario(id_usr)
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_det INT AUTO_INCREMENT PRIMARY KEY,
    ped_id INT NOT NULL,
    prod_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unit DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (ped_id)
        REFERENCES pedido(id_ped),

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (prod_id)
        REFERENCES producto(id_prod)
);

INSERT INTO producto (nombre, descripcion, precio, stock, img)
VALUES
    ('Libro: Flutter desde cero',
     'Guía práctica para crear aplicaciones móviles con Flutter y Dart.',
     349.00, 15, 'https://picsum.photos/400/300?random=11'),
    ('Taza para programadores',
     'Taza de cerámica de 350 ml con diseño de código.',
     159.50, 30, 'https://picsum.photos/400/300?random=12'),
    ('Sudadera Dev',
     'Sudadera de algodón con capucha, tallas S a XL.',
     499.00, 10, 'https://picsum.photos/400/300?random=13'),
    ('Stickers de tecnología',
     'Paquete de 20 stickers de lenguajes y frameworks.',
     89.00, 50, 'https://picsum.photos/400/300?random=14');
