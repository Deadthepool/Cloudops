FROM python:3.13-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1

ENV PYTHONDONTWRITEBYTECODE=1

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Application Modules
COPY main.py database.py schemas.py models.py ./

#Alembic migration configuration
COPY alembic.ini .

COPY alembic/ ./alembic/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]