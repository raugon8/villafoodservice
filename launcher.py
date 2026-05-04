# Punto de entrada del ejecutable. Arranca el servidor y abre el navegador automáticamente.
import threading
import webbrowser
import time
import uvicorn
from main import app

PORT = 8000

def abrir_navegador():
    # Espera a que el servidor esté listo antes de abrir el navegador
    time.sleep(2)
    webbrowser.open(f"http://localhost:{PORT}")

if __name__ == "__main__":
    # Abre el navegador en un hilo separado para no bloquear el servidor
    threading.Thread(target=abrir_navegador, daemon=True).start()
    # log_config=None desactiva el logging de uvicorn (necesario al ejecutar sin consola)
    uvicorn.run(app, host="0.0.0.0", port=PORT, workers=1, log_config=None)