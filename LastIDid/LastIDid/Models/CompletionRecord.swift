//
//  CompletionRecord.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import SwiftData

@Model
final class CompletionRecord {
    var id: UUID
    var completedDate: Date         // When the activity was done
    var recordedDate: Date          // When logged (for backdating detection)
    var notes: String?              // Per-completion notes
    var wasBackdated: Bool
    var activity: Activity?

    init(completedDate: Date = Date(), notes: String? = nil, wasBackdated: Bool = false) {
        self.id = UUID()
        self.completedDate = completedDate
        self.recordedDate = Date()
        self.notes = notes
        self.wasBackdated = wasBackdated
    }
}
