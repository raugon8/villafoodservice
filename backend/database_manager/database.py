import os
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 1. Leer la URL desde las variables de entorno
SQLALCHEMY_DATABASE_URL = os.getenv("Villafood_db")

# Validación de seguridad: avisa si no detecta la variable
if not SQLALCHEMY_DATABASE_URL:
    raise ValueError("¡Error! No se ha encontrado la variable de entorno DATABASE_URL.")

# 2. Configurar el motor exclusivo para PostgreSQL
engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def init_db():
    Base.metadata.create_all(bind=engine)


def migrate_db():
    migrations = [
        ("orders", "order_pickup_time", "ALTER TABLE orders ADD COLUMN order_pickup_time TIMESTAMP"),
        ("orders", "order_service", "ALTER TABLE orders ADD COLUMN order_service VARCHAR(20)"),
        ("orders", "order_staff_seen", "ALTER TABLE orders ADD COLUMN order_staff_seen BOOLEAN DEFAULT FALSE"),
        ("usuarios", "usuario_servicio", "ALTER TABLE usuarios ADD COLUMN usuario_servicio VARCHAR(20)"),
    ]

    with engine.connect() as conn:
        for table, column, sql in migrations:

            # 3. Consulta estándar de PostgreSQL para comprobar si la columna ya existe
            result = conn.execute(
                text(f"SELECT column_name FROM information_schema.columns WHERE table_name='{table}'"))
            existing_columns = [row[0] for row in result.fetchall()]

            if column not in existing_columns:
                conn.execute(text(sql))
                print(f"Migración aplicada: {table}.{column}")
            else:
                print(f"Ya existe, omitiendo: {table}.{column}")

        _seed_roles(conn)
        _seed_root(conn)
        conn.commit()


def _seed_roles(conn):
    roles = [
        ('admin', 'Administrador del sistema con acceso total'),
        ('cliente', 'Cliente que puede hacer pedidos'),
        ('dependiente', 'Personal que gestiona pedidos'),
        ('almacen', 'Personal que gestiona stock'),
    ]
    for role_name, role_desc in roles:
        existing = conn.execute(
            text("SELECT role_id FROM roles WHERE role_name = :name"),
            {"name": role_name}
        ).fetchone()
        if not existing:
            conn.execute(
                text(
                    "INSERT INTO roles (role_name, role_description, role_active, role_action) VALUES (:name, :desc, TRUE, TRUE)"),
                {"name": role_name, "desc": role_desc}
            )
            print(f"Rol creado: {role_name}")


def _seed_root(conn):
    existing = conn.execute(
        text("SELECT usuario_ID FROM usuarios WHERE correo = 'root@villafoodservice.com'")
    ).fetchone()
    if not existing:
        from passlib.context import CryptContext
        hashed = CryptContext(schemes=["bcrypt"], deprecated="auto").hash('VillaFood2024!')
        conn.execute(
            text(
                "INSERT INTO usuarios (nombre_usuario, correo, contraseña) VALUES ('Root Admin', 'root@villafoodservice.com', :pwd)"),
            {"pwd": hashed}
        )
        conn.execute(text("""
            INSERT INTO user_roles (user_id, role_id, role_active)
            SELECT u.usuario_ID, r.role_id, TRUE
            FROM usuarios u, roles r
            WHERE u.correo = 'root@villafoodservice.com'
            AND r.role_name = 'admin'
        """))
        print("Usuario root creado: root@villafoodservice.com / VillaFood2024!")
    else:
        print("Ya existe, omitiendo: usuario root")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()