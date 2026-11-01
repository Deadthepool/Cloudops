from typing import Annotated
from pydantic import BaseModel, ConfigDict, Field, StringConstraints


TaskTitle = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=255,
    ),
]

TaskDescription = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=1000,
    ),
]

class TaskCreate(BaseModel):
    title: TaskTitle
    description: TaskDescription
#    title: str = Field(min_length=1, max_length=255, strip_whitespace=True)
#    description: str = Field(min_length=1, max_length=1000, strip_whitespace=True)

class TaskResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str
    completed: bool