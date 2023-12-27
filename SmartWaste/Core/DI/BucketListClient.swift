//
//  BucketListClient.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.12.2023.
//

import ComposableArchitecture
import CoreData

@DependencyClient
struct BucketListClient {
    var fetchBucketItems: () async throws -> [BucketItem]
    var createBucketItem: (BucketItem) async -> Void
    var updateBucketItem: (BucketItem) async -> Void
    var deleteBucketItem: (BucketItem) async -> Void
}

extension DependencyValues {
    var bucketListClient: BucketListClient {
        get { self[BucketListClient.self] }
        set { self[BucketListClient.self] = newValue }
    }
}

extension BucketListClient: DependencyKey {
    static let liveValue = BucketListClient(
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
            } catch {
                print("❌ Couldn't create bucket item")
            }
        },
        updateBucketItem: { bucketItem in
            let viewContext = CoreDataManager.shared.container.viewContext
            let fetchRequest: NSFetchRequest<BucketItemEntity> = BucketItemEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", bucketItem.id as CVarArg)
            
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
                    
                    try viewContext.save()
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
            fetchRequest.predicate = NSPredicate(format: "id == %@", bucketItem.id as CVarArg)
            
            do {
                let fetchedEntities = try viewContext.fetch(fetchRequest)
                if let entity = fetchedEntities.first {
                    viewContext.delete(entity)
                    try viewContext.save()
                } else {
                    print("❌ Couldn't find bucket item with id: \(bucketItem.id)")
                }
            } catch {
                print("❌ Couldn't delete this item")
            }
        }
    )
}

