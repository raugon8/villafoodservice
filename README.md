# 🧑‍🍳 VillaFood Service

Sistema integral de gestión de servicios de alimentación para centros educativos. Unifica las operaciones de cafetería, restaurante y repostería en una única plataforma multiplataforma, optimizando el flujo desde que el cliente hace el pedido hasta que se entrega, controlando el inventario en tiempo real.

---

## 🚀 Stack Técnico

* **Backend:** Python + FastAPI *(Alojado en Railway)*
* **Base de Datos:** PostgreSQL *(Alojado en Supabase)* + SQLAlchemy
* **Frontend:** Flutter *(Compatible con Web Desktop/Mobile y App Android APK)*
* **Estado y UI:** `Provider`, Navegación nativa, Soporte para Modo Claro/Oscuro dinámico y Multi-idioma (ES/EN).

---

## 🌐 Despliegue

* **Backend:** Desplegado en **Railway** — arranca automáticamente con cada push a `main`.
* **Base de Datos:** Gestionada en **Supabase** (PostgreSQL).
* **Frontend:** Build web estático desplegado en **Netlify** / GitHub Pages.

---

## 📦 Datos de Demostración (Seed)

Al arrancar el backend por primera vez con una base de datos vacía, el sistema ejecuta un script de *semilla* automático que inserta:

* **3 Servicios:** Cafetería, Restaurante, Repostería.
* **8 Categorías** distribuidas entre los servicios.
* **9 Ingredientes** con stock inicial.
* **12 Productos** base listos para ser consumidos.
* **14 Alérgenos** europeos de declaración obligatoria.

> **Nota:** Ejecutar el servidor una segunda vez no duplica estos datos, el sistema verifica su existencia.

---

## 🔔 Notificaciones de Estado de Pedido

La aplicación informa al cliente cuando su pedido cambia de estado (`En preparación` / `Listo` / `Cancelado`):

* **En primer plano (Foreground):** Se realiza un *polling* ligero al servidor cada 15 segundos para mantener la interfaz actualizada en tiempo real.
* **En segundo plano (Background - Android):** Utiliza `workmanager` para revisar el estado periódicamente.

> **Limitación en iOS / Web:** Las notificaciones en background puro pueden verse limitadas por las restricciones del sistema operativo de Apple. En Web, la sincronización automática solo ocurre mientras la pestaña permanezca activa.

---

## 🏗️ Estructura del Proyecto

El proyecto está dividido en dos grandes bloques para separar la lógica de negocio de la interfaz de usuario:

### 📱 Frontend (Flutter)
La arquitectura del cliente se basa en la separación por funcionalidades y roles:

```text
frontend/lib/
├── config/               // Constantes globales y URLs base de la API.
├── l10n/                 // Archivos de internacionalización (traducciones ES/EN).
├── models/               // Modelos de datos (Producto, User, Order, CartManager...).
├── providers/            // Gestión de estado global (Auth, Theme, Locale, Scale).
├── screens/              // Vistas de la app agrupadas por contexto de usuario:
│   ├── admin/            // Dashboard, gestión de usuarios y categorías.
│   ├── screens_auth/     // Login, registro y selector de roles.
│   ├── screens_client/   // Catálogo, carrito, detalle de producto e historial.
│   ├── screens_staff/    // Panel de gestión de pedidos en tiempo real.
│   └── screens_ingredientes/ // Gestión de stock para el rol de almacén.
├── services/             // Clases que gestionan las peticiones HTTP al backend.
├── theme/                // Definición visual y paletas de colores (AppTheme).
└── widgets/              // Componentes visuales reutilizables.
```

### ⚙️ Backend (FastAPI)
```text
backend/
├── main_class/           // Punto de entrada de la API (main.py).
├── routers/              // Controladores/Endpoints (auth, pedidos, productos).
├── services/             // Lógica de negocio pura (validaciones, cálculos).
├── models/               // Modelos de base de datos (SQLAlchemy).
├── object_class/         // Esquemas de validación de datos (Pydantic).
├── middleware/           // Verificación de JWT y control de acceso por roles.
└── database_manager/     // Configuración y conexión con Supabase.
```

---

## 🔄 Flujo de la Aplicación

El sistema está diseñado en torno a un sistema de control de acceso basado en roles (**RBAC**). El flujo principal es el siguiente:

1. **Autenticación Segura:** El usuario inicia sesión y el backend emite un token `JWT` firmado. Si el usuario posee múltiples roles, la app le presenta un **Selector de Rol** para decidir con qué privilegios entrar en esa sesión.

2. **Catálogo Dinámico (Cliente):** El usuario navega por un catálogo responsive. Puede filtrar por servicios *(Cafetería, Restaurante, etc)*, buscar productos y ver advertencias de alérgenos.

3. **Gestión de Carrito y Validación:** Al intentar realizar un pedido, el frontend envía el carrito al backend. FastAPI cruza los productos solicitados con la receta de cada producto y verifica en tiempo real si hay *Stock de Ingredientes* suficiente.

4. **Recepción de Pedidos (Staff):** Si el pedido se aprueba, se descuenta el stock automáticamente. El pedido aparece instantáneamente en el panel del dependiente, marcado como **"Nuevo"**.

5. **Flujo de Preparación:** El dependiente avanza el estado del ticket: `Pendiente` ➔ `En Preparación` ➔ `Listo` | `Cancelado`.

6. **Historial y Cancelaciones:** Los clientes pueden ver su historial, repetir pedidos pasados (el sistema ignora productos que ya no tengan stock) y leer las notas si el personal tuvo que cancelar un pedido, restituyendo automáticamente el stock.
