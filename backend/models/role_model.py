from backend.database_manager.database import Base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime


class RoleModel(Base):
    """Roles disponibles en el sistema: admin, cliente, dependiente, almacen."""
    __tablename__ = "roles"

    role_id          = Column(Integer, primary_key=True, autoincrement=True)
    role_name        = Column(String(50), unique=True, nullable=False)
    role_description = Column(String(200), nullable=True)
    # Soft delete a nivel de sistema: Si es False, ningún usuario puede tener este rol.
    role_active      = Column(Boolean, default=True)
    role_action      = Column(Boolean, default=True)

    # Relación con usuarios a través de la tabla intermedia user_roles.
    users = relationship("User", secondary="user_roles", back_populates="roles")


class UserRoleModel(Base):
    """Tabla intermedia que asigna roles a usuarios.
    Un usuario puede tener varios roles simultáneamente."""
    __tablename__ = "user_roles"

    user_role_id      = Column(Integer, primary_key=True, autoincrement=True)
    user_id           = Column(Integer, ForeignKey("usuarios.usuario_id"), nullable=False)
    role_id           = Column(Integer, ForeignKey("roles.role_id"), nullable=False)
    # Fecha en que se asignó el rol al usuario.
    roles_assignation = Column(DateTime, default=datetime.now)
    # Soft delete a nivel de usuario: Si es False, el usuario ya no tiene ese rol activo.
    role_active       = Column(Boolean, default=True)