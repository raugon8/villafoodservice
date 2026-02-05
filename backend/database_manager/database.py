from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Definimos el nombre y lugar del archivo de base de datos
SQLALCHEMY_DATABASE_URL = "sqlite:///./backend/villafood.db"

#  Creamos el motor de la base de datos
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

#  Creamos la herramienta para abrir y cerrar sesiones
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

#  Base para crear modelos
Base = declarative_base()

# Función para crear las tablas si no existen
def init_db():
    Base.metadata.create_all(bind=engine)