# SmallBizOps

A SwiftUI iOS app for small-business owners to track inventory, orders, suppliers, and daily tasks, with an on-device "agent" that reviews stock and order health and surfaces findings. All data is read from and written to **Cloud Firestore** in real time — there is no local/mock data store.

## Requirements

- macOS with Xcode 16+ (project uses Swift 5, iOS 17 deployment target)
- An iOS 17+ simulator or device
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled

## Running the app

1. Open `SmallBizOps/SmallBizOps.xcodeproj` in Xcode.
2. Let Xcode resolve Swift Package dependencies (Firebase Auth, Firebase Firestore, and their transitive packages) — this happens automatically on first open.
3. Select the `SmallBizOps` scheme and an iOS 17+ simulator (or a connected device), then **Run** (⌘R).
4. Sign in with an email/password account that exists in the connected Firebase project's Authentication (see below — there is no in-app sign-up).

### Running tests

Unit tests live in the `SmallBizOpsTests` target (`AppRouterTests`, `ModelTests`, `MockDataStoreTests`). Run them from Xcode with ⌘U, or from the command line:

```sh
xcodebuild test \
  -scheme SmallBizOps \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Reaching the backend (Firebase)

The app ships pointed at a specific Firebase project via `SmallBizOps/SmallBizOps/GoogleService-Info.plist` (project id `smallbizops-63040`, bundle id `com.pasindu.smallBizOps`). Firebase is initialized once at launch in `App/SmallBizOpsApp.swift` via `FirebaseApp.configure()` — no further setup is needed if you're using the included config file.

### Using your own Firebase project instead

1. In the [Firebase console](https://console.firebase.google.com), create a project and add an iOS app with bundle id `com.pasindu.smallBizOps` (or update `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode target to match whatever you register).
2. Enable **Authentication → Sign-in method → Email/Password**.
3. Enable **Firestore Database** (start in production or test mode — see data model below for the collections the app expects).
4. Download the project's `GoogleService-Info.plist` and replace `SmallBizOps/SmallBizOps/GoogleService-Info.plist` with it.
5. Since the app has no sign-up screen, create at least one user under **Authentication → Users → Add user** so you can log in.
6. Add some documents to Firestore matching the shapes below (the app no longer seeds mock data — see "No mock data" below).

### Data model

`Data/MockDataStore.swift` attaches a live snapshot listener per collection. Expected collections/documents:

| Collection | Document ID | Shape (see `Models/`) |
|---|---|---|
| `products` | `sku` | `Product` — name, sku, stock, minimum, status (`"Low stock"` \| `"In stock"`), category, supplier, unitCost, averageDailyUsage |
| `orders` | order `id` (e.g. `"#ORD-1048"`) | `Order` — customer, email, phone, total, status (`"Pending"` \| `"Processing"` \| `"Delayed"`), time, itemsLabel, lineItems[], shipping, timeline[] |
| `suppliers` | generated `id` | `Supplier` — name, category, address, city, phone, email, leadTimeDays, productsSupplied[], latitude, longitude |
| `tasks` | generated `id` | `TaskItem` — title, relatedTo, time, priority (`"High"` \| `"Medium"` \| `"Low"`), isCompleted |
| `agentRuns` | generated `id` | `AgentRun` — title, dateLabel, timeLabel, duration, findingsCount, tasksCount, toolCallsCount, reviewState, executionTrace[], createdAt (ordered by `createdAt` desc) |
| `activityEvents` | generated `id` | `ActivityEvent` — title, subtitle, time, isApproved, createdAt (ordered by `createdAt` desc) |
| `settings/business` (single doc) | — | `Business` — ownerName, businessName, role |

Features like low-stock alerts, the "needs attention" count, and the in-app notification center (`Views/Notifications`) are all **derived live** from this data — they're computed, not stored separately.

### No mock data

Earlier versions of this app seeded sample data into an empty Firestore project on first launch (`Data/FirestoreSeeder.swift`). That has been removed now that the backend holds real data — the app only reads/writes to whatever Firestore project `GoogleService-Info.plist` points at. If you connect a brand-new, empty Firebase project, the app will simply show empty lists until you add documents (via the Firebase console, the Firestore CLI, or the app's own "Add product/order/supplier/task" screens).

## Project structure

```
SmallBizOps/
  SmallBizOps/
    App/            Entry point + root navigation shell
    Navigation/      AppRouter: single-screen state machine
    Data/            AuthStore, MockDataStore (Firestore-backed), SettingsContent
    Models/          Codable models matching the Firestore schema above
    Views/           Screens, grouped by feature (Dashboard, Inventory, Orders, Activity, Notifications, Settings, Suppliers, Tasks, Agent, Auth)
    Components/      Shared UI (bottom nav, cards, badges, notification bell, …)
    Theme/           Colors, typography, spacing, shared view modifiers
    Resources/       Info.plist, asset catalog
  SmallBizOpsTests/  Unit tests (router, models, derived store logic)
```
