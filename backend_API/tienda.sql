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


UPDATE blog SET img = 'https://imgs.search.brave.com/gcnvRWOsA-_lm-msmmzt3NPVd57-xXx4NfHXxhHLyK0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9odHRw/Mi5tbHN0YXRpYy5j/b20vRF9RX05QXzJY/XzczMTM3Ni1NTFU3/NjgwMjYzMTAyNF8w/NjIwMjQtVi53ZWJw' WHERE titulo LIKE 'Cómo armar%';
UPDATE blog SET img = 'https://imgs.search.brave.com/LHCz6J86BvZ7ZOI8w7LXSuyMfDB_kaw9Unu4HiI1iUY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/bGlnYWRlZ2FtZXJz/LmNvbS9pbWFnZW5l/cy9zaG92ZWwta25p/Z2h0LW1lam9yZXMt/anVlZ29zLWluZGll/LmpwZw' WHERE titulo LIKE '5 juegos indie%';
UPDATE blog SET img = 'https://imgs.search.brave.com/611U-u_wjpiF9rbFbKJ-Hsh_B5rm2V3Fz5Zm_TUylKg/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90aHVt/Yi53aWtpbWVkaWEu/b3JnL3dpa2lwZWRp/YS9jb21tb25zL3Ro/dW1iL2EvYTQvWGJv/eF9DbG91ZF9HYW1p/bmdfbG9nby5wbmcv/MjUwcHgtWGJveF9D/bG91ZF9HYW1pbmdf/bG9nby5wbmc_dXRt/X3NvdXJjZT1lbi53/aWtpcGVkaWEub3Jn/JnV0bV9jYW1wYWln/bj1wYXJzZXImdXRt/X2NvbnRlbnQ9dGh1/bWJuYWls' WHERE titulo LIKE '¿Vale la pena%';
UPDATE blog SET img = 'https://imgs.search.brave.com/tL8sntU0Tgtfi-ZtX1h5Wv_4VT6JrSICYqQX0qfkvOw/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5uYWNvbmdhbWlu/Zy5jb20vbWVkaWEv/YW1hc3R5L2Jsb2cv/Y2FjaGUvcC9sLzE5/MjAvMTA4MC9wbGF5/X21pbmVjcmFmdF9j/b250cm9sbGVyLndl/YnA' WHERE titulo LIKE 'Consejos para mejorar%';
UPDATE blog SET img = 'https://imgs.search.brave.com/MG6T007MbzGnSGQcON5QRwfLgJPi5TP7-PAvSiZdZ6M/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zMS5z/dGF0aWNsZC5jb20v/MjAyMi8wMi8yNS9j/b25zb2xhLXJldHJv/LW5pbnRlbmRvLXN1/cGVyLW5lcy1jbGFz/c2ljLW1pbmkuanBn' WHERE titulo LIKE 'El regreso de lo retro%';

UPDATE bd_aplicacion_movil.producto SET img = 'https://images-na.ssl-images-amazon.com/images/I/51jHP4rL3iL.jpg' WHERE nombre = 'Control inalámbrico Pro';
UPDATE bd_aplicacion_movil.producto SET img = 'https://m.media-amazon.com/images/I/51GfYCZuI4L.jpg' WHERE nombre = 'Audífonos gamer 7.1';
UPDATE bd_aplicacion_movil.producto SET img = 'https://pcdiga-prod.eu.saleor.cloud/media/thumbnails/products/1_a8677c40_thumbnail_1024.jpg' WHERE nombre = 'Teclado mecánico RGB';
UPDATE bd_aplicacion_movil.producto SET img = 'https://m.media-amazon.com/images/I/61uvGH2OjlL.jpg' WHERE nombre = 'Mouse gamer 16000 DPI';
UPDATE bd_aplicacion_movil.producto SET img = 'https://ss628.liverpool.com.mx/lg/1124625099.jpg' WHERE nombre = 'Silla gamer ergonómica';
UPDATE bd_aplicacion_movil.producto SET img = 'https://m.media-amazon.com/images/I/412z+cFioDL.jpg' WHERE nombre = 'Mousepad XL';
UPDATE bd_aplicacion_movil.producto SET img = 'https://i5.walmartimages.com/asr/af3f7c38-2573-4d95-a279-0c1521466a1e.45ddf4b0edcbcd9af929e779680938b3.jpeg' WHERE nombre = 'Tarjeta de regalo $500';
UPDATE bd_aplicacion_movil.producto SET img = 'https://m.media-amazon.com/images/I/81zWu71x-RL.jpg' WHERE nombre = 'Soporte para audífonos';