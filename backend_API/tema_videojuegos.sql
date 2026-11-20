-- =========================================================
-- RESPAWN · Contenido temático de videojuegos
-- Reemplaza las publicaciones, comentarios y productos de
-- ejemplo. Ejecutar DESPUÉS de bd.sql y tienda.sql.
-- ¡Borra los pedidos de prueba existentes!
-- =========================================================

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

-- Usuarios que firmarán los comentarios de ejemplo
SET @u1 = (SELECT MIN(id_usr) FROM usuario);
SET @u2 = (SELECT MAX(id_usr) FROM usuario);

-- ---------------------------------------------------------
-- Blog
-- ---------------------------------------------------------

INSERT INTO blog (titulo, `desc`, img, tags) VALUES (
  'Cómo armar tu primer setup gamer sin gastar de más',
  'Antes de comprar la tarjeta de video más cara, piensa en qué juegas y en qué monitor lo vas a ver. Un monitor de 144 Hz cambia más la experiencia que muchos componentes caros. Prioriza una silla cómoda y buena postura: vas a pasar horas ahí. Después elige un mouse que se ajuste a tu mano y un teclado que te guste escribir. Por último, la iluminación RGB es lo menos importante… aunque se vea increíble en las fotos.',
  NULL,
  'Guías, PC'
);
SET @b1 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags) VALUES (
  '5 juegos indie que no te puedes perder',
  'Los estudios pequeños están detrás de algunas de las experiencias más creativas de los últimos años. Busca juegos con mecánicas únicas, como los roguelikes donde cada partida es distinta, los de exploración con historias contadas sin palabras o los de plataformas con controles precisos. Muchos cuestan menos que un juego grande y se terminan en un fin de semana. Revisa las tiendas digitales en temporada de ofertas y apoya a los desarrolladores independientes.',
  NULL,
  'Indie, Recomendaciones'
);
SET @b2 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags) VALUES (
  '¿Vale la pena jugar en la nube?',
  'El juego en la nube permite correr títulos exigentes en equipos sencillos, porque el juego se procesa en un servidor y a ti solo te llega el video. La gran ventaja es no depender del hardware; la desventaja es que necesitas una conexión estable y rápida, idealmente por cable. Para juegos de reflejos rápidos la latencia todavía se nota, pero para aventuras, estrategia o RPG puede ser una gran opción.',
  NULL,
  'Tecnología, Nube'
);
SET @b3 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags) VALUES (
  'Consejos para mejorar tu puntería en shooters',
  'La puntería se entrena como cualquier habilidad. Baja la sensibilidad del mouse para movimientos más controlados y usa siempre la misma. Coloca la mira a la altura de la cabeza mientras te desplazas, para moverla menos al encontrar a un rival. Practica 10 minutos al día en un modo de entrenamiento antes de jugar partidas. Y lo más importante: la constancia vale más que una sesión larga una vez por semana.',
  NULL,
  'Guías, Shooters'
);
SET @b4 = LAST_INSERT_ID();

INSERT INTO blog (titulo, `desc`, img, tags) VALUES (
  'El regreso de lo retro: por qué volvemos a los clásicos',
  'Los juegos retro siguen vigentes porque son fáciles de entender y difíciles de dominar. Hoy existen colecciones oficiales, consolas mini y remasterizaciones que permiten volver a jugar títulos de los 80 y 90 con mejor imagen. Además, muchos juegos nuevos usan gráficos pixelados como estilo artístico. Lo retro no es solo nostalgia: es un recordatorio de que la diversión no depende de los gráficos.',
  NULL,
  'Retro, Cultura'
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
   1299.00, 12, NULL),
  ('Audífonos gamer 7.1',
   'Sonido envolvente 7.1, micrófono con cancelación de ruido y almohadillas de espuma.',
   899.00, 20, NULL),
  ('Teclado mecánico RGB',
   'Switches mecánicos, iluminación RGB por tecla y reposamuñecas desmontable.',
   1149.00, 15, NULL),
  ('Mouse gamer 16000 DPI',
   'Sensor óptico de 16000 DPI, 7 botones programables y peso ajustable.',
   649.00, 25, NULL),
  ('Silla gamer ergonómica',
   'Respaldo reclinable, soporte lumbar y cojín para cuello. Soporta hasta 120 kg.',
   3499.00, 5, NULL),
  ('Mousepad XL',
   'Superficie de tela de 90 x 40 cm con base antideslizante y bordes cosidos.',
   299.00, 40, NULL),
  ('Tarjeta de regalo $500',
   'Código digital para comprar juegos en tiendas en línea. Se envía por correo.',
   500.00, 100, NULL),
  ('Soporte para audífonos',
   'Base de aluminio con hub USB de 2 puertos para mantener tu escritorio ordenado.',
   389.00, 18, NULL);
