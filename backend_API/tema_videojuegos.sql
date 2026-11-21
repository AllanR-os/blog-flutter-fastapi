-- =========================================================
-- RESPAWN · Contenido temático de videojuegos
-- Reemplaza las publicaciones, comentarios y productos de
-- ejemplo. Ejecutar DESPUÉS de bd.sql y tienda.sql.
-- ¡Borra los pedidos de prueba existentes!
-- =========================================================

SET NAMES utf8mb4;

USE bd_aplicacion_movil;

-- Limpiar contenido anterior (en orden, por las llaves foráneas)
DELETE FROM comentarios;
DELETE FROM blog;
DELETE FROM detalle_pedido;
DELETE FROM pedido;
DELETE FROM producto;

ALTER TABLE comentarios AUTO_INCREMENT = 1;
ALTER TABLE blog AUTO_INCREMENT = 1;
ALTER TABLE detalle_pedido AUTO_INCREMENT = 1;
ALTER TABLE pedido AUTO_INCREMENT = 1;
ALTER TABLE producto AUTO_INCREMENT = 1;

-- Usuarios que firmarán las publicaciones y comentarios de ejemplo
SET @u1 = (SELECT MIN(id_usr) FROM usuario);
SET @u2 = (SELECT MAX(id_usr) FROM usuario);

-- ---------------------------------------------------------
-- Blog (repartido entre usuarios para entradas propias y de otros)
-- ---------------------------------------------------------

INSERT INTO blog (titulo, `desc`, img, tags, usr_id) VALUES (
  'Cómo armar tu primer setup gamer sin gastar de más',
  'Antes de comprar la tarjeta de video más cara, piensa en qué juegas y en qué monitor lo vas a ver. Un monitor de 144 Hz cambia más la experiencia que muchos componentes caros. Prioriza una silla cómoda y buena postura: vas a pasar horas ahí. Después elige un mouse que se ajuste a tu mano y un teclado que te guste escribir. Por último, la iluminación RGB es lo menos importante… aunque se vea increíble en las fotos.',
  'https://imgs.search.brave.com/gcnvRWOsA-_lm-msmmzt3NPVd57-xXx4NfHXxhHLyK0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9odHRw/Mi5tbHN0YXRpYy5j/b20vRF9RX05QXzJY/XzczMTM3Ni1NTFU3/NjgwMjYzMTAyNF8w/NjIwMjQtVi53ZWJw',
  'Guías, PC',
  @u1
);
SET @b1 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags, usr_id) VALUES (
  '5 juegos indie que no te puedes perder',
  'Los estudios pequeños están detrás de algunas de las experiencias más creativas de los últimos años. Busca juegos con mecánicas únicas, como los roguelikes donde cada partida es distinta, los de exploración con historias contadas sin palabras o los de plataformas con controles precisos. Muchos cuestan menos que un juego grande y se terminan en un fin de semana. Revisa las tiendas digitales en temporada de ofertas y apoya a los desarrolladores independientes.',
  'https://imgs.search.brave.com/LHCz6J86BvZ7ZOI8w7LXSuyMfDB_kaw9Unu4HiI1iUY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/bGlnYWRlZ2FtZXJz/LmNvbS9pbWFnZW5l/cy9zaG92ZWwta25p/Z2h0LW1lam9yZXMt/anVlZ29zLWluZGll/LmpwZw',
  'Indie, Recomendaciones',
  @u2
);
SET @b2 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags, usr_id) VALUES (
  '¿Vale la pena jugar en la nube?',
  'El juego en la nube permite correr títulos exigentes en equipos sencillos, porque el juego se procesa en un servidor y a ti solo te llega el video. La gran ventaja es no depender del hardware; la desventaja es que necesitas una conexión estable y rápida, idealmente por cable. Para juegos de reflejos rápidos la latencia todavía se nota, pero para aventuras, estrategia o RPG puede ser una gran opción.',
  'https://imgs.search.brave.com/611U-u_wjpiF9rbFbKJ-Hsh_B5rm2V3Fz5Zm_TUylKg/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90aHVt/Yi53aWtpbWVkaWEu/b3JnL3dpa2lwZWRp/YS9jb21tb25zL3Ro/dW1iL2EvYTQvWGJv/eF9DbG91ZF9HYW1p/bmdfbG9nby5wbmcv/MjUwcHgtWGJveF9D/bG91ZF9HYW1pbmdf/bG9nby5wbmc_dXRt/X3NvdXJjZT1lbi53/aWtpcGVkaWEub3Jn/JnV0bV9jYW1wYWln/bj1wYXJzZXImdXRt/X2NvbnRlbnQ9dGh1/bWJuYWls',
  'Tecnología, Nube',
  @u1
);
SET @b3 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags, usr_id) VALUES (
  'Consejos para mejorar tu puntería en shooters',
  'La puntería se entrena como cualquier habilidad. Baja la sensibilidad del mouse para movimientos más controlados y usa siempre la misma. Coloca la mira a la altura de la cabeza mientras te desplazas, para moverla menos al encontrar a un rival. Practica 10 minutos al día en un modo de entrenamiento antes de jugar partidas. Y lo más importante: la constancia vale más que una sesión larga una vez por semana.',
  'https://imgs.search.brave.com/tL8sntU0Tgtfi-ZtX1h5Wv_4VT6JrSICYqQX0qfkvOw/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5uYWNvbmdhbWlu/Zy5jb20vbWVkaWEv/YW1hc3R5L2Jsb2cv/Y2FjaGUvcC9sLzE5/MjAvMTA4MC9wbGF5/X21pbmVjcmFmdF9j/b250cm9sbGVyLndl/YnA',
  'Guías, Shooters',
  @u2
);
SET @b4 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags, usr_id) VALUES (
  'El regreso de lo retro: por qué volvemos a los clásicos',
  'Los juegos retro siguen vigentes porque son fáciles de entender y difíciles de dominar. Hoy existen colecciones oficiales, consolas mini y remasterizaciones que permiten volver a jugar títulos de los 80 y 90 con mejor imagen. Además, muchos juegos nuevos usan gráficos pixelados como estilo artístico. Lo retro no es solo nostalgia: es un recordatorio de que la diversión no depende de los gráficos.',
  'https://imgs.search.brave.com/MG6T007MbzGnSGQcON5QRwfLgJPi5TP7-PAvSiZdZ6M/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zMS5z/dGF0aWNsZC5jb20v/MjAyMi8wMi8yNS9j/b25zb2xhLXJldHJv/LW5pbnRlbmRvLXN1/cGVyLW5lcy1jbGFz/c2ljLW1pbmkuanBn',
  'Retro, Cultura',
  @u1
);
SET @b5 = LAST_INSERT_ID();

