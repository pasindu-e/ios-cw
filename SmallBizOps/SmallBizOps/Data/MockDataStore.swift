import SwiftUI

@MainActor
final class MockDataStore: ObservableObject {
    @Published var products: [Product] = MockData.products
    @Published var orders: [Order] = MockData.orders
    @Published var tasks: [TaskItem] = MockData.initialTasks
    @Published var faceIDEnabled: Bool = true
    @Published var lastReorderApproval: (product: String, quantity: Int, total: Double)? = nil
    @Published var createdFollowUpTaskForOrder: Set<String> = []

    func product(sku: String) -> Product? {
        products.first { $0.sku == sku }
    }

    func order(id: String) -> Order? {
        orders.first { $0.id == id }
    }

    func toggleTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func approveReorder(product: Product, quantity: Int) {
        lastReorderApproval = (product.name, quantity, Double(quantity) * product.unitCost)
    }

    func createFollowUpTask(for order: Order) {
        createdFollowUpTaskForOrder.insert(order.id)
        let alreadyExists = tasks.contains { $0.relatedTo == order.id }
        if !alreadyExists {
            tasks.insert(TaskItem(title: "Follow up on \(order.id)", relatedTo: order.id, time: "Today", priority: .high), at: 0)
        }
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
}
