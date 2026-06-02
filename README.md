# Field Force Manager

Field Force Manager is a production-quality Flutter application designed to manage field operations, task assignments, visit tracking, and activity monitoring with automated AI-assisted insights. This project was developed as an internship assignment to demonstrate expertise in clean architecture, advanced state management, and role-based access control.

## Features

* Authentication: Secure login system with persistent user sessions.
* Role-Based Access Control: Granular permission system for five distinct user roles.
* Dashboard: Real-time overview of tasks and quick actions based on user permissions.
* Task Management: Comprehensive system for creating, viewing, and tracking task lifecycles.
* Task Assignment Workflow: Hierarchical assignment system preventing unauthorized task delegation.
* Visit Tracking: Dedicated workflow for field agents to check-in, log notes, and complete site visits.
* Activity Timeline: Audit trail for every task showing the complete history of actions.
* Mock AI Insights: Automated analysis of visit notes to determine priority and recommendations.
* Analytics Dashboard: Visual data representation of task distribution and completion rates.
* Hive Local Persistence: Robust offline-first storage for all application data.
* Search and Filters: Global search across the system with status-based filtering.
* Permission-Aware Navigation: Routing system that redirects and restricts access based on authentication and role.

## User Roles

The system implements a strict hierarchy for task assignment and data visibility:

* Admin: Full system access. Can create and assign tasks to any user in the system.
* Regional Manager: Manages regional operations. Can assign tasks to Team Leads and Field Agents.
* Team Lead: Coordinates field activities. Can assign tasks only to Field Agents.
* Field Agent: Executes field tasks. Can update visit statuses, log notes, and complete assigned tasks.
* Auditor: Read-only access. Can browse all tasks, activities, and AI insights but cannot modify data.

## Technology Stack

* Framework: Flutter
* Language: Dart
* State Management: Riverpod
* Navigation: GoRouter
* Local Database: Hive
* Design Language: Material 3
* Logic Processing: Mock AI Service

## Architecture

The project follows Clean Architecture principles to ensure scalability and maintainability:

1. Presentation Layer: Flutter widgets and UI components.
2. Riverpod State Management: Notifiers and providers handling the reactive application state.
3. Repositories: Abstracted data layer that coordinates between different data sources.
4. Local Data Sources: Hive boxes for persistent storage and mock seed data.

The Mock AI service is isolated behind an interface, allowing the deterministic rule-based engine to be replaced with a real Large Language Model API in the future without affecting the presentation layer.

## Folder Structure

```
lib/
├── core/            # Application configuration, theme, and routing
├── shared/          # Common models and reusable UI components
├── features/
│   ├── auth/        # Authentication and session management
│   ├── dashboard/   # Main landing, analytics, and search
│   ├── tasks/       # Task lifecycle, visits, and timeline
│   ├── ai/          # AI insight generation and analysis
│   └── profile/     # User settings and profile management
└── main.dart        # Entry point and database initialization
```

## Mock AI Module

The system features an intelligent analysis module that processes field agent notes upon visit completion. The module performs:

* Summary generation: Condenses detailed notes into a concise overview.
* Priority classification: Automatically flags cases as High, Medium, or Low based on content sentiment and keywords.
* Recommendation generation: Suggests specific next steps for management.
* Warning flag generation: Highlights urgent issues requiring immediate escalation.

Note: The AI behavior is currently implemented as a deterministic rule-based engine to satisfy assignment requirements for local processing.

## Demo Credentials

All accounts use the password: 123456

* Admin: admin@test.com
* Regional Manager: manager@test.com
* Team Lead: lead@test.com
* Field Agent: agent@test.com
* Auditor: auditor@test.com

## Installation

1. Clone the repository.
2. Ensure you have the Flutter SDK installed and configured.
3. Run the following commands:

```bash
flutter pub get
flutter run
```

## Build APK

To generate a release build for Android:

```bash
flutter build apk --release
```

## Screenshots

The following sections illustrate the core functionality of the Field Force Manager application.

### Authentication and Dashboard
* Login Screen: `screenshots/login_screen.png`
* Dashboard: `screenshots/dashboard.png`
* Analytics Dashboard: `screenshots/analytics.png`

### Task and Visit Management
* Task List: `screenshots/task_list.png`
* Task Details: `screenshots/task_details.png`
* Visit Tracking: `screenshots/visit_tracking.png`

### Insights and History
* AI Insights: `screenshots/ai_insights.png`
* Activity Timeline: `screenshots/activity_timeline.png`

## Assignment Requirements Mapping

The project satisfies all requirements specified in the internship assignment:

* Authentication and Roles: Fully implemented with 5 roles and persistent sessions.
* Task Management: Full lifecycle from creation to completion.
* Visit Tracking: Field-ready check-in and outcome logging.
* Activity Timeline: Complete audit trail for every task.
* Mock AI Integration: Rule-based analysis and recommendation engine.
* Role-Based Access: Hierarchical permissions and filtered UI elements.
* Permission-Aware Navigation: Protected routes and automatic redirection.
* Hive Persistence: Full offline state restoration.
* Search and Filters: Global search functionality implemented.

## Assumptions and Design Decisions

* Local-first architecture: The app is designed to work fully offline using Hive.
* Mock repositories: Data is simulated locally to demonstrate UI/UX and logic without requiring a live backend.
* Deterministic AI: Keyword-based priority assignment was chosen for reliability and to avoid external API costs during the review process.
* Permission-based workflows: UI elements are hidden or disabled dynamically based on the logged-in user's role to prevent unauthorized actions.

## Future Improvements

* Real backend integration using Firebase or a REST API.
* Real-time push notifications for task assignments.
* Integration with a live LLM (OpenAI/Gemini) for advanced note analysis.
* Geographic tracking and map integration for visit routes.
* Automated team performance report generation.
