
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from schemas import TaskCreate, TaskResponse
from database import get_db
from models import Task



app = FastAPI(title="CloudOps Task API")






@app.get("/")
def home():
    return {"message": "Welcome to CloudOps Task API"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/tasks", response_model=dict[str, list[TaskResponse]])
def list_tasks(db: Session = Depends(get_db)):
    tasks = db.query(Task).all()
    return {"tasks": tasks}

@app.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = db.get(Task, task_id)

    if task is None:
        raise HTTPException(
            status_code=404,
            detail="task not found"
        )
    return task


@app.patch("/tasks/{task_id}/complete", response_model=TaskResponse)
def complete_task(task_id: int,db: Session = Depends(get_db)):
    task=db.get(Task, task_id)

    if task is None:
        raise HTTPException(
            status_code=404,
            detail="task not found",
        )
    task.completed=True

    db.commit()
    db.refresh(task)
    return task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.get(Task, task_id)
    if task is None:
        raise HTTPException(
            status_code=404,
            detail="task not found"
        )
    deleted_task = TaskResponse.model_validate(task)
    db.delete(task)
    db.commit()
    

    return {
        "message": "Task deleted successfully",
        "task": deleted_task.model_dump()
    }

    

@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    new_task = Task(
        title=task.title,
        description=task.description,
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task
