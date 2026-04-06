from pydantic import BaseModel, Field, validator
from typing import List, Optional


# Función validadora reutilizable para contraseñas
def validar_fuerza_password(v: str) -> str:
    if v is None:
        return v
    if len(v) < 8:
        raise ValueError('La contraseña debe tener al menos 8 caracteres')
    if not any(char.isdigit() for char in v):
        raise ValueError('La contraseña debe contener al menos un número')
    if not any(char.isupper() for char in v):
        raise ValueError('La contraseña debe contener al menos una letra mayúscula')
    if not any(char.islower() for char in v):
        raise ValueError('La contraseña debe contener al menos una letra minúscula')
    return v


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
    usuario_password: str = Field(..., description="Mínimo 8 caracteres, una mayúscula, una minúscula y un número")
    roles:            List[str] = Field(..., min_length=1)

    @validator('usuario_password')
    def validate_password(cls, v):
        return validar_fuerza_password(v)

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

    @validator('usuario_password')
    def validate_password(cls, v):
        if v is not None:
            return validar_fuerza_password(v)
        return v