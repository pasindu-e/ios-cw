# SmallBizOps — Feature Documentation

_Last updated: 2026-10-24_

## Overview

SmallBizOps is a SwiftUI iOS app for small business operations management
(inventory, orders, suppliers, tasks, and an AI operations agent). It is
backed by Firebase (Authentication + Firestore) with an optional on-device AI
agent powered by Apple's Foundation Models framework.

**Stack**
- SwiftUI, iOS 17.0+ deployment target
- Firebase Authentication (email/password)
- Cloud Firestore (real-time listeners)
- Apple Foundation Models framework (on-device LLM, iOS 26+ / Apple
  Intelligence–capable devices only, with a rule-based fallback everywhere
  else)

**Architecture**
- `MockDataStore` (`Data/MockDataStore.swift`) is the single app-wide,
  Firestore-backed `ObservableObject`, injected via `@EnvironmentObject`
  throughout the view hierarchy. It keeps its original name for historical
  reasons, but holds no mock data — all `@Published` arrays are populated by
  live Firestore snapshot listeners.
- `AuthStore` (`Data/AuthStore.swift`) wraps Firebase Auth and drives the
  app's top-level navigation stage (`credentials` → `faceIDSetup` →
  `authenticated`).
- `AppRouter` (`Navigation/AppRouter.swift`) is a simple screen-enum router
  used once the user is authenticated.
- `AgentService` (`Data/AgentService.swift`) runs the on-device AI agent.

## Authentication

- Firebase email/password sign-in (`AuthStore.signIn`). The login screen's
  "Email" field is the Firebase Auth email.
- After a successful sign-in, the user is taken through an optional Face ID
  enrollment step (`FaceIDSetupView`) before landing on the main app.
- Session persistence: on cold launch, `AuthStore.init()` checks
  `Auth.auth().currentUser` and skips straight to the authenticated state if
  already signed in.
- Sign-out (`AuthStore.signOut`) calls `Auth.auth().signOut()` and returns to
  the credentials screen.
- **Important lifecycle detail:** `MockDataStore` does **not** start its
  Firestore listeners in `init()`. It exposes `start()` / `stop()`, called
  from `SmallBizOpsApp` only when `auth.stage` becomes `.authenticated` /
  `.credentials` respectively. This is required because Firestore security
  rules require `request.auth != null` — starting listeners before sign-in
  causes silent permission-denied failures, and a permission error on a
  Firestore **listener** (unlike a one-shot call) kills that listener
  permanently until the app restarts. `stop()` also clears all local
  `@Published` state on sign-out so the next user doesn't see stale data.
- **Not implemented:** sign-up flow (users must be created manually via
  Firebase Console → Authentication → Users), "Forgot password?", "Continue
  with Google" (both are inert UI stubs on the login screen).

## Data Layer (Firestore)

Firestore collections, all under the default database:

| Collection | Document ID | Model |
|---|---|---|
| `products` | SKU | `Product` |
| `orders` | Order ID (e.g. `#ORD-1048`) | `Order` |
| `suppliers` | random UUID string | `Supplier` |
| `tasks` | random UUID string | `TaskItem` |
| `agentRuns` | random UUID string | `AgentRun` |
| `activityEvents` | random UUID string | `ActivityEvent` |
| `settings/business` | fixed doc `business` | `Business` |

- **`FirestoreSeeder`** (`Data/FirestoreSeeder.swift`) seeds a brand-new
  Firestore project with sample data from `MockData.swift` the first time the
  `products` collection is found empty. It is a one-time, idempotent
  operation triggered from `MockDataStore.start()`. On failure, it returns a
  human-readable error message instead of only printing to the console.
- **In-app diagnostics:** `MockDataStore.diagnosticMessage` surfaces any
  Firestore listener or seeding error as a "Data Sync Issue" alert on the
  Home screen, so Firestore problems are visible without needing Xcode's
  console.
- All create/update/delete operations use completion-handler APIs
  (`Result<Void, Error>`) so the UI can show real success/failure feedback
  instead of silently swallowing errors (the original `try?` pattern used
  during early development did not do this).

## Inventory (Products)

- **Read:** live list (`InventoryView`) with search, category/status filter
  chips, and summary counts (tracked / low stock / out of stock) computed
  from live data.
- **Create:** `+` button → `AddProductView` (name, SKU, category, supplier,
  stock, minimum, unit cost, average daily usage). SKU must be unique and
  becomes the Firestore document ID.
