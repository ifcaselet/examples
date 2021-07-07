import CoreData

protocol CoreDataStack {
    var writerContext: NSManagedObjectContext { get }

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
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else {
            return
        }

        try! save()
    }
}
