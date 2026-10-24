import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// Live, Firestore-backed app data. The type keeps its original name so
/// existing `@EnvironmentObject var store: MockDataStore` call sites don't change.
@MainActor
final class MockDataStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var orders: [Order] = []
    @Published var tasks: [TaskItem] = []
    @Published var suppliers: [Supplier] = []
    @Published var agentRuns: [AgentRun] = []
    @Published var activityEvents: [ActivityEvent] = []
    @Published var faceIDEnabled: Bool = false
    @Published var lastReorderApproval: (product: String, quantity: Int, total: Double)? = nil
    @Published var createdFollowUpTaskForOrder: Set<String> = []
    @Published var latestAgentSummary: String?
    @Published var latestAgentFindings: [AgentFinding]?
    @Published var latestAgentTrace: [TraceLine]?
    @Published var business: Business = .placeholder
    @Published var diagnosticMessage: String?
    @Published var isSeeding = false
    @Published var seedResultMessage: String?
    @Published private var readNotificationIDs: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "readNotificationIDs") ?? [])

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private var hasStarted = false

    deinit {
        listeners.forEach { $0.remove() }
    }

    /// Starts Firestore listeners and the one-time seed. Must be called only
    /// after the user is signed in — Firestore security rules require auth,
    /// so starting this before sign-in causes silent permission-denied
    /// failures (and a permission error on a *listener*, unlike a one-shot
    /// call, kills that listener permanently until the app restarts).
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        // On a cold launch with a cached session, Auth.auth().currentUser can be
        // non-nil before its ID token is actually valid for outgoing requests,
        // which causes a transient permission-denied on the first Firestore call
        // (and since that's a one-shot read/listener, it would never retry).
        // Forcing a token refresh first guarantees requests below are authorized.
        Task { [weak self] in
            _ = try? await Auth.auth().currentUser?.getIDToken(forcingRefresh: true)
            self?.startListening()
        }
    }

    /// Tears down all listeners and clears local data, e.g. on sign-out, so
    /// the next sign-in starts clean and doesn't leak the previous user's data.
    func stop() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        hasStarted = false
        products = []
        orders = []
        tasks = []
        suppliers = []
        agentRuns = []
        activityEvents = []
        business = .placeholder
        latestAgentSummary = nil
        latestAgentFindings = nil
        latestAgentTrace = nil
    }

    private func startListening() {
        listeners.append(db.collection("products").addSnapshotListener { [weak self] snapshot, error in
            if let error {
                print("products listener error: \(error)")
                self?.diagnosticMessage = "Couldn't load live data: \(error.localizedDescription)"
            }
            guard let self, let documents = snapshot?.documents else { return }
            self.products = documents.compactMap { doc in
                do {
                    return try doc.data(as: Product.self)
                } catch {
                    print("Failed to decode product \(doc.documentID): \(error)")
                    return nil
                }
            }
        })
        listeners.append(db.collection("orders").addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let documents = snapshot?.documents else { return }
            self.orders = documents.compactMap { try? $0.data(as: Order.self) }
        })
        listeners.append(db.collection("suppliers").addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let documents = snapshot?.documents else { return }
            self.suppliers = documents.compactMap { try? $0.data(as: Supplier.self) }
        })
        listeners.append(db.collection("tasks").addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let documents = snapshot?.documents else { return }
            self.tasks = documents.compactMap { try? $0.data(as: TaskItem.self) }
        })
        listeners.append(db.collection("agentRuns").order(by: "createdAt", descending: true).addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let documents = snapshot?.documents else { return }
            self.agentRuns = documents.compactMap { try? $0.data(as: AgentRun.self) }
        })
        listeners.append(db.collection("activityEvents").order(by: "createdAt", descending: true).addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let documents = snapshot?.documents else { return }
            self.activityEvents = documents.compactMap { try? $0.data(as: ActivityEvent.self) }
        })
        listeners.append(db.collection("settings").document("business").addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let business = try? snapshot?.data(as: Business.self) else { return }
            self.business = business
        })

        Task { [weak self] in
            if case .failed(let error) = await FirestoreSeeder.seedIfNeeded(db: db) {
                self?.diagnosticMessage = "Couldn't load starter data: \(error)"
            }
        }
    }

    /// Manually triggers the one-time seed (e.g. from a "Seed Mock Data" button).
    /// Still a no-op if the `products` collection already has data.
    func seedMockData() {
        guard !isSeeding else { return }
        isSeeding = true
        Task { [weak self] in
            guard let self else { return }
            switch await FirestoreSeeder.seedIfNeeded(db: self.db) {
            case .seeded:
                self.seedResultMessage = "Mock data seeded successfully."
            case .alreadySeeded:
                self.seedResultMessage = "Mock data already exists — nothing to seed."
            case .failed(let error):
                self.seedResultMessage = "Failed to seed mock data: \(error)"
            }
            self.isSeeding = false
        }
    }

    func product(sku: String) -> Product? {
        products.first { $0.sku == sku }
    }

    func order(id: String) -> Order? {
        orders.first { $0.id == id }
    }

    func addProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("products").document(product.sku).setData(from: product) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("products").document(product.sku).setData(from: product, merge: false) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteProduct(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("products").document(product.sku).delete { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func updateBusiness(_ business: Business, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("settings").document("business").setData(from: business) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func addOrder(_ order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("orders").document(order.id).setData(from: order) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func addSupplier(_ supplier: Supplier, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("suppliers").document(supplier.id).setData(from: supplier) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateSupplier(_ supplier: Supplier, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("suppliers").document(supplier.id).setData(from: supplier, merge: false) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteSupplier(_ supplier: Supplier, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("suppliers").document(supplier.id).delete { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func toggleTask(_ task: TaskItem) {
        db.collection("tasks").document(task.id).updateData(["isCompleted": !task.isCompleted])
    }

    func addTask(_ task: TaskItem, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("tasks").document(task.id).setData(from: task) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateTask(_ task: TaskItem, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("tasks").document(task.id).setData(from: task, merge: false) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteTask(_ task: TaskItem, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("tasks").document(task.id).delete { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func approveReorder(product: Product, quantity: Int) {
        lastReorderApproval = (product.name, quantity, Double(quantity) * product.unitCost)

        var updated = product
        updated.stock += quantity
        updated.status = updated.stock <= updated.minimum ? .lowStock : .inStock

        do {
            try db.collection("products").document(updated.sku).setData(from: updated) { [weak self] error in
                guard let self else { return }
                if let error {
                    print("Failed to apply reorder for \(updated.sku): \(error)")
                    return
                }
                let event = ActivityEvent(
                    title: "Reorder approved",
                    subtitle: "\(product.name) · \(quantity) units · \((Double(quantity) * product.unitCost).asUSD())",
                    time: "Just now",
                    isApproved: true,
                    createdAt: Date()
                )
                try? self.db.collection("activityEvents").document(event.id).setData(from: event)
            }
        } catch {
            print("Failed to encode reorder for \(updated.sku): \(error)")
        }
    }

    func createFollowUpTask(for order: Order) {
        createdFollowUpTaskForOrder.insert(order.id)
        guard !tasks.contains(where: { $0.relatedTo == order.id }) else { return }
        let task = TaskItem(title: "Follow up on \(order.id)", relatedTo: order.id, time: "Today", priority: .high)
        try? db.collection("tasks").document(task.id).setData(from: task)
    }

    var lowStockCount: Int {
        products.filter { $0.status == .lowStock }.count
    }

    var openOrdersCount: Int {
        orders.count
    }

    var needsAttentionCount: Int {
        lowStockCount + orders.filter { $0.status == .delayed }.count
    }

    var todayRun: AgentRun? { agentRuns.first }
    var yesterdayRun: AgentRun? { agentRuns.dropFirst().first }

    /// Notifications are derived live from current stock, order, and activity
    /// state rather than stored separately, so they always reflect reality and
    /// need no extra Firestore collection or seeding.
    var notifications: [AppNotification] {
        var items: [AppNotification] = []

        for product in products.filter({ $0.status == .lowStock }).sorted(by: { $0.stock < $1.stock }) {
            items.append(AppNotification(
                id: "lowstock-\(product.sku)",
                kind: .lowStock,
                title: "\(product.name) is low on stock",
                message: "\(product.stock) units left · minimum \(product.minimum)",
                createdAt: Date(),
                destination: .product(sku: product.sku)
            ))
        }

        for order in orders.filter({ $0.status == .delayed }) {
            items.append(AppNotification(
                id: "delayed-\(order.id)",
                kind: .delayedOrder,
                title: "Order \(order.id) needs follow-up",
                message: "The carrier update is overdue.",
                createdAt: Date(),
                destination: .order(id: order.id)
            ))
        }

        for event in activityEvents {
            items.append(AppNotification(
                id: "activity-\(event.id)",
                kind: .activity,
                title: event.title,
                message: event.subtitle,
                createdAt: event.createdAt,
                destination: .activity
            ))
        }

        return items.sorted { $0.createdAt > $1.createdAt }
    }

    var unreadNotificationCount: Int {
        notifications.filter { !readNotificationIDs.contains($0.id) }.count
    }

    func isNotificationRead(_ id: String) -> Bool {
        readNotificationIDs.contains(id)
    }

    func markNotificationRead(_ id: String) {
        guard readNotificationIDs.insert(id).inserted else { return }
        persistReadNotificationIDs()
    }

    func markAllNotificationsRead() {
        readNotificationIDs.formUnion(notifications.map(\.id))
        persistReadNotificationIDs()
    }

    private func persistReadNotificationIDs() {
        UserDefaults.standard.set(Array(readNotificationIDs), forKey: "readNotificationIDs")
    }

    /// Findings shown on the results screen: the on-device agent's output when
    /// available, otherwise the plain rule-based `findings` below.
    var displayedFindings: [AgentFinding] {
        latestAgentFindings ?? findings
    }

    /// Findings are computed live from current stock levels and order status,
    /// rather than stored separately, so they always reflect real data.
    var findings: [AgentFinding] {
        var results: [AgentFinding] = []

        for product in products.filter({ $0.status == .lowStock }).sorted(by: { $0.stock < $1.stock }) {
            let critical = product.stock <= product.minimum / 2
            results.append(AgentFinding(
                severity: critical ? .highPriority : .medium,
                title: critical ? "\(product.name) are critically low" : "\(product.name) are approaching minimum",
                factLabel: critical ? "FACT" : nil,
                factValue: critical ? "\(product.stock) units" : nil,
                copy: critical
                    ? "remain; your minimum is \(product.minimum)."
                    : "\(product.stock) units remain. Based on recent usage, stock may run low soon.",
                suggestion: critical ? "Review a reorder of \(product.minimum * 2) units to cover the next 14 days." : nil,
                destination: .product(sku: product.sku)
            ))
        }

        for order in orders.filter({ $0.status == .delayed }) {
            results.append(AgentFinding(
                severity: .highPriority,
                title: "Order \(order.id) needs follow-up",
                factLabel: nil,
                factValue: nil,
                copy: "The carrier update is overdue. I recommend contacting the customer today.",
                suggestion: nil,
                destination: .order(id: order.id)
            ))
        }

        return results
    }
}
