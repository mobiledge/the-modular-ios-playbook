import Foundation
import CoreData

/// A saved item in the user's local library. This is the app-facing value type;
/// the Core Data `NSManagedObject` representation stays hidden inside the manager.
struct SavedItem: Identifiable, Hashable {
    let id: Int64
    let title: String
    let subtitle: String?
    let artworkURL: String?
    let mediaType: String   // "music" | "movie" | "audiobook"
    let savedAt: Date
}

/// The app's local persistence layer, backed by Core Data.
///
/// The Core Data model is defined *programmatically* (no `.xcdatamodeld` file),
/// which keeps the monolith buildable from plain source files.
///
/// MONOLITH NOTE: like the API client, this is a global singleton that views
/// and even table cells reach into directly. The Database layer is extracted
/// into its own module in Chapter 3 (Domain & Infrastructure).
final class CoreDataManager {
    static let shared = CoreDataManager()

    private static let entityName = "SavedItemEntity"
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    private init() {
        let model = CoreDataManager.makeModel()
        container = NSPersistentContainer(name: "iTunesSearchApp", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error {
                Logger.log("Core Data failed to load store: \(error)")
            }
        }
    }

    // MARK: - Programmatic model

    private static func makeModel() -> NSManagedObjectModel {
        func attribute(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = optional
            return attribute
        }

        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            attribute("id", .integer64AttributeType),
            attribute("title", .stringAttributeType),
            attribute("subtitle", .stringAttributeType, optional: true),
            attribute("artworkURL", .stringAttributeType, optional: true),
            attribute("mediaType", .stringAttributeType),
            attribute("savedAt", .dateAttributeType)
        ]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }

    // MARK: - CRUD

    func save(_ item: SavedItem) {
        guard !isSaved(id: item.id, mediaType: item.mediaType) else { return }
        guard let entity = container.managedObjectModel.entitiesByName[Self.entityName] else { return }

        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(item.id, forKey: "id")
        object.setValue(item.title, forKey: "title")
        object.setValue(item.subtitle, forKey: "subtitle")
        object.setValue(item.artworkURL, forKey: "artworkURL")
        object.setValue(item.mediaType, forKey: "mediaType")
        object.setValue(item.savedAt, forKey: "savedAt")
        saveContext()
    }

    func remove(id: Int64, mediaType: String) {
        let request = fetchRequest(id: id, mediaType: mediaType)
        if let results = try? context.fetch(request) {
            results.forEach(context.delete)
            saveContext()
        }
    }

    func isSaved(id: Int64, mediaType: String) -> Bool {
        let request = fetchRequest(id: id, mediaType: mediaType)
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }

    func fetchAll() -> [SavedItem] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
        let objects = (try? context.fetch(request)) ?? []
        return objects.map { object in
            SavedItem(
                id: object.value(forKey: "id") as? Int64 ?? 0,
                title: object.value(forKey: "title") as? String ?? "",
                subtitle: object.value(forKey: "subtitle") as? String,
                artworkURL: object.value(forKey: "artworkURL") as? String,
                mediaType: object.value(forKey: "mediaType") as? String ?? "",
                savedAt: object.value(forKey: "savedAt") as? Date ?? Date()
            )
        }
    }

    // MARK: - Helpers

    private func fetchRequest(id: Int64, mediaType: String) -> NSFetchRequest<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.predicate = NSPredicate(format: "id == %lld AND mediaType == %@", id, mediaType)
        return request
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Logger.log("Core Data save error: \(error)")
        }
    }
}
