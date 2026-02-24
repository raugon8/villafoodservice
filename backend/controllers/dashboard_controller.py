from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
from backend.database_manager.database import get_db
from backend.middleware.auth_middleware import RequireRole
from backend.object_class.dashboard import DashboardResponse
from backend.services import dashboard_service

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/stats", response_model=DashboardResponse)
def GetDashboardStats(
    periodo: Optional[str] = Query(None),
    fecha_inicio: Optional[datetime] = None,
    fecha_fin: Optional[datetime] = None,
    user_id: int = Query(...),
    current_role: str = Query(...),
    db: Session = Depends(get_db)
):
    """Obtiene las estadisticas filtradas por tiempo para el admin"""
    RequireRole(["admin"])
    start_date = fecha_inicio
    end_date = fecha_fin

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

    return dashboard_service.obtener_estadisticas_dashboard(db, start_date, end_date)