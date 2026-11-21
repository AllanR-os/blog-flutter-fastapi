SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bd_aplicacion_movil;

CREATE TABLE usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200),
    tip_usu INT NOT NULL DEFAULT 2
);

CREATE TABLE blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT,
    img VARCHAR(500),
    tags VARCHAR(255),
    usr_id INT NOT NULL,

    CONSTRAINT fk_blog_usuario
        FOREIGN KEY (usr_id)
        REFERENCES usuario(id_usr)
);

CREATE TABLE comentarios (
    id_com INT AUTO_INCREMENT PRIMARY KEY,
    comentario TEXT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estatus INT NOT NULL DEFAULT 1,
    usr_id INT NOT NULL,
    blog_id INT NOT NULL,

    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (usr_id)
        REFERENCES usuario(id_usr),

    CONSTRAINT fk_comentario_blog
        FOREIGN KEY (blog_id)
        REFERENCES blog(id_blog)
);

-- Cuentas semilla de prueba (contraseña inicial para ambas: 12345678)
INSERT INTO usuario
    (nom_usr, mail, pass, dir_usr, tip_usu)
VALUES
    ('Adriana Contreras', 'adriana@ejemplo.com',
     '$argon2id$v=19$m=65536,t=3,p=4$mEHRq97lMdfjHILhdDMI7A$ufG9cg2XEX1o984pwpMup1tr7cx6v+fAbh5yb2/1Ev0',
     'Querétaro', 1),
    ('Carlos Pérez', 'carlos@ejemplo.com',
     '$argon2id$v=19$m=65536,t=3,p=4$JsFlk/S9IiXdDwSxu4R7Ww$AekbZ6RQQ+220uy8+qSHIlG2bdzLtcjq3rDUnfDBkTU',
     'Querétaro', 2);

INSERT INTO blog (titulo, `desc`, img, tags, usr_id)
VALUES
    (
      'Construyendo aplicaciones con Flutter',
      'Una introducción al desarrollo móvil con Dart.',
      'https://picsum.photos/800/400?random=1',
      'Flutter,Dart',
      1
    ),
    (
      'Introducción a la inteligencia artificial',
      'Conceptos fundamentales de inteligencia artificial.',
      'https://picsum.photos/800/400?random=2',
      'IA,tecnología',
      2
    );

INSERT INTO comentarios
    (comentario, estatus, usr_id, blog_id)
VALUES
    ('Muy útil la explicación de Flutter.', 1, 1, 1),
    ('Me gustaría ver más ejemplos.', 1, 2, 1),
    ('Buen artículo de introducción.', 1, 1, 2);
