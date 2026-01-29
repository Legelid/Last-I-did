//
//  ActivityEntity.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import AppIntents
import SwiftData

struct ActivityEntity: AppEntity {
    var id: UUID
    var name: String
    var daysSince: Int

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Activity")
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var defaultQuery = ActivityEntityQuery()
}

struct ActivityEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [ActivityEntity] {
        await MainActor.run {
            let container = try? ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
            guard let context = container?.mainContext else { return [] }

            // Fetch all and filter in memory to avoid predicate capture issues
            let descriptor = FetchDescriptor<Activity>()
            guard let activities = try? context.fetch(descriptor) else { return [] }

            let identifierSet = Set(identifiers)
            return activities
                .filter { identifierSet.contains($0.id) }
                .map { activity in
                    ActivityEntity(
                        id: activity.id,
                        name: activity.name,
                        daysSince: activity.daysSinceLastCompleted
                    )
                }
        }
    }

    func suggestedEntities() async throws -> [ActivityEntity] {
        await MainActor.run {
            let container = try? ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
            guard let context = container?.mainContext else { return [] }

            // Fetch all and filter in memory
            let descriptor = FetchDescriptor<Activity>()
            guard let activities = try? context.fetch(descriptor) else { return [] }

            return activities
                .filter { !$0.isArchived }
                .map { activity in
                    ActivityEntity(
                        id: activity.id,
                        name: activity.name,
                        daysSince: activity.daysSinceLastCompleted
                    )
                }
        }
    }
}

// Make ActivityEntity conform to EntityStringQuery for Siri voice matching
extension ActivityEntityQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [ActivityEntity] {
        await MainActor.run {
            let container = try? ModelContainer(for: Activity.self, CompletionRecord.self, Category.self)
            guard let context = container?.mainContext else { return [] }

            // Fetch all and filter in memory
            let descriptor = FetchDescriptor<Activity>()
            guard let activities = try? context.fetch(descriptor) else { return [] }

            return activities
                .filter { !$0.isArchived && $0.name.localizedCaseInsensitiveContains(string) }
                .map { activity in
                    ActivityEntity(
                        id: activity.id,
                        name: activity.name,
                        daysSince: activity.daysSinceLastCompleted
                    )
                }
        }
    }
}
