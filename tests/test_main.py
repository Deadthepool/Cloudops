
import main
from fastapi.testclient import TestClient

client = TestClient(main.app)


def setup_function():
    # Reset in-memory data before each test.
    main.tasks.clear()
    main.next_task_id = 1


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_list_tasks_initially_empty():
    response = client.get("/tasks")

    assert response.status_code == 200
    assert response.json() == {"tasks": []}


def test_create_task():
    response = client.post(
        "/tasks",
        json={
            "title": "Learn Docker",
            "description": "Containerize CloudOps",
        },
    )

    assert response.status_code == 201
    assert response.json() == {
        "id": 1,
        "title": "Learn Docker",
        "description": "Containerize CloudOps",
        "completed": False,
    }


def test_empty_title_is_rejected():
    response = client.post(
        "/tasks",
        json={"title": "", "description": "Invalid task"},
    )

    assert response.status_code == 422
def test_empty_description_is_rejected():
    response = client.post(
        "/tasks",
        json={"title": "Valid Title", "description": ""},
    )

    assert response.status_code == 422

def test_get_task_by_id():
    create_response = client.post(
        "/tasks",
        json={
            "title": "Learn FastAPI",
            "description": "Test task retrieval",
        },
    )
    task_id = create_response.json()["id"]

    response = client.get(f"/tasks/{task_id}")

    assert response.status_code == 200
    assert response.json()["id"] == task_id
    assert response.json()["title"] == "Learn FastAPI"
    assert response.json()["description"] == "Test task retrieval"
    assert response.json()["completed"] is False

def test_get_nonexistent_task():
    response = client.get("/tasks/99999")

    assert response.status_code == 404
    assert response.json() == {"detail": "task not found"}

def test_complete_task():
    create_response = client.post(
        "/tasks",
        json={
            "title": "Learn Kubernetes",
            "description": "Test task completion",
        }
    )

    task_id = create_response.json()["id"]

    response = client.patch(f"/tasks/{task_id}/complete")

    assert response.status_code == 200
    assert response.json()["id"] == task_id
    assert response.json()["completed"] is True


def test_complete_nonexistent_task():
    response = client.patch("/tasks/99999/complete")

    assert response.status_code == 404
    assert response.json() == {"detail": "task not found"}

def test_task_delete():
    create_response = client.post(
        "/tasks",
        json={
            "title": "Learn Pytest",
            "description": "Test the task deletion",
        }
    )

    task_id = create_response.json()["id"]

    response = client.delete(f"/tasks/{task_id}")

    assert response.status_code == 200
    assert response.json()["message"] == "Task deleted successfully"

    get_response = client.get(f"/tasks/{task_id}")

    assert get_response.status_code == 404

def test_delete_nonexistent():
    response = client.delete("tasks/9999")

    assert response.status_code == 404
    assert response.json() == {"detail": "task not found"}

