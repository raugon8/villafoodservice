from backend.database_manager.database import engine
from sqlalchemy import text

with engine.connect() as conn:
    conn.execute(text("DELETE FROM user_roles WHERE user_id = (SELECT usuario_ID FROM usuarios WHERE correo = 'root@villafoodservice.com')"))
    conn.execute(text("DELETE FROM usuarios WHERE correo = 'root@villafoodservice.com'"))
    conn.commit()
    print('Root eliminado correctamente')