//
//  BucketDB.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.12.2023.
//

import ComposableArchitecture
import CoreData

// MARK: - API client interface

// Typically this interface would live in its own module, separate from the live implementation.
// This allows the feature to compile faster since it only depends on the interface.

@DependencyClient
struct BucketDB {
    var fetchBucketItems: () async throws -> [BucketItem]
    var createBucketItem: (BucketItem) async -> Void
    var updateBucketItem: (BucketItem) async -> Void
    var deleteBucketItem: (BucketItem) async -> Void
    var deleteAllBucketItems: () async throws -> Void
}

extension DependencyValues {
    var bucketDB: BucketDB {
        get { self[BucketDB.self] }
        set { self[BucketDB.self] = newValue }
    }
}

// MARK: - Live API implementation

extension BucketDB: DependencyKey {
    static let liveValue = BucketDB(
        fetchBucketItems: {
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<BucketItemEntity> = BucketItemEntity.fetchRequest()
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                let bucketItems = fetchedEntities.map { entity in
                    return BucketItem(
                        id: Int(entity.id),
                        name: entity.name!,
                        count: Int(entity.count),
                        categories: (entity.itemToCategory as? Set<BucketCategoryEntity>)?.compactMap { categoryEntity in
                            BucketCategory(
                                id: Int(categoryEntity.id),
                                name: categoryEntity.name!,
                                slug: categoryEntity.slug!,
                                emoji: categoryEntity.emoji!
                            )
                        } ?? []
                    )
                }
                print("✅ Successfully fetched items")
                return bucketItems
            } catch {
                print("❌ Couldn't fetch bucket items")
                return []
            }
        },
        createBucketItem: { bucketItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let entity = BucketItemEntity(context: viewContext)
            
            entity.id = Int16(bucketItem.id)
            entity.name = bucketItem.name
            entity.count = Int16(bucketItem.count)
            
            for category in bucketItem.categories {
                let categoryEntity = BucketCategoryEntity(context: viewContext)
                categoryEntity.id = Int16(category.id)
                categoryEntity.name = category.name
                categoryEntity.slug = category.slug
                categoryEntity.emoji = category.emoji
                entity.addToItemToCategory(categoryEntity)
            }
            
            do {
                try viewContext.save()
                print("✅ Successfully created bucket item")
            } catch {
                print("❌ Couldn't create bucket item")
            }
        },
        updateBucketItem: { bucketItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<BucketItemEntity> = BucketItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", bucketItem.id)
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                if let entity = fetchedEntities.first {
                    entity.name = bucketItem.name
                    entity.count = Int16(bucketItem.count)
                    
                    // Remove existing categories
                    if let existingCategories = entity.itemToCategory {
                        entity.removeFromItemToCategory(existingCategories)
                    }
                    
                    // Add updated categories
                    for category in bucketItem.categories {
                        let categoryEntity = BucketCategoryEntity(context: viewContext)
                        categoryEntity.id = Int16(category.id)
                        categoryEntity.name = category.name
                        categoryEntity.slug = category.slug
                        categoryEntity.emoji = category.emoji
                        entity.addToItemToCategory(categoryEntity)
                    }
                    
                    if viewContext.hasChanges {
                        try viewContext.save()
                    }
                    print("✅ Successfully updated bucket item")
                } else {
                    print("❌ Couldn't find bucket item with id: \(bucketItem.id)")
                }
            } catch {
                print("❌ Couldn't delete this item")
            }
        },
        deleteBucketItem: { bucketItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<BucketItemEntity> = BucketItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", bucketItem.id)
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                if let entity = fetchedEntities.first {
                    viewContext.delete(entity)
                    try viewContext.save()
                    print("✅ Successfully deleted item")
                } else {
                    print("❌ Couldn't find bucket item with id: \(bucketItem.id)")
                }
            } catch {
                print("❌ Couldn't delete this item")
            }
        },
        deleteAllBucketItems: {
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BucketItemEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(deleteRequest)
                try viewContext.save()
                print("✅ Successfully deleted all items")
            } catch {
                print("❌ Couldn't delete all items: \(error)")
            }
        }
    )
}

// MARK: - Test Implementation

extension BucketDB {
    static let testValue = BucketDB(
        fetchBucketItems: {
            return [
                BucketItem(id: 1, name: "Glass bottle", count: 1, categories: []),
                BucketItem(id: 2, name: "Plastic bottle", count: 2, categories: []),
                BucketItem(id: 3, name: "Paper", count: 3, categories: []),
                BucketItem(id: 4, name: "Food", count: 4, categories: []),
                BucketItem(id: 5, name: "Metal", count: 5, categories: [])
            ]
        },
        createBucketItem: { _ in },
        updateBucketItem: { _ in },
        deleteBucketItem: { _ in },
        deleteAllBucketItems: {}
    )
}
