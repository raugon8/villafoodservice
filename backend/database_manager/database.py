from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# URL de conexión a la base de datos local.
SQLALCHEMY_DATABASE_URL = "sqlite:///./backend/villafood.db"

# Motor de conexión a la base de datos. check_same_thread=False es necesario para que SQLite funcione con FastAPI y pueda tener múltiples hilos.
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Sessionmaker: cada petición al backend abre una sesión independiente.
# autocommit=False: los cambios no se guardan hasta llamar a db.commit().
# autoflush=False: los cambios no se envían a la BD hasta que se indique.
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Clase base de la que heredan todos los modelos SQLAlchemy del proyecto.
Base = declarative_base()


def init_db():
    # Crea todas las tablas definidas en los modelos si no existen todavía.
    # Si las tablas ya existen, no altera nada.
    Base.metadata.create_all(bind=engine)


def migrate_db():
    # Añade columnas nuevas a tablas ya existentes sin perder datos.
    migrations = [
        ("orders",   "order_pickup_time", "ALTER TABLE orders ADD COLUMN order_pickup_time TIMESTAMP"),
        ("orders",   "order_service",     "ALTER TABLE orders ADD COLUMN order_service VARCHAR(20)"),
        ("orders",   "order_staff_seen",  "ALTER TABLE orders ADD COLUMN order_staff_seen BOOLEAN DEFAULT 0"),
        ("usuarios", "usuario_servicio",  "ALTER TABLE usuarios ADD COLUMN usuario_servicio VARCHAR(20)"),
    ]

    with engine.connect() as conn:
        for table, column, sql in migrations:

            # PRAGMA table_info devuelve las columnas actuales de la tabla
            result = conn.execute(text(f"PRAGMA table_info({table})"))

            existing_columns = [row[1] for row in result.fetchall()]
            if column not in existing_columns:
                conn.execute(text(sql))
                print(f"Migración aplicada: {table}.{column}")
            else:
                print(f"Ya existe, omitiendo: {table}.{column}")

        _seed_roles(conn)
        _seed_root(conn)
        conn.commit()


def _seed_roles(conn):
    # Función interna, solo debe llamarse desde migrate_db().
    # Inserta los cuatro roles base del sistema si no existen todavía.
    roles = [
        ('admin',       'Administrador del sistema con acceso total'),
        ('cliente',     'Cliente que puede hacer pedidos'),
        ('dependiente', 'Personal que gestiona pedidos'),
        ('almacen',     'Personal que gestiona stock'),
    ]
    for role_name, role_desc in roles:
        existing = conn.execute(
            text("SELECT role_id FROM roles WHERE role_name = :name"),
            {"name": role_name}
        ).fetchone()
        if not existing:
            conn.execute(
                text("INSERT INTO roles (role_name, role_description, role_active, role_action) VALUES (:name, :desc, 1, 1)"),
                {"name": role_name, "desc": role_desc}
            )
            print(f"Rol creado: {role_name}")


def _seed_root(conn):
    # Función interna, solo debe llamarse desde migrate_db().
    # Crea el usuario administrador raíz del sistema si no existe.
    existing = conn.execute(
        text("SELECT usuario_ID FROM usuarios WHERE correo = 'root@villafoodservice.com'")
    ).fetchone()
    if not existing:
        from passlib.context import CryptContext
        hashed = CryptContext(schemes=["bcrypt"], deprecated="auto").hash('VillaFood2024!')
        conn.execute(
            text("INSERT INTO usuarios (nombre_usuario, correo, contraseña) VALUES ('Root Admin', 'root@villafoodservice.com', :pwd)"),
            {"pwd": hashed}
        )
        # Uso una subquery para obtener los IDs
        conn.execute(text("""
            INSERT INTO user_roles (user_id, role_id, role_active)
            SELECT u.usuario_ID, r.role_id, 1
            FROM usuarios u, roles r
            WHERE u.correo = 'root@villafoodservice.com'
            AND r.role_name = 'admin'
        """))
        print("Usuario root creado: root@villafoodservice.com / VillaFood2024!")
    else:
        print("Ya existe, omitiendo: usuario root")


def get_db():
    # Generador que proporciona una sesión de BD a cada endpoint.
    # Uso yield para que al terminar la petición, se cierre la sesión en finally.
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()