- **Update:** `ProductDetailView` → "Edit" opens the same `AddProductView` in
  edit mode (SKU locked once created, since it's the document ID).
- **Delete:** trash icon on `ProductDetailView`, with a confirmation alert.
- **Reorder approval:** `ReorderView` → "Approve Reorder" now actually
  increases the product's `stock` in Firestore, recomputes its low/in-stock
  `status`, and logs a "Reorder approved" entry to `activityEvents`. (Earlier
  in development this only updated a local display value and didn't persist
  anything — fixed.)
- Low-stock detection drives the Home "Needs attention" section and the
  agent's rule-based findings (see "AI Operations Agent" below).

## Orders

- **Read:** live list (`OrdersView`) with status filter (All/Pending/
  Processing/Delayed) and live header/section counts.
- **Create:** `+` button → `AddOrderView` — customer info, a dynamic list of
  line items (add/remove), shipping cost, and a status picker. On save, it
  generates a unique `#ORD-XXXX` ID, computes the total, and builds a status
  timeline matching the chosen status (Pending/Processing/Delayed each get a
  different pre-filled timeline).
- **Detail / follow-up:** `OrderDetailView` shows the line items, totals, and
  status timeline; "Create Follow-up Task" adds a task linked to the order.
- **Not implemented:** order edit/delete (only Create + Read exist for
  Orders; Products/Suppliers/Tasks have full CRUD).

## Suppliers

- **Read:** map + list (`SuppliersView`) with live `store.suppliers`.
- **Create:** `+` button → `AddEditSupplierView` (name, category, products
  supplied, contact info, lead time, and a map location picker).
- **Update:** pencil icon on the selected supplier's detail card opens the
  same form pre-filled.
- **Delete:** trash icon with a confirmation alert.
- **Map location picker:** the add/edit form shows an interactive map —
  tapping anywhere drops a pin there, and that pin's coordinates are saved
  (no manual latitude/longitude entry). Editing a supplier centers the map on
  their existing location.

## Tasks

- **Read:** live list (`TasksView`) with Today/Upcoming/Completed tabs and a
  live completion-progress ring.
- **Create:** `+` button → `AddEditTaskView` (title, related-to, time,
  priority).
- **Update:** pencil icon on each row, or long-press → context menu → Edit.
- **Delete:** long-press → context menu → Delete, with a confirmation alert.
  (SwiftUI's built-in swipe-to-delete only works inside a `List`; this screen
  uses a custom card layout, so edit/delete use a visible pencil icon + a
  long-press context menu instead.)
- Toggling the checkbox marks a task complete/incomplete
  (`MockDataStore.toggleTask`).

## Activity & Agent Runs

- `ActivityView` shows the most recent agent run (`store.todayRun`), a feed
  of `activityEvents`, and the prior run (`store.yesterdayRun`) — all live
  from Firestore, including the summary strip (agent run count, total
  findings across runs, live task count), which was previously hardcoded.
- `RunDetailView` shows a single run's stats and execution trace, with a
  "No run data yet" empty state when none exists.
- Agent run and activity records are currently only created by
  `FirestoreSeeder` (sample data) and `approveReorder` (which logs a real
  activity event). There is no UI action yet that creates a brand-new
  `AgentRun` record after a live agent execution — only the in-memory
  "trace"/"findings" for the current session are updated (see below).

## AI Operations Agent

- `AgentService` (`Data/AgentService.swift`) calls Apple's on-device
  `LanguageModelSession` (Foundation Models framework), feeding it the live
  product and order data as plain text, with instructions to flag only
  genuine issues (stock at/below minimum, delayed orders) and to reference
  only SKUs/order IDs it was actually given.
- The model returns structured output (`@Generable` types: a summary
  sentence + a findings list with severity, title, explanation, suggestion,
  and related SKU/order). Findings referencing an ID that wasn't in the
  provided data are dropped as a **hallucination guard**.
- `AgentRunningView` kicks off the real async call while its intro animation
  plays, and only shows "Your plan is ready" once the model call actually
  resolves — not on a fixed timer.
- `AgentResultsView` shows the real summary/findings (`store.displayedFindings`)
  with dynamic counts, and a live execution trace reflecting the actual run
  (real product/order counts, and whether the AI path or the fallback ran).
- **Fallback:** Apple's Foundation Models framework requires iOS 26+ on an
  Apple Intelligence–capable device (A17 Pro/M-series or later, Apple
  Intelligence enabled in Settings). Everywhere else — older iOS, unsupported
  hardware, Apple Intelligence off, or the Simulator (which usually reports
  unavailable) — the app automatically falls back to plain rule-based
  findings computed from live stock/order data (`MockDataStore.findings`),
  with a message explaining why.

## Business Profile & Settings

- The business profile (owner name, business name, role) is stored at
  `settings/business` in Firestore and is live on both Home (greeting,
  avatar initials) and Settings (profile card).
- Tap the profile card on Settings, or the avatar on Home, to open
  `BusinessProfileView` and edit it.
- Home's greeting is time-of-day-based ("Good morning/afternoon/evening,
  {first name}") and the date label is the real current date — no longer
  hardcoded.
- **Still static** (not business data — unbuilt-feature placeholders in the
  Settings menu, not bugs): "Stock thresholds (2 custom rules)",
  "Notifications (Daily brief at 8:30 AM)", "Sync status", "On-device
  processing", "About SmallBizOps", "Privacy & security". Wiring these to
  real data would mean building those features from scratch (a threshold
  editor, a notification scheduler, etc.).

## Known Limitations / Not Yet Implemented

- No sign-up flow — users must be created manually in Firebase Console.
- Orders have no edit/delete (only Create + Read).
- Cosmetic no-op buttons: "Forgot password?" and "Continue with Google" on
  the login screen, "Filter" and the search icon on Activity, "Edit Proposal
  Details" on the Reorder screen.
- Static Settings menu rows listed above under "Business Profile & Settings".
- No agent-run history is created from a live (non-fallback) agent execution
  — only the current session's summary/findings/trace are updated in memory.
- `MockData.swift` still exists, but solely as `FirestoreSeeder`'s one-time
  seed source for a brand-new Firebase project — it is not read anywhere
  else in the live app.
