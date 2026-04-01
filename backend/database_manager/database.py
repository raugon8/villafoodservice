from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./backend/villafood.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def init_db():
    Base.metadata.create_all(bind=engine)

def migrate_db():
    """Adds new columns to existing tables without losing data."""
    migrations = [
        # Tarea 6
        ("orders",   "order_pickup_time", "ALTER TABLE orders ADD COLUMN order_pickup_time TIMESTAMP"),
        ("orders",   "order_service",     "ALTER TABLE orders ADD COLUMN order_service VARCHAR(20)"),
        ("orders",   "order_staff_seen",  "ALTER TABLE orders ADD COLUMN order_staff_seen BOOLEAN DEFAULT 0"),
        ("usuarios", "usuario_servicio",  "ALTER TABLE usuarios ADD COLUMN usuario_servicio VARCHAR(20)"),
        # Tarea 15
        ("products", "image_url",         "ALTER TABLE products ADD COLUMN image_url VARCHAR(255)"),
    ]

    with engine.connect() as conn:
        for table, column, sql in migrations:
            result = conn.execute(text(f"PRAGMA table_info({table})"))
            existing_columns = [row[1] for row in result.fetchall()]
            if column not in existing_columns:
                conn.execute(text(sql))
                print(f"Migration applied: {table}.{column}")
            else:
                print(f"Already exists, skipping: {table}.{column}")

        _seed_roles(conn)
        _seed_root(conn)
        _seed_alergenos(conn)  # Nuevo seed de sistema
        conn.commit()

def _seed_roles(conn):
    """Insert base roles if they don't exist yet"""
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
            print(f"Role seeded: {role_name}")

def _seed_root(conn):
    """Insert Root admin user if not exists"""
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
        conn.execute(text("""
            INSERT INTO user_roles (user_id, role_id, role_active)
            SELECT u.usuario_ID, r.role_id, 1
            FROM usuarios u, roles r
            WHERE u.correo = 'root@villafoodservice.com'
            AND r.role_name = 'admin'
        """))
        print("Root user seeded: root@villafoodservice.com / VillaFood2024!")
    else:
        print("Already exists, skipping: root user")

def _seed_alergenos(conn):
    """Insert official EU allergens if they don't exist yet"""
    alergenos_ue = [
        (1, 'Gluten'), (2, 'Crustáceos'), (3, 'Huevo'), (4, 'Pescado'),
        (5, 'Cacahuetes'), (6, 'Soja'), (7, 'Lácteos'), (8, 'Frutos de cáscara'),
        (9, 'Apio'), (10, 'Mostaza'), (11, 'Sésamo'), (12, 'Dióxido de azufre y sulfitos'),
        (13, 'Altramuces'), (14, 'Moluscos')
    ]
    for a_id, a_nombre in alergenos_ue:
        existing = conn.execute(
            text("SELECT alergeno_id FROM alergenos WHERE alergeno_id = :id"),
            {"id": a_id}
        ).fetchone()
        if not existing:
            conn.execute(
                text("INSERT INTO alergenos (alergeno_id, nombre) VALUES (:id, :name)"),
                {"id": a_id, "name": a_nombre}
            )
            print(f"Allergen seeded: {a_nombre}")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()