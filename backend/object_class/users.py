"""
Users - Pydantic schemas
backend/object_class/users.py
"""
from pydantic import BaseModel, Field, validator
from typing import List, Optional


class UserWithRoles(BaseModel):
    """User response including active roles"""
    user_id:     int
    user_name:   str
    user_email:  str
    roles:       List[str] = []
    user_active: bool = True

    class Config:
        from_attributes = True


class UserCreateAdmin(BaseModel):
    """Schema for admin to create new users"""
    usuario_name:     str = Field(..., min_length=2)
    usuario_surname:  str = Field(default='', min_length=0)
    usuario_email:    str = Field(..., min_length=5)
    usuario_password: str = Field(..., min_length=6)
    roles:            List[str] = Field(..., min_length=1)

    @validator('roles')
    def validate_roles(cls, v):
        valid = ['admin', 'cliente', 'dependiente', 'almacen']
        for role in v:
            if role not in valid:
                raise ValueError(f"Rol '{role}' no válido. Use: {valid}")
        return v


class UserUpdate(BaseModel):
    """Schema for admin to update user data"""
    usuario_name:     Optional[str] = None
    usuario_surname:  Optional[str] = None
    usuario_email:    Optional[str] = None
    usuario_password: Optional[str] = None
    roles:            Optional[List[str]] = None
    usuario_active:   Optional[bool] = None