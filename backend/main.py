from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from pydantic import BaseModel
from typing import Optional, List
from datetime import date, timedelta
import asyncio

SQLALCHEMY_DATABASE_URL = "sqlite:///./tasks.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class TaskDB(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    due_date = Column(Date)
    status = Column(String)
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)
    is_recurring = Column(String, nullable=True)
    custom_order = Column(Integer, default=0)
    blocked_by = relationship("TaskDB", remote_side=[id], backref="blocking_tasks")

Base.metadata.create_all(bind=engine)

class TaskBase(BaseModel):
    title: str
    description: str
    due_date: date
    status: str
    blocked_by_id: Optional[int] = None
    is_recurring: Optional[str] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(TaskBase):
    pass

class Task(TaskBase):
    id: int
    custom_order: int
    class Config:
        from_attributes = True

app = FastAPI(title="Task Management API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def simulate_delay():
    await asyncio.sleep(2)

@app.get("/")
def read_root():
    return {"message": "Task Management API"}

@app.get("/tasks", response_model=List[Task])
def get_tasks(search: Optional[str] = None, status: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(TaskDB)
    if search:
        query = query.filter(TaskDB.title.contains(search))
    if status:
        query = query.filter(TaskDB.status == status)
    tasks = query.order_by(TaskDB.custom_order, TaskDB.id).all()
    return tasks

@app.get("/tasks/{task_id}", response_model=Task)
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.post("/tasks", response_model=Task)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    await simulate_delay()
    if task.blocked_by_id:
        blocking_task = db.query(TaskDB).filter(TaskDB.id == task.blocked_by_id).first()
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")
    max_order = db.query(TaskDB).count()
    db_task = TaskDB(**task.model_dump(), custom_order=max_order)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.put("/tasks/{task_id}", response_model=Task)
async def update_task(task_id: int, task: TaskUpdate, db: Session = Depends(get_db)):
    await simulate_delay()
    db_task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.blocked_by_id and task.blocked_by_id != task_id:
        blocking_task = db.query(TaskDB).filter(TaskDB.id == task.blocked_by_id).first()
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")
    old_status = db_task.status
    new_status = task.status
    for key, value in task.model_dump().items():
        setattr(db_task, key, value)
    db.commit()
    db.refresh(db_task)
    if old_status != "Done" and new_status == "Done" and db_task.is_recurring:
        if db_task.is_recurring == "Daily":
            new_due_date = db_task.due_date + timedelta(days=1)
        elif db_task.is_recurring == "Weekly":
            new_due_date = db_task.due_date + timedelta(weeks=1)
        else:
            new_due_date = db_task.due_date
        max_order = db.query(TaskDB).count()
        new_task = TaskDB(
            title=db_task.title,
            description=db_task.description,
            due_date=new_due_date,
            status="To-Do",
            blocked_by_id=None,
            is_recurring=db_task.is_recurring,
            custom_order=max_order
        )
        db.add(new_task)
        db.commit()
    return db_task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    blocking_tasks = db.query(TaskDB).filter(TaskDB.blocked_by_id == task_id).all()
    if blocking_tasks:
        raise HTTPException(status_code=400, detail=f"Cannot delete task. {len(blocking_tasks)} task(s) are blocked by this task.")
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}

@app.put("/tasks/reorder")
async def reorder_tasks(task_ids: List[int], db: Session = Depends(get_db)):
    for index, task_id in enumerate(task_ids):
        db_task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
        if db_task:
            db_task.custom_order = index
    db.commit()
    return {"message": "Tasks reordered successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
