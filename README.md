# VillaFoodService

Sistema de gestión de servicios de alimentación para un centro educativo. Unifica cafetería, restaurante y repostería en una única plataforma de pedidos.

## Stack técnico

- **Backend:** FastAPI + Python (Railway)
- **Base de datos:** PostgreSQL (Supabase)
- **Frontend:** Flutter (web + APK)

## Arrancar en local

**Backend:**
```bash
cd backend
.venv\Scripts\Activate.ps1
uvicorn main_class.main:app --reload
```

**Frontend:**
```bash
cd frontend
flutter run -d chrome
```

## Usuarios de prueba / Demo

El sistema crea automáticamente los siguientes usuarios la primera vez que arranca con la base de datos vacía.

| Rol         | Usuario            | Contraseña   |
|-------------|--------------------|--------------|
| Admin       | root               | root1234     |
| Cliente     | cliente_prueba     | cliente1234  |
| Dependiente | dependiente_prueba | dep1234      |
| Almacén     | almacen_prueba     | almacen1234  |

> El seed se ejecuta automáticamente al arrancar el servidor si la base de datos está vacía. Ejecutarlo una segunda vez no duplica datos.

## Datos de demostración

Al arrancar por primera vez se insertan automáticamente:
- 3 servicios: Cafetería, Restaurante, Repostería
- 8 categorías distribuidas entre los servicios
- 8 ingredientes con stock inicial
- 12 productos listos para pedir

## Build de Flutter Web

Para compilar la app web apuntando al backend de producción:

```bash
flutter build web --release \
  --dart-define=API_URL=https://<proyecto>.railway.app \
  --dart-define=SUPABASE_URL=https://tvflsjhtybzwbqxciciv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable_key>
```

> Sustituir `<proyecto>` por la URL del backend en Railway y `<publishable_key>` por la clave publicable de Supabase. Ninguna de estas claves debe subirse al repositorio.

## Notificaciones de estado de pedido

La app notifica al cliente cuando su pedido cambia a "En preparación" o "Listo" mediante polling cada 15 segundos (app en primer plano) y workmanager cada 15 minutos (app en background en Android).

**Limitación en iOS:** las notificaciones en background pueden no funcionar de forma consistente en iOS debido a las restricciones del sistema operativo de Apple. En Android el comportamiento es el esperado.

En web, el polling solo funciona mientras la app está abierta en el navegador.