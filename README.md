# CloudOps Task API

A task-management REST API built with Python and FastAPI.

## Run locally

Activate the virtual environment and install the dependencies:

    python -m pip install fastapi "uvicorn[standard]" pytest httpx

Start the development server:

    python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

## API documentation

Open http://127.0.0.1:8000/docs

## Run tests

    python -m pytest -v
