to start back use
Open your Windows Start menu and search for Docker Desktop.
Launch the application.
Wait a few moments until you see the engine is fully started (the Docker icon in your system tray will stop animating and indicate "Engine running").
**
Start Redis: 
docker-compose up redis -d
Start Celery worker:
.\.venv\Scripts\celery -A app.celery_app worker --loglevel=info --pool=solo

**
use another terminal 

uvicorn app.main:app --reload
