# Blog móvil con Flutter, FastAPI y MySQL

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
- Visualización de publicaciones y sus comentarios.

## Estructura del repositorio

```
├── backend_API/            API en FastAPI
│   ├── main.py             Rutas (endpoints) de la API
│   ├── database.py         Conexión a MySQL
│   ├── models.py           Modelos de SQLAlchemy (tablas)
│   ├── schemas.py          Esquemas de validación (Pydantic)
│   ├── bd.sql              Script de creación de la base de datos
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
```

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
| POST | `/comentarios` | Crea comentario |