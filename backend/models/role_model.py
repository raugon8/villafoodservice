from backend.database_manager.database import Base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime


class RoleModel(Base):
    """Roles disponibles en el sistema"""
    __tablename__ = "roles"

    role_id          = Column(Integer, primary_key=True, autoincrement=True)
    role_name        = Column(String(50), unique=True, nullable=False)
    role_description = Column(String(200), nullable=True)
    role_active      = Column(Boolean, default=True)
    role_action      = Column(Boolean, default=True)

    # Relation with users through intermediate table
    users = relationship("User", secondary="user_roles", back_populates="roles")


class UserRoleModel(Base):
    """Intermediate table for user-role assignments"""
    __tablename__ = "user_roles"

    user_role_id      = Column(Integer, primary_key=True, autoincrement=True)
    user_id           = Column(Integer, ForeignKey("usuarios.usuario_ID"), nullable=False)
    role_id           = Column(Integer, ForeignKey("roles.role_id"), nullable=False)
    roles_assignation = Column(DateTime, default=datetime.now)
    role_active       = Column(Boolean, default=True)