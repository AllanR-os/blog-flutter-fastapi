# Respawn · Blog y tienda gamer con Flutter, FastAPI y MySQL

Aplicación móvil de blog desarrollada en **Flutter**, conectada a una **API REST en FastAPI** que almacena la información en **MySQL**.

**Autora:** Erick Gonzales Gomez, Allan Roberto Ortiz Sanchez 
**Materia:** PROGRAMACION PARA MOVILES II

## Funcionalidades

- Inicio de sesión con validación de credenciales contra la base de datos.
- Contraseñas encriptadas con **Argon2** (librería `pwdlib`); nunca se guardan ni se devuelven en texto plano.
- Redirección según el tipo de usuario:
  - **Tipo 1 (Administrador):** gestión de usuarios y menú lateral de administración.
  - **Tipo 2 (General):** blog de publicaciones.
- Gestión de usuarios (crear, editar, eliminar).
- Registro de usuarios: el administrador elige si el nuevo usuario es Administrador o General; el registro público siempre crea usuarios generales.
- Agregar publicaciones al blog.
- Perfil del usuario con actualización de datos.
- Blog de videojuegos con filtro por categorías.
- Lectura y creación de comentarios en cada publicación.
- **Módulo de venta y comercio electrónico (alcance extendido):**
  - Catálogo de productos y alta de productos por el administrador.
  - Carrito de compras con control de stock.
  - Proceso de pago **simulado**: se valida la tarjeta (algoritmo de Luhn, vencimiento y CVV) sin cobro real; solo se guardan los últimos 4 dígitos y el total se calcula en el servidor.
  - Historial de pedidos del usuario.
- Tema visual oscuro propio (fuentes Chakra Petch e Inter).

## Estructura del repositorio

```
├── backend_API/            API en FastAPI
│   ├── main.py             Rutas (endpoints) de la API
│   ├── database.py         Conexión a MySQL
│   ├── models.py           Modelos de SQLAlchemy (tablas)
│   ├── schemas.py          Esquemas de validación (Pydantic)
│   ├── bd.sql              Script de creación de la base de datos
│   ├── tienda.sql          Tablas del módulo de tienda
│   ├── tema_videojuegos.sql Contenido de ejemplo (blog, comentarios, productos)
│   ├── tienda.py           Rutas de la tienda y pago simulado
│   └── .env.example        Ejemplo de configuración
└── flutter_application_3/  Aplicación móvil en Flutter
    └── lib/
        ├── models/         Modelos de datos
        ├── services/       Conexión con la API
        ├── screens/        Pantallas
        └── widgets/        Componentes reutilizables
```

## Modelo de datos

| Tabla | Campos principales |
|---|---|
| `usuario` | `id_usr`, `nom_usr`, `mail` (único), `pass` (hash), `dir_usr`, `tip_usu` |
| `blog` | `id_blog`, `titulo`, `desc`, `img`, `tags` |
| `comentarios` | `id_com`, `comentario`, `fecha`, `estatus`, `usr_id` → usuario, `blog_id` → blog |

## Requisitos

- Python 3.12 o 3.13
- MySQL 8 o superior
- Flutter 3.x
- Google Chrome

## Instalación

### 1. Base de datos

Ejecuta el script `backend_API/bd.sql` en MySQL Workbench (File → Open SQL Script → ⚡) o desde la terminal:

```bash
mysql -u root -p < backend_API/bd.sql
mysql -u root -p < backend_API/tienda.sql
mysql -u root -p < backend_API/tema_videojuegos.sql
```

Ejecuta los tres scripts en ese orden (en phpMyAdmin: pestaña **SQL**, pegar y **Continuar**).

### 2. Backend (API)

```bash
cd backend_API
python3 -m venv venv
source venv/bin/activate            # Windows: .\venv\Scripts\Activate.ps1
pip install fastapi "uvicorn[standard]" sqlalchemy pymysql python-dotenv "pwdlib[argon2]" cryptography
```

Copia `.env.example` como `.env` y escribe tu contraseña de MySQL:

```bash
cp .env.example .env                # Windows: copy .env.example .env
```

Inicia la API:

```bash
uvicorn main:app --reload
```

La API queda en `http://127.0.0.1:8000` y su documentación en `http://127.0.0.1:8000/docs`.

### 3. Aplicación Flutter

En otra terminal:

```bash
cd flutter_application_3
flutter pub add google_fonts
flutter pub get
flutter run -d chrome --web-port 60450
```

> Es importante usar `--web-port 60450`: la API solo acepta peticiones (CORS) desde ese puerto.

## Uso

Los usuarios de ejemplo de `bd.sql` tienen una contraseña de prueba sin encriptar, así que no pueden iniciar sesión. Para crear usuarios válidos, abre `http://127.0.0.1:8000/docs` → **POST /usuarios** → **Try it out**:

```json
{
  "nom_usr": "Admin Prueba",
  "mail": "admin@prueba.com",
  "password": "12345678",
  "dir_usr": "Queretaro",
  "tip_usu": 1
}
```

Usa `"tip_usu": 1` para un administrador y `"tip_usu": 2` para un usuario general. Después inicia sesión en la app con ese correo y contraseña.

## Endpoints principales

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/login` | Inicia sesión (devuelve 401 si las credenciales son incorrectas) |
| GET | `/usuarios` | Lista usuarios |
| POST | `/usuarios` | Crea usuario (encripta la contraseña) |
| PUT | `/usuarios/{id}` | Actualiza usuario |
| DELETE | `/usuarios/{id}` | Elimina usuario |
| GET | `/blog` | Lista publicaciones |
| POST | `/blog` | Crea publicación |
| GET | `/comentarios` | Lista comentarios |
| POST | `/comentarios` | Crea comentario || GET | `/productos` | Lista productos de la tienda |
| POST | `/productos` | Crea producto |
| POST | `/pedidos` | Compra con pago simulado (valida stock y tarjeta) |
| GET | `/pedidos/usuario/{id}` | Historial de pedidos de un usuario |

### Tarjetas de prueba (pago simulado)

| Número | Resultado |
|---|---|
| `4242 4242 4242 4242` | Pago aprobado |
| `4000 0000 0000 0002` | Pago rechazado por el banco |

Usa cualquier fecha futura (por ejemplo `12/30`) y cualquier CVV de 3 dígitos.
