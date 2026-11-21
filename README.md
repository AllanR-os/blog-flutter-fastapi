# Respawn · Blog y tienda gamer con Flutter, FastAPI y MySQL

Aplicación móvil y web de blog comunitario y tienda gamer desarrollada en **Flutter**, conectada a una **API REST en FastAPI** con autenticación **JWT + RBAC** y persistencia en **MySQL**.

**Autores:** Erick Gonzalez Gomez, Allan Roberto Ortiz Sanchez
**Materia:** Programación para Móviles II

## Funcionalidades

- Inicio de sesión seguro con validación de credenciales contra MySQL y emisión de token **JWT (`HS256`)**.
- Contraseñas encriptadas con **Argon2** (`pwdlib`); nunca se almacenan ni se devuelven en texto plano.
- Control de acceso por rol (**RBAC**) aplicado en servidor y reflejado en la interfaz:
  - **Tipo 1 (Administrador):** gestión de usuarios, alta de administradores desde `/register`, alta de productos en tienda, perfil, blog y compras.
  - **Tipo 2 (General):** registro público forzado a rol General en API y UI, lectura y publicación de entradas en el blog, comentarios, perfil propio y tienda.
- Blog comunitario con autoría (`usr_id`), filtro por categorías y vista de **Mis publicaciones** frente a entradas de otros usuarios.
- Lectura y creación de comentarios en cada publicación con el nombre del autor resuelto en servidor.
- **Módulo de venta y comercio electrónico (alcance extendido):**
  - Catálogo de productos y alta de productos por el administrador.
  - Carrito de compras con control de stock.
  - Proceso de pago **simulado**: valida tarjeta (algoritmo de Luhn, vencimiento y CVV) sin cobro real, guarda únicamente los últimos 4 dígitos y calcula el total en el servidor.
  - Historial de pedidos protegido por propietario o administrador.
- Tema visual oscuro propio (fuentes Chakra Petch e Inter).

## Estructura del repositorio

```text
├── docker-compose.yml       Contenedor opcional de MySQL 8.0 + phpMyAdmin
├── backend_API/             API en FastAPI
│   ├── main.py              Rutas de autenticación, usuarios, blog y comentarios
│   ├── seguridad.py         Emisión y validación JWT + dependencias RBAC
│   ├── tienda.py            Rutas de la tienda y pago simulado
│   ├── database.py          Conexión a MySQL desde .env
│   ├── models.py            Modelos SQLAlchemy (usuario, blog, comentarios)
│   ├── models_tienda.py     Modelos SQLAlchemy (producto, pedido, detalle_pedido)
│   ├── schemas.py           Esquemas Pydantic del núcleo
│   ├── schemas_tienda.py    Esquemas Pydantic de la tienda
│   ├── bd.sql               Esquema base y cuentas semilla con Argon2
│   ├── tienda.sql           Tablas del módulo de comercio electrónico
│   ├── tema_videojuegos.sql Contenido gamer (posts con autoría, comentarios y productos)
│   ├── requirements.txt     Dependencias de Python
│   ├── test_e2e_api.py      Pruebas E2E de contratos y permisos de la API
│   └── .env.example         Plantilla de configuración de entorno
└── flutter_application_3/   Aplicación en Flutter
    └── lib/
        ├── models/          Modelos de datos
        ├── services/        Servicios HTTP con Bearer JWT, sesión y carrito
        ├── screens/         Pantallas
        ├── widgets/         Componentes reutilizables
        └── theme/           Paleta y tipografía
```

## Modelo de datos

| Tabla | Campos principales |
| :--- | :--- |
| `usuario` | `id_usr`, `nom_usr`, `mail` (único), `pass` (hash Argon2), `dir_usr`, `tip_usu` |
| `blog` | `id_blog`, `titulo`, `desc`, `img`, `tags`, `usr_id` -> `usuario(id_usr)` |
| `comentarios` | `id_com`, `comentario`, `fecha`, `estatus`, `usr_id` -> `usuario`, `blog_id` -> `blog` |
| `producto` | `id_prod`, `nombre`, `descripcion`, `precio`, `stock`, `img` |
| `pedido` | `id_ped`, `usr_id` -> `usuario`, `fecha`, `total`, `estatus`, `ultimos4` |
| `detalle_pedido` | `id_det`, `ped_id` -> `pedido`, `prod_id` -> `producto`, `cantidad`, `precio_unit` |

## Requisitos

