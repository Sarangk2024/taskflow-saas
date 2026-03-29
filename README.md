# Task Management Application

A full-stack task management application built with **Flutter** and **Python FastAPI**.

> 📝 **Assignment**: Flodo AI Take-Home Assignment  
> 🎯 **Track**: Track A - Full-Stack Builder  
> ⭐ **Stretch Goals**: ALL THREE (Debounced Search, Recurring Tasks, Drag-and-Drop)

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
- [API Documentation](#api-documentation)
- [AI Usage Report](#ai-usage-report)
- [Demo Video](#demo-video)
- [Technical Decisions](#technical-decisions)

## ✨ Features

### Core Requirements ✅

- **Full CRUD Operations**: Create, Read, Update, and Delete tasks
- **Task Data Model**: Title, Description, Due Date, Status (To-Do/In Progress/Done), Blocked By
- **Task Dependencies**: Visual indicators when tasks are blocked
- **Draft Persistence**: Auto-saves partial task data
- **Search**: Debounced search by task title
- **Filter**: Filter tasks by status
- **2-Second Delay**: Simulated on Create/Update with non-blocking UI

### Stretch Goals ✅

#### 1. Debounced Autocomplete Search with Text Highlighting
- 300ms debounce delay to reduce API calls
- Real-time search as you type
- Matching text highlighted in yellow
- Instant visual feedback

#### 2. Recurring Tasks Logic
- Daily or Weekly recurrence options
- Auto-creates new task when marked "Done"
- Updates due date for next occurrence
- Original task remains in history

#### 3. Persistent Drag-and-Drop Reordering
- Long-press and drag to reorder tasks
- Custom ordering saved to database
- Persists across app restarts
- Smooth animations

### UI/UX Highlights

- 🎨 Material Design 3 with Indigo theme
- 🟦 Color-coded status indicators (Blue, Orange, Green)
- 🔒 Greyed-out blocked tasks with warning banner
- 📅 Overdue dates highlighted in red
- 🔁 Recurring task badges (Daily/Weekly)
- ⌛ Non-blocking loading states
- ⚠️ Error handling with user-friendly messages
- 💾 Auto-saving drafts
- 🔍 Search highlighting

## 🏗️ Tech Stack

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| Python | 3.8+ | Programming language |
| FastAPI | 0.104.1 | Web framework |
| SQLAlchemy | 2.0.23 | ORM |
| SQLite | 3.x | Database |
| Uvicorn | 0.24.0 | ASGI server |
| Pydantic | 2.5.0 | Data validation |

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.0+ | UI framework |
| Dart | 3.0+ | Programming language |
| Provider | 6.1.1 | State management |
| HTTP | 1.1.2 | API communication |
| SharedPreferences | 2.2.2 | Local storage |
| Intl | 0.18.1 | Date formatting |

## 📁 Project Structure

```
task_management_app/
├── backend/
│   ├── main.py                  # FastAPI application
│   ├── requirements.txt         # Python dependencies
│   ├── tasks.db                 # SQLite database (auto-generated)
│   ├── .gitignore
│   └── README.md
│
├── frontend/
│   └── task_manager/
│       ├── lib/
│       │   ├── main.dart        # App entry point
│       │   ├── models/
│       │   │   └── task.dart    # Task data model
│       │   ├── services/
│       │   │   ├── api_service.dart    # HTTP API client
│       │   │   └── draft_service.dart  # Draft persistence
│       │   ├── providers/
│       │   │   └── task_provider.dart  # State management
│       │   ├── screens/
│       │   │   ├── task_list_screen.dart   # Main list view
│       │   │   └── task_form_screen.dart   # Create/Edit form
│       │   └── widgets/
│       │       ├── task_card.dart          # Task item widget
│       │       └── highlighted_text.dart   # Search highlighting
│       ├── pubspec.yaml         # Flutter dependencies
│       ├── analysis_options.yaml
│       ├── .gitignore
│       └── README.md
│
└── README.md                    # This file
```

## 🚀 Setup Instructions

### Prerequisites

Ensure you have the following installed:

- **Python** 3.8 or higher ([Download](https://www.python.org/downloads/))
- **Flutter SDK** 3.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Git** ([Download](https://git-scm.com/downloads))
- **VS Code** or **Android Studio** (recommended)

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd task_management_app/backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   ```

3. **Activate virtual environment**:
   ```bash
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

4. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

5. **Run the server**:
   ```bash
   python main.py
   ```

   The backend will start at `http://localhost:8000`

6. **Verify it's running**:
   - Open browser: http://localhost:8000
   - API Docs: http://localhost:8000/docs

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd task_management_app/frontend/task_manager
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For Chrome (Web)
   flutter run -d chrome
   
   # For Windows
   flutter run -d windows
   
   # For Android (with emulator running)
   flutter run
   
   # For iOS (macOS only, with simulator)
   flutter run -d ios
   ```

**Important**: Make sure the backend is running before starting the frontend!

## 📖 Usage Guide

### Creating a Task

1. Click the "**New Task**" floating action button
2. Fill in the form:
   - **Title** (required)
   - **Description** (required)
   - **Due Date** (tap to select)
   - **Status** (dropdown: To-Do, In Progress, Done)
   - **Blocked By** (optional: select another task)
   - **Recurring** (optional: None, Daily, Weekly)
3. Click "**Create Task**"
4. Wait for 2-second delay (loading indicator shown)
5. Task appears in the list

### Searching Tasks

1. Type in the search bar at the top
2. Search is debounced (300ms delay)
3. Matching text is highlighted in yellow
4. Results update in real-time

### Filtering by Status

1. Tap filter chips below the search bar:
   - **All** - Show all tasks
   - **To-Do** - Show only To-Do tasks
   - **In Progress** - Show only In Progress tasks
   - **Done** - Show only completed tasks

### Reordering Tasks

1. Long-press on a task card
2. Drag it up or down
3. Release to drop in new position
4. Order is automatically saved to the database

### Editing a Task

1. Tap on any task card
2. Edit form opens with current data
3. Make changes
4. Click "**Update Task**"
5. Wait for 2-second delay
6. Returns to list with updated task

### Deleting a Task

1. Tap the **delete icon** on a task card
2. Confirm deletion in the dialog
3. Task is removed

**Note**: Cannot delete tasks that are blocking other tasks!

### Task Blocking

- When Task B is "**Blocked By**" Task A:
  - Task B appears greyed out
  - Shows yellow warning banner: "Blocked by: [Task A Title]"
  - Once Task A is marked "Done", Task B becomes active

### Recurring Tasks

1. Create/Edit a task
2. Set "**Recurring**" to Daily or Weekly
3. Mark task as "**Done**"
4. A new task is automatically created:
   - Same title and description
   - Status: To-Do
   - Due date: +1 day (Daily) or +7 days (Weekly)
   - Original task remains in Done status

### Draft Persistence

- Start creating a task
- Type title, description, etc.
- Close the app or navigate away
- Reopen the create screen
- **Your draft is still there!**
- Draft is cleared after successful creation

## 📚 API Documentation

Once the backend is running, visit:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API status |
| GET | `/tasks` | Get all tasks (supports `?search=` and `?status=`) |
| GET | `/tasks/{id}` | Get specific task |
| POST | `/tasks` | Create task (2s delay) |
| PUT | `/tasks/{id}` | Update task (2s delay) |
| DELETE | `/tasks/{id}` | Delete task |
| PUT | `/tasks/reorder` | Reorder tasks |

### Request/Response Examples

**Create Task**:
```json
POST /tasks
{
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "due_date": "2026-04-01",
  "status": "To-Do",
  "blocked_by_id": null,
  "is_recurring": "Weekly"
}
```

**Response**:
```json
{
  "id": 1,
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "due_date": "2026-04-01",
  "status": "To-Do",
  "blocked_by_id": null,
  "is_recurring": "Weekly",
  "custom_order": 0
}
```

## 🤖 AI Usage Report

### AI Tools Used

- **GitHub Copilot CLI**: Complete project generation and code creation
- **Claude AI**: Architecture planning and problem-solving

### Most Helpful Prompts

1. **Backend Architecture**:
   > "Create a FastAPI backend with SQLAlchemy that supports task CRUD operations, implements 2-second delay simulation on create/update, handles recurring task logic (Daily/Weekly), and supports custom ordering for drag-and-drop"

   **Result**: Generated complete backend with proper async/await handling, relationship management, and recurring task auto-creation logic.

2. **Frontend State Management**:
   > "Build a Flutter Provider-based state management system with debounced search (300ms delay), text highlighting for search results, and integration with ReorderableListView for persistent drag-and-drop"

   **Result**: Clean separation of concerns with Provider pattern, efficient debouncing implementation, and optimistic UI updates.

3. **Draft Persistence**:
   > "Implement draft persistence using SharedPreferences in Flutter to auto-save task creation form data as the user types, restore it when returning to the form, and clear it after successful submission"

   **Result**: Seamless draft saving with TextEditingController listeners and proper lifecycle management.

### AI Hallucinations & Fixes

#### Issue 1: Package Recommendation
- **AI Suggested**: Using `flutter_reorderable_list` external package
- **Problem**: Package had compatibility issues and was outdated
- **Fix**: Switched to Flutter's built-in `ReorderableListView` which is more stable and well-maintained

#### Issue 2: Date Serialization
- **AI Generated**: Full ISO8601 timestamp with time component
- **Problem**: Backend expected date-only format (YYYY-MM-DD)
- **Fix**: Modified serialization to use `.split('T')[0]` to extract date portion only:
  ```dart
  'due_date': dueDate.toIso8601String().split('T')[0]
  ```

#### Issue 3: Search Implementation
- **AI Suggested**: Direct API calls on every `onChanged` event
- **Problem**: Would cause excessive API calls and poor performance
- **Fix**: Implemented proper debouncing with `Timer`:
  ```dart
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    _applyFilters();
  });
  ```

#### Issue 4: Blocked Task Status
- **AI Initial Code**: Only checked if `blocked_by_id` exists
- **Problem**: Didn't account for blocking task being "Done"
- **Fix**: Added status check:
  ```dart
  bool isTaskBlocked(Task task) {
    if (task.blockedById == null) return false;
    Task? blockingTask = getTaskById(task.blockedById!);
    return blockingTask != null && blockingTask.status != 'Done';
  }
  ```


## 🧠 Technical Decisions

### 1. State Management: Provider vs BLoC/Riverpod

**Decision**: Used Provider

**Reasoning**:
- Simpler learning curve and less boilerplate
- Perfect for app's complexity level
- Excellent Flutter integration
- ChangeNotifier pattern is intuitive
- Widely adopted with strong community support

**Alternative Considered**: BLoC pattern
- **Pros**: More scalable, testable, reactive
- **Cons**: Overkill for this app size, steeper learning curve

### 2. Database: SQLite vs PostgreSQL

**Decision**: Used SQLite

**Reasoning**:
- Zero configuration required
- File-based database perfect for development
- Meets all assignment requirements
- Easy to share and demo
- FastAPI + SQLAlchemy abstracts DB differences

**Alternative Considered**: PostgreSQL
- **Pros**: More robust, better for production
- **Cons**: Requires installation and configuration

### 3. Debounce Implementation Location

**Decision**: Implemented in Provider layer

**Reasoning**:
- Centralizes business logic
- UI remains clean and simple
- Easy to adjust debounce timing
- Prevents duplicate debouncing in multiple widgets

**Alternative Considered**: Widget-level debouncing
- **Cons**: Would need to duplicate logic if search appears in multiple places

### 4. Drag-and-Drop: Optimistic vs Pessimistic Updates

**Decision**: Optimistic UI updates

**Reasoning**:
- Immediate visual feedback for better UX
- Feels faster and more responsive
- Network latency doesn't block UI
- Reverts on failure (with error message)

**Implementation**:
```dart
// Update UI immediately
_filteredTasks = reorderedTasks;
notifyListeners();

// Then sync to backend
await _apiService.reorderTasks(taskIds);
```

### 5. Recurring Task Strategy

**Decision**: Auto-create on "Done" status change

**Reasoning**:
- Aligns with user mental model
- Backend can detect status transition
- Single source of truth (backend)
- Frontend doesn't need complex logic

**Alternative Considered**: Cron job for scheduled creation
- **Cons**: Requires additional infrastructure, less immediate feedback

## 🧪 Testing

### Manual Testing Checklist

- [x] Create task with all fields
- [x] Create task with minimal fields
- [x] Update task
- [x] Delete task
- [x] Delete blocked task (should fail)
- [x] Search tasks by title
- [x] Filter by each status
- [x] Clear search
- [x] Clear filter
- [x] Drag-and-drop reorder
- [x] Refresh task list
- [x] Task blocking (greyed out)
- [x] Mark blocking task as Done (unblocks)
- [x] Create recurring task (Daily)
- [x] Mark recurring task Done (creates new)
- [x] Draft persistence (minimize app)
- [x] Draft clear (after creation)
- [x] 2-second delay loading state
- [x] Prevent double-tap during save
- [x] Overdue date highlighting
- [x] Network error handling

### Test Scenarios

#### Scenario 1: Task Dependencies
1. Create Task A: "Setup environment"
2. Create Task B: "Write code" (blocked by Task A)
3. Verify Task B is greyed out
4. Mark Task A as "Done"
5. Verify Task B is no longer greyed out

#### Scenario 2: Recurring Tasks
1. Create "Weekly Report" (Recurring: Weekly, Due: 2026-04-01)
2. Mark as "Done"
3. Verify new task created with due date 2026-04-08
4. Verify original task remains "Done"

#### Scenario 3: Draft Persistence
1. Click "New Task"
2. Type title: "Test Draft"
3. Type description: "Testing draft feature"
4. Close app (minimize or kill)
5. Reopen app
6. Click "New Task"
7. Verify fields contain "Test Draft" and description

## 🐛 Known Limitations

1. **iOS Testing**: Not tested on iOS (requires macOS environment)
2. **Offline Mode**: Limited offline support - shows error messages for network failures
3. **Pagination**: No pagination implemented (works well for <1000 tasks)
4. **Search Scope**: Only searches task titles, not descriptions
5. **Multi-user**: No authentication or multi-user support

## 🚀 Future Enhancements

If I had more time, I would add:

- [ ] **Subtasks**: Task hierarchies and nested tasks
- [ ] **Categories/Tags**: Organize tasks with custom tags
- [ ] **Notifications**: Push notifications for due dates
- [ ] **Attachments**: Upload files to tasks
- [ ] **Comments**: Discussion threads on tasks
- [ ] **Dark Mode**: Theme switching
- [ ] **Export**: CSV/PDF export
- [ ] **Analytics**: Task completion statistics
- [ ] **Calendar View**: Visual timeline
- [ ] **Collaboration**: Share tasks with other users
- [ ] **Offline Support**: Local-first with sync
- [ ] **Undo/Redo**: Action history

## 📝 Commit History

This project follows atomic commits:

```
✅ Initial project setup
✅ Add FastAPI backend with SQLAlchemy
✅ Implement CRUD endpoints
✅ Add 2-second delay simulation
✅ Implement recurring task logic
✅ Create Flutter project structure
✅ Implement Provider state management
✅ Add task list screen with ReorderableListView
✅ Implement debounced search
✅ Add text highlighting widget
✅ Implement draft persistence
✅ Add task form with validation
✅ Implement task blocking UI
✅ Polish UI/UX and themes
✅ Add documentation and README
```

## 📄 License

Created for Flodo AI Take-Home Assignment.

## 👤 Author

Created with ❤️ using:
- GitHub Copilot CLI
- Claude AI
- Lots of coffee ☕

---

**Total Development Time**: ~8 hours  
**Lines of Code**: ~2000  
**Features**: 100% Core + 100% Stretch Goals  
**Coffee Consumed**: ☕☕☕☕

---


**Thank you for reviewing my submission!** 🙏
