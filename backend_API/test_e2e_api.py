"""Pruebas E2E contra la API FastAPI conectada a MySQL.

Ejecutar con la API levantada en http://127.0.0.1:8000 (o API_BASE_URL):
    ./venv/bin/python test_e2e_api.py
"""

import json
import os
import time
import unittest
from urllib import error, request

BASE_URL = os.getenv("API_BASE_URL", "http://127.0.0.1:8000").rstrip("/")


def api_request(
    method: str,
    path: str,
    body: dict | None = None,
    token: str | None = None,
) -> tuple[int, dict | list | str]:
    headers = {"Accept": "application/json"}
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode("utf-8")
    if token is not None:
        headers["Authorization"] = f"Bearer {token}"

    req = request.Request(
        f"{BASE_URL}{path}",
        data=data,
        headers=headers,
        method=method,
    )
    try:
        with request.urlopen(req, timeout=10) as resp:
            raw = resp.read().decode("utf-8")
            return resp.status, json.loads(raw) if raw else {}
    except error.HTTPError as exc:
        try:
            raw = exc.read().decode("utf-8")
            try:
                payload = json.loads(raw) if raw else {}
            except json.JSONDecodeError:
                payload = raw
            return exc.code, payload
        finally:
            exc.close()


class TestRespawnE2E(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.sufijo = str(int(time.time()))
        cls.usuarios_creados: list[int] = []

        status, admin = api_request(
            "POST",
            "/login",
            {"mail": "adriana@ejemplo.com", "password": "12345678"},
        )
        assert status == 200, f"Login admin falló: {status} {admin}"
        cls.admin = admin
        cls.admin_token = admin["access_token"]

        status, general = api_request(
            "POST",
            "/login",
            {"mail": "carlos@ejemplo.com", "password": "12345678"},
        )
        assert status == 200, f"Login general falló: {status} {general}"
        cls.general = general
        cls.general_token = general["access_token"]

    @classmethod
    def tearDownClass(cls) -> None:
        for uid in cls.usuarios_creados:
            api_request("DELETE", f"/usuarios/{uid}", token=cls.admin_token)

    def test_01_salud_y_autenticacion(self) -> None:
        status, data = api_request("GET", "/")
        self.assertEqual(status, 200)
        self.assertIn("mensaje", data)

        self.assertEqual(self.admin["token_type"], "bearer")
        self.assertTrue(self.admin_token)

        status, _ = api_request(
            "POST",
            "/login",
            {"mail": "adriana@ejemplo.com", "password": "incorrecta"},
        )
        self.assertEqual(status, 401)

        status, me = api_request("GET", "/me", token=self.general_token)
        self.assertEqual(status, 200)
        self.assertEqual(me["id_usr"], self.general["id_usr"])

        status, _ = api_request("GET", "/me")
        self.assertEqual(status, 401)

        status, _ = api_request("GET", "/me", token="token.invalido.firmado")
        self.assertEqual(status, 401)

    def test_02_registro_y_garantia_de_roles(self) -> None:
        correo_pub = f"jugador_{self.sufijo}@ejemplo.com"
        status, creado = api_request(
            "POST",
            "/usuarios",
            {
                "nom_usr": "Jugador E2E",
                "mail": correo_pub,
                "password": "password123",
                "dir_usr": "Querétaro",
            },
        )
        self.assertEqual(status, 201, creado)
        self.assertEqual(creado["tip_usu"], 2)
        self.usuarios_creados.append(creado["id_usr"])

        # Registro público intentando asignar rol Administrador -> 403
        status, _ = api_request(
            "POST",
            "/usuarios",
            {
                "nom_usr": "Intento Admin Público",
                "mail": f"pub_admin_{self.sufijo}@ejemplo.com",
                "password": "password123",
                "tip_usu": 1,
            },
        )
        self.assertEqual(status, 403)

        # Usuario General intentando crear Administrador -> 403
        status, _ = api_request(
            "POST",
            "/usuarios",
            {
                "nom_usr": "Intento Admin General",
                "mail": f"gen_admin_{self.sufijo}@ejemplo.com",
                "password": "password123",
                "tip_usu": 1,
            },
            token=self.general_token,
        )
        self.assertEqual(status, 403)

        # Administrador creando otro Administrador -> 201
        status, admin_nuevo = api_request(
            "POST",
            "/usuarios",
            {
                "nom_usr": "Admin E2E",
                "mail": f"admin_e2e_{self.sufijo}@ejemplo.com",
                "password": "password123",
                "tip_usu": 1,
            },
            token=self.admin_token,
        )
        self.assertEqual(status, 201, admin_nuevo)
        self.assertEqual(admin_nuevo["tip_usu"], 1)
        self.usuarios_creados.append(admin_nuevo["id_usr"])

    def test_03_rbac_usuarios_y_perfil(self) -> None:
        # Sin token -> 401
        status, _ = api_request("GET", "/usuarios")
        self.assertEqual(status, 401)

        # General no puede listar ni eliminar usuarios -> 403
        status, _ = api_request("GET", "/usuarios", token=self.general_token)
        self.assertEqual(status, 403)

        status, _ = api_request(
            "DELETE",
            f"/usuarios/{self.admin['id_usr']}",
            token=self.general_token,
        )
        self.assertEqual(status, 403)

        # General no puede editar a otro usuario ni escalarse el rol -> 403
        status, _ = api_request(
            "PUT",
            f"/usuarios/{self.admin['id_usr']}",
            {
                "nom_usr": "Cambio ajeno",
                "mail": self.admin["mail"],
                "dir_usr": "Querétaro",
            },
            token=self.general_token,
        )
        self.assertEqual(status, 403)

        status, _ = api_request(
            "PUT",
            f"/usuarios/{self.general['id_usr']}",
            {
                "nom_usr": self.general["nom_usr"],
                "mail": self.general["mail"],
                "dir_usr": self.general["dir_usr"],
                "tip_usu": 1,
            },
            token=self.general_token,
        )
        self.assertEqual(status, 403)

        # General sí puede actualizar su propio perfil manteniendo tip_usu = 2
        status, actualizado = api_request(
            "PUT",
            f"/usuarios/{self.general['id_usr']}",
            {
                "nom_usr": self.general["nom_usr"],
                "mail": self.general["mail"],
                "dir_usr": "Querétaro",
            },
            token=self.general_token,
        )
        self.assertEqual(status, 200, actualizado)
        self.assertEqual(actualizado["tip_usu"], 2)

        # Admin sí puede listar usuarios
        status, usuarios = api_request("GET", "/usuarios", token=self.admin_token)
        self.assertEqual(status, 200)
        self.assertGreaterEqual(len(usuarios), 2)

    def test_04_blog_autoria_y_comentarios(self) -> None:
        # Sin token -> 401
        status, _ = api_request("GET", "/blog")
        self.assertEqual(status, 401)

        # Entradas iniciales tienen imagen y autoría repartida
        status, posts = api_request("GET", "/blog", token=self.general_token)
        self.assertEqual(status, 200)
        self.assertGreaterEqual(len(posts), 5)
        autores = {p["usr_id"] for p in posts}
        self.assertGreaterEqual(len(autores), 2)
        self.assertTrue(all(p.get("autor") for p in posts))
        semilla_blog = [p for p in posts if p["id_blog"] <= 5]
        self.assertEqual(len(semilla_blog), 5)
        self.assertTrue(all(p.get("img") for p in semilla_blog))

        # Usuario General crea publicación propia (usr_id asignado desde JWT)
        status, nuevo_post = api_request(
            "POST",
            "/blog",
            {
                "titulo": f"Guía comunitaria {self.sufijo}",
                "descripcion": "Publicación creada por usuario general en prueba E2E.",
                "tags": "Comunidad, E2E",
            },
            token=self.general_token,
        )
        self.assertEqual(status, 201, nuevo_post)
        self.assertEqual(nuevo_post["usr_id"], self.general["id_usr"])
        self.assertEqual(nuevo_post["autor"], self.general["nom_usr"])

        # Filtro solo_mios=true devuelve solo entradas del usuario actual
        status, mios = api_request(
            "GET",
            "/blog?solo_mios=true",
            token=self.general_token,
        )
        self.assertEqual(status, 200)
        self.assertTrue(all(p["usr_id"] == self.general["id_usr"] for p in mios))
        self.assertTrue(any(p["id_blog"] == nuevo_post["id_blog"] for p in mios))

        # Comentario asociado al JWT y consultado por blog_id con autor
        status, nuevo_com = api_request(
            "POST",
            "/comentarios",
            {
                "comentario": "Excelente aporte comunitario",
                "blog_id": nuevo_post["id_blog"],
            },
            token=self.admin_token,
        )
        self.assertEqual(status, 201, nuevo_com)
        self.assertEqual(nuevo_com["usr_id"], self.admin["id_usr"])
        self.assertEqual(nuevo_com["autor"], self.admin["nom_usr"])

        status, comentarios = api_request(
            "GET",
            f"/comentarios?blog_id={nuevo_post['id_blog']}",
            token=self.general_token,
        )
        self.assertEqual(status, 200)
        self.assertEqual(len(comentarios), 1)
        self.assertEqual(comentarios[0]["autor"], self.admin["nom_usr"])

    def test_05_tienda_rbac_y_pagos(self) -> None:
        # Catálogo con imágenes cargadas
        status, productos = api_request("GET", "/productos", token=self.general_token)
        self.assertEqual(status, 200)
        self.assertGreaterEqual(len(productos), 8)
        semilla_productos = [p for p in productos if p["id_prod"] <= 8]
        self.assertEqual(len(semilla_productos), 8)
        self.assertTrue(all(p.get("img") for p in semilla_productos))

        # General no puede dar de alta productos -> 403
        status, _ = api_request(
            "POST",
            "/productos",
            {"nombre": "No permitido", "precio": 100.0, "stock": 5},
            token=self.general_token,
        )
        self.assertEqual(status, 403)

        # Admin sí puede crear producto -> 201
        status, prod_nuevo = api_request(
            "POST",
            "/productos",
            {
                "nombre": f"Cable trenzado {self.sufijo}",
                "descripcion": "Producto de prueba E2E",
                "precio": 199.0,
                "stock": 5,
            },
            token=self.admin_token,
        )
        self.assertEqual(status, 201, prod_nuevo)

        # Pago rechazado -> 402
        status, _ = api_request(
            "POST",
            "/pedidos",
            {
                "items": [{"prod_id": prod_nuevo["id_prod"], "cantidad": 1}],
                "pago": {
                    "titular": "Carlos Perez",
                    "numero": "4000 0000 0000 0002",
                    "vencimiento": "12/30",
                    "cvv": "123",
                },
            },
            token=self.general_token,
        )
        self.assertEqual(status, 402)

        # Pago aprobado -> 201 y stock descontado
        status, pedido = api_request(
            "POST",
            "/pedidos",
            {
                "items": [{"prod_id": prod_nuevo["id_prod"], "cantidad": 2}],
                "pago": {
                    "titular": "Carlos Perez",
                    "numero": "4242 4242 4242 4242",
                    "vencimiento": "12/30",
                    "cvv": "123",
                },
            },
            token=self.general_token,
        )
        self.assertEqual(status, 201, pedido)
        self.assertEqual(pedido["ultimos4"], "4242")
        self.assertEqual(pedido["total"], 398.0)

        # Historial propio permitido -> 200; historial ajeno bloqueado -> 403
        status, mis_pedidos = api_request(
            "GET",
            f"/pedidos/usuario/{self.general['id_usr']}",
            token=self.general_token,
        )
        self.assertEqual(status, 200)
        self.assertTrue(any(p["id_ped"] == pedido["id_ped"] for p in mis_pedidos))

        status, _ = api_request(
            "GET",
            f"/pedidos/usuario/{self.admin['id_usr']}",
            token=self.general_token,
        )
        self.assertEqual(status, 403)


if __name__ == "__main__":
    unittest.main(verbosity=2)