- Python 3.12+
- Docker y Docker Compose (opción contenerizada) o MySQL 8+ local (XAMPP / Workbench)
- Flutter 3.x y Google Chrome

## Instalación

### 1. Base de datos

**Opción A · Contenerizada con Docker (recomendada):**

```bash
docker compose up -d
```

Levanta MySQL 8.0 en `127.0.0.1:3306` y phpMyAdmin en `http://localhost:8080`, ejecutando automáticamente `bd.sql`, `tienda.sql` y `tema_videojuegos.sql` en orden.

**Opción B · MySQL local / XAMPP:**

Ejecuta los tres scripts en este orden (desde MySQL Workbench, phpMyAdmin o terminal):

```bash
mysql -u root -p < backend_API/bd.sql
mysql -u root -p < backend_API/tienda.sql
mysql -u root -p < backend_API/tema_videojuegos.sql
```

### 2. Backend (API)

```bash
cd backend_API
python3 -m venv venv
source venv/bin/activate            # Windows: .\venv\Scripts\Activate.ps1
pip install -r requirements.txt
cp .env.example .env                # Windows: copy .env.example .env
```

Ajusta `DB_PASSWORD` y `JWT_SECRET` en `backend_API/.env` si difieren de la configuración de Docker (`root`), e inicia la API:

```bash
uvicorn main:app --reload
```

La API responde en `http://127.0.0.1:8000` y su documentación interactiva (con botón **Authorize** para Bearer JWT) en `http://127.0.0.1:8000/docs`.

### 3. Aplicación Flutter

En otra terminal:

```bash
cd flutter_application_3
flutter pub get
flutter run -d chrome --web-port 60450
```

> Usa `--web-port 60450`: la configuración CORS de la API permite el origen en ese puerto.

## Cuentas semilla y verificación E2E

Las cuentas precargadas en `bd.sql` usan hashes Argon2 válidos con la contraseña de prueba `12345678`:

| Correo | Nombre | Rol (`tip_usu`) |
| :--- | :--- | :---: |
| `adriana@ejemplo.com` | Adriana Contreras | `1` (Administrador) |
| `carlos@ejemplo.com` | Carlos Pérez | `2` (General) |

Con la base de datos y la API activas, ejecuta la suite E2E desde `backend_API/`:

```bash
./venv/bin/python test_e2e_api.py
```

## Endpoints principales

| Método | Ruta | Acceso | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | Público | Estado del servicio |
| `POST` | `/login` | Público | Valida credenciales y emite `access_token` JWT (`401` si son inválidas) |
| `GET` | `/me` | Autenticado | Devuelve los datos públicos de la sesión JWT activa |
| `POST` | `/usuarios` | Público / Admin | Crea usuario General (`tip_usu = 2`); crear Admin (`tip_usu = 1`) exige JWT de Admin |
| `GET` | `/usuarios` | Solo Admin | Lista usuarios registrados |
| `PUT` | `/usuarios/{id}` | Propio / Admin | Actualiza perfil propio (sin cambiar rol) o cualquier cuenta como Admin |
| `DELETE` | `/usuarios/{id}` | Solo Admin | Elimina un usuario |
| `GET` | `/blog` | Autenticado | Lista publicaciones con `usr_id` y `autor` (filtro opcional `?solo_mios=true`) |
| `GET` | `/blog/{id}` | Autenticado | Obtiene una publicación por identificador |
| `POST` | `/blog` | Autenticado | Crea publicación asociada al usuario autenticado |
| `GET` | `/comentarios` | Autenticado | Lista comentarios con `autor` (filtro opcional `?blog_id=`) |
| `POST` | `/comentarios` | Autenticado | Crea comentario asociado al usuario autenticado |
| `GET` | `/productos` | Autenticado | Lista el catálogo de la tienda |
| `POST` | `/productos` | Solo Admin | Registra un producto nuevo |
| `POST` | `/pedidos` | Autenticado | Procesa compra con pago simulado, valida stock y tarjeta |
| `GET` | `/pedidos/usuario/{id}` | Propio / Admin | Consulta historial de pedidos del usuario |

### Tarjetas de prueba (pago simulado)

| Número | Resultado |
| :--- | :--- |
| `4242 4242 4242 4242` | Pago aprobado (`201`) |
| `4000 0000 0000 0002` | Pago rechazado por el banco (`402`) |

Usa cualquier fecha futura (por ejemplo `12/30`) y un CVV de 3 o 4 dígitos.
