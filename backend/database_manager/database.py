import os
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from passlib.context import CryptContext

# 1. Configuración de la Variable de Entorno
# Usamos el nombre exacto que tienes en Railway
raw_db_url = os.getenv("Villafood_db")

if not raw_db_url:
    raise ValueError(
        "¡Error Crítico! No se detectó la variable 'Villafood_db'. "
        "Verifica que el nombre coincida exactamente en el panel de Railway."
    )

# 2. Fix de Protocolo para SQLAlchemy 1.4+
# Railway/Supabase usan 'postgres://', pero SQLAlchemy exige 'postgresql://'
if raw_db_url.startswith("postgres://"):
    SQLALCHEMY_DATABASE_URL = raw_db_url.replace("postgres://", "postgresql://", 1)
else:
    SQLALCHEMY_DATABASE_URL = raw_db_url

# 3. Motor optimizado para la nube
# pool_pre_ping=True evita errores de "conexión cerrada" tras periodos de inactividad
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Contexto de seguridad global
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def init_db():
    Base.metadata.create_all(bind=engine)


def migrate_db():
    """
    Migraciones estándar SQL. Comprueba la existencia de columnas
    consultando el esquema de información de Postgres.
    """
    migrations = [
        ("orders", "order_pickup_time", "ALTER TABLE orders ADD COLUMN order_pickup_time TIMESTAMP"),
        ("orders", "order_service", "ALTER TABLE orders ADD COLUMN order_service VARCHAR(20)"),
        ("orders", "order_staff_seen", "ALTER TABLE orders ADD COLUMN order_staff_seen BOOLEAN DEFAULT FALSE"),
        ("usuarios", "usuario_servicio", "ALTER TABLE usuarios ADD COLUMN usuario_servicio VARCHAR(20)"),
    ]

    with engine.connect() as conn:
        for table, column, sql in migrations:
            # Consulta optimizada: solo pedimos la columna que buscamos
            check_query = text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = :table AND column_name = :column
            """)

            result = conn.execute(check_query, {"table": table, "column": column}).fetchone()

            if not result:
                conn.execute(text(sql))
                print(f"Migración aplicada: {table}.{column}")
            else:
                print(f"Columna ya existente: {table}.{column}")

        _seed_roles(conn)
        _seed_root(conn)
        # Importante: confirmar cambios en el motor de Postgres
        conn.commit()


def _seed_roles(conn):
    """Inserta roles base usando booleanos nativos (TRUE)."""
    roles = [
        ('admin', 'Administrador total'),
        ('cliente', 'Cliente final'),
        ('dependiente', 'Gestión de pedidos'),
        ('almacen', 'Gestión de inventario'),
    ]
    for role_name, role_desc in roles:
        existing = conn.execute(
            text("SELECT role_id FROM roles WHERE role_name = :name"),
            {"name": role_name}
        ).fetchone()

        if not existing:
            conn.execute(
                text("""
                    INSERT INTO roles (role_name, role_description, role_active, role_action) 
                    VALUES (:name, :desc, TRUE, TRUE)
                """),
                {"name": role_name, "desc": role_desc}
            )


def _seed_root(conn):
    """Crea el usuario administrador inicial si no existe."""
    root_email = 'root@villafoodservice.com'
    existing = conn.execute(
        text("SELECT usuario_ID FROM usuarios WHERE correo = :email"),
        {"email": root_email}
    ).fetchone()

    if not existing:
        hashed_password = pwd_context.hash('VillaFood2024!')

        conn.execute(
            text("""
                INSERT INTO usuarios (nombre_usuario, correo, contraseña) 
                VALUES ('Root Admin', :email, :pwd)
            """),
            {"email": root_email, "pwd": hashed_password}
        )

        # Asignación de rol usando el nombre para evitar conflictos de ID
        conn.execute(text("""
            INSERT INTO user_roles (user_id, role_id, role_active)
            SELECT u.usuario_ID, r.role_id, TRUE
            FROM usuarios u, roles r
            WHERE u.correo = :email AND r.role_name = 'admin'
        """), {"email": root_email})

        print(f"Root configurado correctamente: {root_email}")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()