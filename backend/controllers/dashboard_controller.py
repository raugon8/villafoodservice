from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
from database_manager.database import get_db
from middleware.auth_middleware import RequireRole
from object_class.dashboard import DashboardResponse
from services import dashboard_service  # Servicio que hara Adan

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/stats", response_model=DashboardResponse)
@RequireRole(["admin"])
def GetDashboardStats(
        periodo: Optional[str] = Query(None, regex="^(hoy|semana|mes|6meses)$"),
        fecha_inicio: Optional[datetime] = None,
        fecha_fin: Optional[datetime] = None,
        user_id: int = Query(...),  # Requerido por el middleware
        current_role: str = Query(...),  # Requerido por el middleware
        db: Session = Depends(get_db)
):
    """Obtiene las estadisticas filtradas por tiempo para el admin"""

    start_date = fecha_inicio
    end_date = fecha_fin

    # Logica de filtros predefinidos
    if periodo:
        end_date = datetime.now()
        if periodo == "hoy":
            start_date = end_date.replace(hour=0, minute=0, second=0, microsecond=0)
        elif periodo == "semana":
            start_date = end_date - timedelta(days=7)
        elif periodo == "mes":
            start_date = end_date - timedelta(days=30)
        elif periodo == "6meses":
            start_date = end_date - timedelta(days=180)

    # Llama al servicio del coordinador para obtener los calculos
    return dashboard_service.obtener_estadisticas_dashboard(db, start_date, end_date)