-- ---------------------------------------------------------
-- Comentarios
-- ---------------------------------------------------------

INSERT INTO comentarios (comentario, estatus, usr_id, blog_id) VALUES
  ('Lo del monitor de 144 Hz es totalmente cierto, se nota muchísimo.', 1, @u2, @b1),
  ('¿Qué silla recomiendan para alguien que juega muchas horas?', 1, @u1, @b1),
  ('Los roguelikes son mis favoritos, nunca me aburro.', 1, @u1, @b2),
  ('Probé jugar en la nube por Wi-Fi y se trababa; por cable va mucho mejor.', 1, @u2, @b3),
  ('Bajar la sensibilidad me ayudó un montón, gracias por el consejo.', 1, @u1, @b4),
  ('Nada como los juegos de antes, buenísimo el artículo.', 1, @u2, @b5);

-- ---------------------------------------------------------
-- Tienda
-- ---------------------------------------------------------

INSERT INTO producto (nombre, descripcion, precio, stock, img) VALUES
  ('Control inalámbrico Pro',
   'Control con conexión Bluetooth, gatillos de precisión y batería de hasta 30 horas.',
   1299.00, 12, 'https://images-na.ssl-images-amazon.com/images/I/51jHP4rL3iL.jpg'),
  ('Audífonos gamer 7.1',
   'Sonido envolvente 7.1, micrófono con cancelación de ruido y almohadillas de espuma.',
   899.00, 20, 'https://m.media-amazon.com/images/I/51GfYCZuI4L.jpg'),
  ('Teclado mecánico RGB',
   'Switches mecánicos, iluminación RGB por tecla y reposamuñecas desmontable.',
   1149.00, 15, 'https://pcdiga-prod.eu.saleor.cloud/media/thumbnails/products/1_a8677c40_thumbnail_1024.jpg'),
  ('Mouse gamer 16000 DPI',
   'Sensor óptico de 16000 DPI, 7 botones programables y peso ajustable.',
   649.00, 25, 'https://m.media-amazon.com/images/I/61uvGH2OjlL.jpg'),
  ('Silla gamer ergonómica',
   'Respaldo reclinable, soporte lumbar y cojín para cuello. Soporta hasta 120 kg.',
   3499.00, 5, 'https://ss628.liverpool.com.mx/lg/1124625099.jpg'),
  ('Mousepad XL',
   'Superficie de tela de 90 x 40 cm con base antideslizante y bordes cosidos.',
   299.00, 40, 'https://m.media-amazon.com/images/I/412z+cFioDL.jpg'),
  ('Tarjeta de regalo $500',
   'Código digital para comprar juegos en tiendas en línea. Se envía por correo.',
   500.00, 100, 'https://i5.walmartimages.com/asr/af3f7c38-2573-4d95-a279-0c1521466a1e.45ddf4b0edcbcd9af929e779680938b3.jpeg'),
  ('Soporte para audífonos',
   'Base de aluminio con hub USB de 2 puertos para mantener tu escritorio ordenado.',
   389.00, 18, 'https://m.media-amazon.com/images/I/81zWu71x-RL.jpg');
