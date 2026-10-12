
from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title="CloudOps Task API")

# Temporary storage. Data resets when the app restarts.
tasks = []
next_task_id = 1


class TaskCreate(BaseModel):
    title: str = Field(min_length=1, strip_whitespace=True)
    description: str = Field(min_length=1, strip_whitespace=True)
    


@app.get("/")
def home():
    return {"message": "Welcome to CloudOps Task API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/tasks")
def list_tasks():
    return {"tasks": tasks}


@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate):
    global next_task_id

    new_task = {
        "id": next_task_id,
        "title": task.title,
        "description": task.description,
        "completed": False,
    }

    tasks.append(new_task)
    next_task_id += 1

    return new_task
