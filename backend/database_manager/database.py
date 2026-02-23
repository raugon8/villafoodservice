from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Definimos el nombre y lugar del archivo de base de datos
SQLALCHEMY_DATABASE_URL = "sqlite:///./backend/villafood.db"

# Creamos el motor de la base de datos
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Creamos la herramienta para abrir y cerrar sesiones
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para crear modelos
Base = declarative_base()

# Función para crear las tablas si no existen
def init_db():
    Base.metadata.create_all(bind=engine)

# Función para aplicar migraciones incrementales
def migrate_db():
    """Adds new columns to existing tables without losing data."""
    migrations = [
        ("orders",   "order_pickup_time", "ALTER TABLE orders ADD COLUMN order_pickup_time TIMESTAMP"),
        ("orders",   "order_service",     "ALTER TABLE orders ADD COLUMN order_service VARCHAR(20)"),
        ("orders",   "order_staff_seen",  "ALTER TABLE orders ADD COLUMN order_staff_seen BOOLEAN DEFAULT 0"),
        ("usuarios", "usuario_servicio",  "ALTER TABLE usuarios ADD COLUMN usuario_servicio VARCHAR(20)"),
    ]

    with engine.connect() as conn:
        for table, column, sql in migrations:
            # Check if column already exists before adding
            result = conn.execute(text(f"PRAGMA table_info({table})"))
            existing_columns = [row[1] for row in result.fetchall()]
            if column not in existing_columns:
                conn.execute(text(sql))
                print(f"Migration applied: {table}.{column}")
            else:
                print(f"Already exists, skipping: {table}.{column}")
        conn.commit()

# Función para obtener sesión de BD (dependency de FastAPI)
def get_db():
    """
    Dependency que proporciona una sesión de base de datos.
    Se cierra automáticamente al terminar la request.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()