import FirebaseFirestore

/// Populates a brand-new Firestore project with the sample data from `MockData`
/// so the app isn't empty on first run. No-ops once the `products` collection has data.
enum FirestoreSeeder {
    enum Result {
        case seeded
        case alreadySeeded
        case failed(String)
    }

    static func seedIfNeeded(db: Firestore) async -> Result {
        do {
            let existing = try await db.collection("products").limit(to: 1).getDocuments()
            guard existing.documents.isEmpty else { return .alreadySeeded }

            let batch = db.batch()
            for product in MockData.products {
                try batch.setData(from: product, forDocument: db.collection("products").document(product.sku))
            }
            for order in MockData.orders {
                try batch.setData(from: order, forDocument: db.collection("orders").document(order.id))
            }
            for supplier in MockData.suppliers {
                try batch.setData(from: supplier, forDocument: db.collection("suppliers").document(supplier.id))
            }
            for task in MockData.initialTasks {
                try batch.setData(from: task, forDocument: db.collection("tasks").document(task.id))
            }
            for run in [MockData.todayRun, MockData.yesterdayRun] {
                try batch.setData(from: run, forDocument: db.collection("agentRuns").document(run.id))
            }
            for event in MockData.activityEvents {
                try batch.setData(from: event, forDocument: db.collection("activityEvents").document(event.id))
            }
            try batch.setData(from: Business.placeholder, forDocument: db.collection("settings").document("business"))
            try await batch.commit()
            return .seeded
        } catch {
            print("FirestoreSeeder failed: \(error)")
            return .failed(error.localizedDescription)
        }
    }
}
