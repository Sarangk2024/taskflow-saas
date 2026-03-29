# Task Manager - Flutter Frontend

A beautiful task management Flutter application with advanced features.

## Features

✅ Full CRUD operations for tasks
✅ Task blocking dependencies with visual indicators
✅ Draft persistence (auto-save partial tasks)
✅ Debounced autocomplete search with text highlighting
✅ Recurring tasks (Daily/Weekly)
✅ Persistent drag-and-drop reordering
✅ Filter by status
✅ 2-second delay simulation with loading states

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Running backend API at http://localhost:8000

## Setup

1. Navigate to the frontend directory:
```bash
cd task_management_app/frontend/task_manager
```

2. Install dependencies:
```bash
flutter pub get
```

3. Make sure the backend is running (see backend/README.md)

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart            # Task data model
├── services/
│   ├── api_service.dart     # HTTP API client
│   └── draft_service.dart   # Draft persistence
├── providers/
│   └── task_provider.dart   # State management
├── screens/
│   ├── task_list_screen.dart    # Main list view
│   └── task_form_screen.dart    # Create/Edit form
└── widgets/
    ├── task_card.dart           # Task list item
    └── highlighted_text.dart    # Search highlighting
```

## State Management

Uses Provider pattern for clean state management.

## API Configuration

Update the API base URL in `lib/services/api_service.dart` if your backend runs on a different address.
