import CoreData

protocol CoreDataStack {
    var writerContext: NSManagedObjectContext { get }
    var readerContext: NSManagedObjectContext { get }

    func save(_ completion: @escaping () -> ())
    func insertArticle(content: String)
}

extension CoreDataStack {
    func insertArticle(content: String) {
        writerContext.perform {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Article", into: self.writerContext)
            obj.setValue(content, forKey: "content")
        }
    }

    func fetchArticlesCount(result: @escaping (Int) -> ()) {
        self.readerContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Article")
            let count = (try? readerContext.count(for: request)) ?? 0
            result(count)
        }
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else {
            return
        }

        try! save()
    }
}
