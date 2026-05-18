@echo off
chcp 65001 >nul 2>&1
title GenUI Project Launcher
color 0A

:: -- Always run from the script's own directory --
cd /d "%~dp0"

:menu
cls
echo ===================================================
echo            GenUI Project Launcher
echo ===================================================
echo.
echo  [1] Docker - Full Stack (Frontend + Backend + Redis)
echo  [2] Docker - Backend only (API + Redis + Celery)
echo  [3] Local Dev (Python venv + Flutter)
echo  [4] Stop all Docker services
echo  [5] View Docker logs
echo  [6] Exit
echo.
set /p "choice=Enter your choice (1-6): "

if "%choice%"=="1" goto docker_full
if "%choice%"=="2" goto docker_backend
if "%choice%"=="3" goto local
if "%choice%"=="4" goto docker_stop
if "%choice%"=="5" goto docker_logs
if "%choice%"=="6" goto quit

echo.
echo [ERROR] Invalid choice "%choice%". Please enter 1-6.
pause
goto menu

:: ================================================================
::  CHECK DOCKER IS RUNNING
:: ================================================================
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker is not running!
    echo.
    echo Please start Docker Desktop first, then try again.
    echo.
    pause
    goto menu
)
goto :eof

:: ================================================================
::  SETUP .ENV (only needs OPENROUTER_API_KEY)
:: ================================================================
:setup_env
if exist ".env" (
    echo [OK] .env file found.
    goto :eof
)

echo.
echo ===================================================
echo   First-time setup: Creating .env file
echo ===================================================
echo.
echo You only need ONE API key: your OpenRouter key.
echo (Embeddings run locally - no Google API key needed!)
echo.

:: -- Prompt for OpenRouter key --
set "OPENROUTER_KEY="
set /p "OPENROUTER_KEY=Enter your OPENROUTER_API_KEY: "
if "%OPENROUTER_KEY%"=="" set "OPENROUTER_KEY=sk-or-v1-paste-your-key-here"

:: -- Write the .env file --
(
echo # GenUI Environment - Auto-generated
echo.
echo APP_ENV=development
echo APP_PORT=8000
echo FRONTEND_PORT=80
echo DEBUG=true
echo SECRET_KEY=change-me-in-production
echo.
echo OPENROUTER_API_KEY=%OPENROUTER_KEY%
echo OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
echo OPENROUTER_MODEL=google/gemini-2.5-flash
echo OPENROUTER_APP_TITLE=f-idarty
echo.
echo FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
echo.
echo CHROMA_PERSIST_DIRECTORY=./chroma_data
echo CHROMA_COLLECTION_NAME=fberaucracy_procedures
echo.
echo REDIS_URL=redis://localhost:6379/0
echo CACHE_TTL_SECONDS=86400
echo CACHE_ENABLED=true
echo.
echo ALLOWED_ORIGINS=http://localhost,http://localhost:80,http://localhost:3000
) > ".env"

echo.
echo [OK] .env file created!
echo.
goto :eof

:: ================================================================
::  CHECK FIREBASE FILE
:: ================================================================
:check_firebase
if not exist "backend\firebase-service-account.json" (
    echo.
    echo [WARNING] backend\firebase-service-account.json not found!
    echo Firebase authentication will not work without it.
    echo.
    set /p "cont=Continue anyway? (y/n): "
    if /i not "%cont%"=="y" goto menu
)
goto :eof

:: ================================================================
::  DOCKER FULL STACK
:: ================================================================
:docker_full
echo.
call :check_docker
call :setup_env
call :check_firebase

echo.
echo -- Building and Starting All Services ---------------------------------
echo    Services: Redis, Backend API, Celery Worker, Frontend (Nginx)
echo    This may take a few minutes on first build...
echo.
docker compose up -d --build
if errorlevel 1 (
    echo.
    echo [ERROR] Docker Compose failed!
    echo.
    echo Common fixes:
    echo   - Is Docker Desktop running?
    echo   - Is port 80 or 8000 already in use?
    echo   - Try: docker compose down   then re-run
    echo.
    pause
    goto menu
)

echo.
echo -- Waiting for services to be healthy ---------------------------------
timeout /t 10 /nobreak >nul

echo.
echo ===================================================
echo   All services started!
echo.
echo   Frontend:  http://localhost:80
echo   Backend:   http://localhost:8000
echo   API Docs:  http://localhost:8000/docs
echo   Health:    http://localhost:8000/health
echo.
echo   Use option [5] to view live logs.
echo ===================================================
echo.
set /p "openbrowser=Open frontend in browser? (y/n): "
if /i "%openbrowser%"=="y" start http://localhost:80
pause
goto menu

:: ================================================================
::  DOCKER BACKEND ONLY
:: ================================================================
:docker_backend
echo.
call :check_docker
call :setup_env
call :check_firebase

echo.
echo -- Starting Backend Services Only -------------------------------------
docker compose up -d --build redis api celery_worker
if errorlevel 1 (
    echo.
    echo [ERROR] Docker Compose failed! Is Docker Desktop running?
    pause
    goto menu
)
echo.
echo ===================================================
echo   Backend services started!
echo   API:       http://localhost:8000
echo   API Docs:  http://localhost:8000/docs
echo ===================================================
pause
goto menu

:: ================================================================
::  LOCAL DEV
:: ================================================================
:local
echo.
call :setup_env

:: Check venv exists
if not exist "backend\.venv\Scripts\activate.bat" (
    echo.
    echo [INFO] Virtual environment not found. Creating it now...
    python -m venv backend\.venv
    if errorlevel 1 (
        echo [ERROR] Failed to create venv. Is Python installed and in PATH?
        pause
        goto menu
    )
    echo Installing dependencies...
    cmd /c "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && pip install -r requirements.txt"
    echo.
    echo [OK] Virtual environment created and dependencies installed!
)

echo.
echo Starting FastAPI server...
start "GenUI - API Server" cmd /k "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && uvicorn app.main:app --reload --port 8000"

echo Starting Celery worker...
start "GenUI - Celery Worker" cmd /k "cd /d "%~dp0backend" && call .venv\Scripts\activate.bat && celery -A app.celery_app worker --loglevel=info --pool=solo --concurrency=1"

echo.
echo Starting Flutter web...
start "GenUI - Flutter Web" cmd /k "cd /d "%~dp0frontend" && flutter run -d chrome"

echo.
echo ===================================================
echo   Local dev services launched in separate windows!
echo.
echo   API Server:    window "GenUI - API Server" (port 8000)
echo   Celery Worker: window "GenUI - Celery Worker"
echo   Flutter Web:   window "GenUI - Flutter Web" (Chrome)
echo ===================================================
pause
goto menu

:: ================================================================
::  DOCKER STOP
:: ================================================================
:docker_stop
echo.
echo -- Stopping all Docker services ----------------------------------------
docker compose down
echo.
echo All services stopped.
pause
goto menu

:: ================================================================
::  DOCKER LOGS
:: ================================================================
:docker_logs
echo.
echo -- Docker logs (press Ctrl+C to stop) ----------------------------------
echo.
docker compose logs -f
pause
goto menu

:: ================================================================
:quit
exit /b 0
