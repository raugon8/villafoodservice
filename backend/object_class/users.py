from pydantic import BaseModel, Field, validator
from typing import List, Optional


class UserWithRoles(BaseModel):
    """Roles activos del usuario.
    El frontend la usa tras el login para saber a qué pantallas tiene acceso."""
    user_id:     int
    user_name:   str
    user_email:  str
    roles:       List[str] = []
    user_active: bool = True

    class Config:
        from_attributes = True


class UserCreateAdmin(BaseModel):
    """Schema para que el admin cree un nuevo usuario con sus roles asignados. Se exige al menos un rol por usuario."""
    usuario_name:     str = Field(..., min_length=2)
    usuario_surname:  str = Field(default='', min_length=0)
    usuario_email:    str = Field(..., min_length=5)
    usuario_password: str = Field(..., min_length=6)
    roles:            List[str] = Field(..., min_length=1)

    @validator('roles')
    def validate_roles(cls, v):
        # Valida que todos los roles indicados existan en el sistema.
        valid = ['admin', 'cliente', 'dependiente', 'almacen']
        for role in v:
            if role not in valid:
                raise ValueError(f"Rol '{role}' no válido. Use: {valid}")
        return v


class UserUpdate(BaseModel):
    """Schema para que el admin actualice datos de un usuario.
    Todos los campos son opcionales para permitir actualizaciones parciales."""
    usuario_name:     Optional[str] = None
    usuario_surname:  Optional[str] = None
    usuario_email:    Optional[str] = None
    usuario_password: Optional[str] = None
    roles:            Optional[List[str]] = None
    usuario_active:   Optional[bool] = None