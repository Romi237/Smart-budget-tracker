# Smart Budget Tracker

A cross-platform Flutter/Dart mobile application for personal finance management.  
Uses device sensors (GPS + Accelerometer) and includes a full automated unit test suite.

**Course project** — University of Yaoundé  
**Team roles:** Lead Developer + QA Developer  
**Tech stack:** Flutter 3.x · Dart 3.x · SQLite · GPS · Accelerometer

---

## Table of Contents

1. [Setup & Run](#setup--run)
2. [Project Structure](#project-structure)
3. [UML Diagrams](#uml-diagrams)
   - [1. Class Diagram](#1-class-diagram)
   - [2. Use Case Diagram](#2-use-case-diagram)
   - [3. Sequence Diagram — Add Transaction](#3-sequence-diagram--add-transaction)
   - [4. Sequence Diagram — Load Transactions](#4-sequence-diagram--load-transactions)
   - [5. Activity Diagram — App Flow](#5-activity-diagram--app-flow)
   - [6. Component Diagram](#6-component-diagram)
   - [7. State Diagram — Transaction Lifecycle](#7-state-diagram--transaction-lifecycle)
   - [8. Entity-Relationship Diagram](#8-entity-relationship-diagram)
4. [Sensors Used](#sensors-used)
5. [Unit Tests](#unit-tests)
6. [Course Requirements Checklist](#course-requirements-checklist)

---

## Setup & Run

```bash
# Install dependencies
flutter pub get

# Run on Android (recommended — full GPS + accelerometer support)
flutter run

# Run on Android emulator
flutter emulators --launch <emulator_id>
flutter run

# Run automated unit tests (QA developer deliverable)
flutter test
flutter test --reporter expanded
```

---

## Project Structure

```
lib/
├── main.dart                        # App entry point + DB factory init
├── models/
│   ├── transaction.dart             # Transaction data model + enum
│   └── budget_limit.dart            # Budget limit model
├── services/
│   ├── budget_service.dart          # Core business logic (lead dev)
│   ├── database_service.dart        # SQLite / in-memory persistence
│   ├── location_service.dart        # GPS sensor (geolocator)
│   └── sensor_service.dart          # Accelerometer sensor (sensors_plus)
├── screens/
│   ├── home_screen.dart             # Transactions list + metrics
│   ├── add_transaction_screen.dart  # Add transaction form
│   ├── analytics_screen.dart        # Charts + budget progress
│   └── unit_test_screen.dart        # In-app test runner
├── widgets/
│   ├── transaction_card.dart        # Transaction list item
│   └── metric_card.dart             # Summary metric card
└── utils/
    ├── app_theme.dart               # Colors, typography, theme
    └── formatters.dart              # Currency, date, category helpers
test/
└── budget_service_test.dart         # 20 automated unit tests
```

---

## UML Diagrams

### 1. Class Diagram

Shows all classes, their attributes, methods, and relationships.

```mermaid
classDiagram

    %% ── ENUM ─────────────────────────────────────
    class TransactionType {
        <<enumeration>>
        income
        expense
    }

    %% ── MODELS ───────────────────────────────────
    class Transaction {
        +String id
        +TransactionType type
        +double amount
        +String category
        +String description
        +DateTime date
        +String? locationLabel
        +double? latitude
        +double? longitude
        +bool isIncome
        +bool isExpense
        +toMap() Map
        +fromMap(Map) Transaction
        +copyWith(...) Transaction
    }

    class BudgetLimit {
        +String category
        +double limit
        +percentUsed(double spent) double
        +isExceeded(double spent) bool
        +isWarning(double spent) bool
    }

    %% ── SERVICES ─────────────────────────────────
    class BudgetService {
        +calculateTotalIncome(List~Transaction~) double
        +calculateTotalExpenses(List~Transaction~) double
        +calculateBalance(List~Transaction~) double
        +filterByType(List~Transaction~, TransactionType) List~Transaction~
        +filterByCategory(List~Transaction~, String) List~Transaction~
        +spendingByCategory(List~Transaction~) Map~String,double~
        +transactionsForMonth(List~Transaction~, int, int) List~Transaction~
        +isValidAmount(double) bool
        +isValidDescription(String) bool
        +isValidDate(DateTime) bool
        +validateTransaction(...) String?
        +budgetUsagePercent(...) double
        +isBudgetExceeded(...) bool
        +sortByDateDesc(List~Transaction~) List~Transaction~
        +sortByAmountDesc(List~Transaction~) List~Transaction~
    }

    class DatabaseService {
        -Database? _db
        -List~Transaction~ _memoryStore
        -String _tableName
        +getAllTransactions() Future~List~Transaction~~
        +insertTransaction(Transaction) Future~void~
        +deleteTransaction(String) Future~void~
        +updateTransaction(Transaction) Future~void~
        +getTransactionsByType(TransactionType) Future~List~Transaction~~
        +getTransactionsByCategory(String) Future~List~Transaction~~
    }

    class LocationService {
        -Position? _lastKnownPosition
        +getCurrentPosition() Future~Position?~
        +formatCoordinates(double, double) String
        +lastKnownPosition Position?
    }

    class SensorService {
        -StreamSubscription? _subscription
        -double _shakeThreshold
        -DateTime? _lastShake
        +startListening(onShake) void
        +stopListening() void
    }

    %% ── SCREENS ──────────────────────────────────
    class HomeScreen {
        -int _selectedIndex
        -List~Transaction~ _transactions
        -BudgetService _budgetService
        -bool _isLoading
        -String _filterType
        -String _filterCategory
        +initState() void
        +dispose() void
        -_loadTransactions() Future~void~
        -_deleteTransaction(String) Future~void~
    }

    class AddTransactionScreen {
        -TransactionType _type
        -String _category
        -DateTime _date
        -String? _locationLabel
        -bool _fetchingLocation
        -bool _saving
        -_fetchLocation() Future~void~
        -_pickDate() Future~void~
        -_save() Future~void~
    }

    class AnalyticsScreen {
        +List~Transaction~ transactions
    }

    class UnitTestScreen {
        -BudgetService _svc
        -bool _running
        -List~TestCase~ _tests
        -_buildTests() List~TestCase~
        -_runAll() Future~void~
    }

    class TestCase {
        +String name
        +String description
        +Function run
        +TestStatus status
        +String? errorMessage
    }

    %% ── WIDGETS ──────────────────────────────────
    class TransactionCard {
        +Transaction transaction
        +VoidCallback onDelete
    }

    class MetricCard {
        +String label
        +double amount
        +Color valueColor
        +IconData icon
    }

    %% ── UTILS ────────────────────────────────────
    class AppTheme {
        +Color primaryGreen
        +Color expenseRed
        +Color warningAmber
        +ThemeData lightTheme
    }

    class Formatters {
        +currency(double) String
        +date(DateTime) String
        +shortDate(DateTime) String
        +signedAmount(Transaction) String
    }

    %% ── RELATIONSHIPS ────────────────────────────
    Transaction --> TransactionType : type
    BudgetService ..> Transaction : uses
    DatabaseService ..> Transaction : persists
    LocationService ..> AddTransactionScreen : provides GPS
    SensorService ..> HomeScreen : triggers refresh

    HomeScreen --> BudgetService : calculates
    HomeScreen --> DatabaseService : loads/deletes
    HomeScreen --> SensorService : listens
    HomeScreen --> TransactionCard : renders
    HomeScreen --> MetricCard : renders
    HomeScreen --> AnalyticsScreen : navigates
    HomeScreen --> UnitTestScreen : navigates

    AddTransactionScreen --> BudgetService : validates
    AddTransactionScreen --> DatabaseService : inserts
    AddTransactionScreen --> LocationService : tags GPS

    AnalyticsScreen --> BudgetService : computes analytics
    AnalyticsScreen --> BudgetLimit : checks budget

    UnitTestScreen --> BudgetService : tests
    UnitTestScreen --> TestCase : runs

    TransactionCard --> Transaction : displays
    TransactionCard --> Formatters : formats
    MetricCard --> Formatters : formats
```

---

### 2. Use Case Diagram

Shows what each actor (User, GPS Sensor, Accelerometer) can do in the system.

```mermaid
graph TB
    User(["👤 User"])
    GPS(["📡 GPS Sensor"])
    Accel(["📲 Accelerometer"])

    subgraph SmartBudgetTracker["Smart Budget Tracker"]
        UC1["Add Transaction"]
        UC2["View Transaction List"]
        UC3["Delete Transaction"]
        UC4["Filter Transactions"]
        UC5["View Analytics"]
        UC6["View Budget Progress"]
        UC7["Run Unit Tests"]
        UC8["Tag Location on Transaction"]
        UC9["Refresh on Shake"]
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7

    UC1 --> UC8
    GPS --> UC8

    Accel --> UC9
    UC9 --> UC2

    UC5 --> UC6
```

---

### 3. Sequence Diagram — Add Transaction

Shows the step-by-step interaction between all components when a user saves a new transaction.

```mermaid
sequenceDiagram
    actor User
    participant ATS as AddTransactionScreen
    participant LS as LocationService
    participant GPS as GPS Sensor
    participant BS as BudgetService
    participant DS as DatabaseService
    participant DB as SQLite / Memory

    User ->> ATS: Opens Add Transaction screen
    ATS ->> LS: getCurrentPosition()
    LS ->> GPS: Request coordinates
    GPS -->> LS: latitude, longitude
    LS -->> ATS: Position (lat, lng)
    ATS -->> User: Shows GPS coordinates

    User ->> ATS: Fills form (amount, description, category, date)
    User ->> ATS: Taps "Save Transaction"

    ATS ->> BS: validateTransaction(amount, description, date, category)
    BS -->> ATS: null (valid) or error string

    alt Validation fails
        ATS -->> User: Shows error SnackBar
    else Validation passes
        ATS ->> DS: insertTransaction(Transaction)
        DS ->> DB: INSERT INTO transactions
        DB -->> DS: success
        DS -->> ATS: done
        ATS -->> User: Navigate back to HomeScreen
    end
```

---

### 4. Sequence Diagram — Load Transactions

Shows how the home screen loads and displays data, including the shake-to-refresh sensor flow.

```mermaid
sequenceDiagram
    actor User
    participant HS as HomeScreen
    participant SS as SensorService
    participant Accel as Accelerometer
    participant DS as DatabaseService
    participant BS as BudgetService
    participant DB as SQLite / Memory

    User ->> HS: Opens app
    HS ->> SS: startListening(onShake)
    SS ->> Accel: Subscribe to stream

    HS ->> DS: getAllTransactions()
    DS ->> DB: SELECT * FROM transactions ORDER BY date DESC
    DB -->> DS: List of rows
    DS -->> HS: List~Transaction~

    HS ->> BS: calculateTotalIncome(transactions)
    BS -->> HS: double
    HS ->> BS: calculateTotalExpenses(transactions)
    BS -->> HS: double
    HS ->> BS: calculateBalance(transactions)
    BS -->> HS: double

    HS -->> User: Renders transaction list + metrics

    Note over User, Accel: Later — user shakes device
    Accel -->> SS: AccelerometerEvent (magnitude > 15)
    SS -->> HS: onShake() callback
    HS ->> DS: getAllTransactions()
    DS -->> HS: updated list
    HS -->> User: Refreshed UI + SnackBar "Shaken!"
```

---

### 5. Activity Diagram — App Flow

Shows the full flow of user actions from app launch to completing any operation.

```mermaid
flowchart TD
    A([App Launch]) --> B[Initialize SQLite factory]
    B --> C[Load HomeScreen]
    C --> D[Start Accelerometer listener]
    D --> E[Load transactions from DB]
    E --> F[Display metrics + list]

    F --> G{User action?}

    G -->|Tap + Add| H[Open AddTransactionScreen]
    H --> I[Fetch GPS location]
    I --> J[User fills form]
    J --> K{Form valid?}
    K -->|No| L[Show validation error]
    L --> J
    K -->|Yes| M[Save to database]
    M --> N[Return to HomeScreen]
    N --> E

    G -->|Tap delete| O[Delete transaction from DB]
    O --> E

    G -->|Filter change| P[Apply type/category filter]
    P --> F

    G -->|Tap Analytics tab| Q[Open AnalyticsScreen]
    Q --> R[Compute spendingByCategory]
    R --> S[Render pie chart + budget bars]
    S --> G

    G -->|Tap Unit Tests tab| T[Open UnitTestScreen]
    T --> U[Tap Run All Tests]
    U --> V[Execute 20 test cases]
    V --> W[Display pass/fail + coverage]
    W --> G

    G -->|Shake device| X[Accelerometer triggers onShake]
    X --> E
```

---

### 6. Component Diagram

Shows how the main layers of the application depend on each other.

```mermaid
graph TB
    subgraph UI["UI Layer"]
        HS[HomeScreen]
        ATS[AddTransactionScreen]
        ANS[AnalyticsScreen]
        UTS[UnitTestScreen]
        TC[TransactionCard]
        MC[MetricCard]
    end

    subgraph Services["Service Layer"]
        BS[BudgetService]
        DS[DatabaseService]
        LS[LocationService]
        SS[SensorService]
    end

    subgraph Models["Model Layer"]
        TX[Transaction]
        BL[BudgetLimit]
        TT[TransactionType]
    end

    subgraph Utils["Utils"]
        AT[AppTheme]
        FM[Formatters]
    end

    subgraph External["External / Device"]
        GPS[GPS Hardware]
        ACCEL[Accelerometer]
        DB[(SQLite DB)]
    end

    HS --> BS
    HS --> DS
    HS --> SS
    ATS --> BS
    ATS --> DS
    ATS --> LS
    ANS --> BS
    ANS --> BL
    UTS --> BS

    BS --> TX
    DS --> TX
    DS --> DB
    LS --> GPS
    SS --> ACCEL

    TX --> TT
    UI --> FM
    UI --> AT
```

---

### 7. State Diagram — Transaction Lifecycle

Shows all the states a transaction goes through from creation to deletion.

```mermaid
stateDiagram-v2
    [*] --> FormOpen : User taps + Add

    FormOpen --> FetchingGPS : Screen opens
    FetchingGPS --> GPSTagged : Location received
    FetchingGPS --> GPSUnavailable : Timeout / denied

    GPSTagged --> FillingForm : User enters data
    GPSUnavailable --> FillingForm : User enters data

    FillingForm --> Validating : User taps Save

    Validating --> ValidationError : Amount = 0 OR description empty OR no category
    ValidationError --> FillingForm : User corrects input

    Validating --> Saving : All fields valid

    Saving --> Persisted : DB insert success

    Persisted --> DisplayedInList : HomeScreen reloads
    DisplayedInList --> Filtered : User applies filter
    Filtered --> DisplayedInList : Filter cleared

    DisplayedInList --> Deleted : User taps delete
    Deleted --> [*]
```

---

### 8. Entity-Relationship Diagram

Shows the data structure stored in the SQLite database.

```mermaid
erDiagram
    TRANSACTION {
        TEXT id PK
        TEXT type
        REAL amount
        TEXT category
        TEXT description
        TEXT date
        TEXT locationLabel
        REAL latitude
        REAL longitude
    }

    BUDGET_LIMIT {
        TEXT category PK
        REAL limit_amount
    }

    TRANSACTION ||--o{ BUDGET_LIMIT : "category matches"
```

---

## Sensors Used

| Sensor | Package | Usage |
|---|---|---|
| **GPS / Geolocation** | `geolocator ^11.0.0` | Tags each transaction with device coordinates at time of creation |
| **Accelerometer** | `sensors_plus ^5.0.1` | Detects shake gesture (magnitude > 15) to trigger transaction list refresh |

Permission required in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## Unit Tests

File: `test/budget_service_test.dart` — **20 test cases**

| Group | Tests | Scenarios covered |
|---|---|---|
| `calculateTotalIncome` | 3 | Correct sum, empty list, no income entries |
| `calculateTotalExpenses` | 2 | Correct sum, empty list |
| `calculateBalance` | 3 | Income − expenses, empty list, negative balance |
| `filterByType` | 3 | Expenses only, income only, no matches |
| `filterByCategory` | 3 | Match, case-insensitive, not found |
| `isValidAmount` | 3 | Positive, zero, negative |
| `isValidDescription` | 2 | Non-empty, empty / whitespace-only |
| `validateTransaction` | 4 | Valid → null, zero amount, empty description, empty category |
| `spendingByCategory` | 2 | Groups correctly, excludes income |
| `isBudgetExceeded` | 3 | Over limit, under limit, no spending |
| `sortByDateDesc` | 1 | Most recent first |
| `sortByAmountDesc` | 1 | Highest first |
| `transactionsForMonth` | 2 | Correct month, wrong month → empty |

```bash
# Run all tests
flutter test

# Run with detailed output
flutter test --reporter expanded
```

---

## Course Requirements Checklist

- [x] Team of 2: lead developer + QA developer
- [x] Device sensors: GPS (location tagging) + Accelerometer (shake to refresh)
- [x] Automated unit tests: 20 test cases in `test/budget_service_test.dart`
- [x] Test scenarios cover valid input, empty input, and edge cases
- [x] Test report shows pass count, fail count, and coverage percentage
- [x] In-app test runner (Unit Tests tab) for live demonstration

# Smart-budget-tracker