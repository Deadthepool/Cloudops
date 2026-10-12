
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
 