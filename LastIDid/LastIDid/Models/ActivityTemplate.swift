//
//  ActivityTemplate.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation

struct ActivityTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let suggestedReminderDays: Int?
    let category: String
    let icon: String

    static let allTemplates: [String: [ActivityTemplate]] = [
        "Home": [
            ActivityTemplate(id: "hvac_filter", name: "Change HVAC filter", suggestedReminderDays: 90, category: "Home", icon: "wind"),
            ActivityTemplate(id: "smoke_detector", name: "Test smoke detectors", suggestedReminderDays: 30, category: "Home", icon: "flame.fill"),
            ActivityTemplate(id: "water_filter", name: "Replace water filter", suggestedReminderDays: 180, category: "Home", icon: "drop.fill"),
            ActivityTemplate(id: "deep_clean", name: "Deep clean house", suggestedReminderDays: 90, category: "Home", icon: "sparkles"),
            ActivityTemplate(id: "fridge_clean", name: "Clean out refrigerator", suggestedReminderDays: 30, category: "Home", icon: "refrigerator.fill"),
            ActivityTemplate(id: "gutters", name: "Clean gutters", suggestedReminderDays: 180, category: "Home", icon: "house.fill"),
            ActivityTemplate(id: "dryer_vent", name: "Clean dryer vent", suggestedReminderDays: 365, category: "Home", icon: "wind"),
        ],
        "Health": [
            ActivityTemplate(id: "toothbrush", name: "Replace toothbrush", suggestedReminderDays: 90, category: "Health", icon: "mouth.fill"),
            ActivityTemplate(id: "dental", name: "Dental checkup", suggestedReminderDays: 180, category: "Health", icon: "face.smiling"),
            ActivityTemplate(id: "physical", name: "Annual physical", suggestedReminderDays: 365, category: "Health", icon: "heart.fill"),
            ActivityTemplate(id: "eye_exam", name: "Eye exam", suggestedReminderDays: 365, category: "Health", icon: "eye.fill"),
            ActivityTemplate(id: "flu_shot", name: "Flu shot", suggestedReminderDays: 365, category: "Health", icon: "syringe.fill"),
            ActivityTemplate(id: "dermatologist", name: "Skin check", suggestedReminderDays: 365, category: "Health", icon: "person.fill"),
            ActivityTemplate(id: "haircut", name: "Haircut", suggestedReminderDays: 42, category: "Health", icon: "scissors"),
        ],
        "Car": [
            ActivityTemplate(id: "oil_change", name: "Oil change", suggestedReminderDays: 90, category: "Car", icon: "drop.fill"),
            ActivityTemplate(id: "tire_rotation", name: "Rotate tires", suggestedReminderDays: 180, category: "Car", icon: "circle.grid.2x2.fill"),
            ActivityTemplate(id: "air_filter", name: "Replace cabin air filter", suggestedReminderDays: 365, category: "Car", icon: "wind"),
            ActivityTemplate(id: "car_wash", name: "Wash car", suggestedReminderDays: 14, category: "Car", icon: "car.fill"),
            ActivityTemplate(id: "tire_pressure", name: "Check tire pressure", suggestedReminderDays: 30, category: "Car", icon: "gauge.with.dots.needle.bottom.50percent"),
            ActivityTemplate(id: "wiper_blades", name: "Replace wiper blades", suggestedReminderDays: 180, category: "Car", icon: "windshield.front.and.wiper"),
            ActivityTemplate(id: "car_inspection", name: "Vehicle inspection", suggestedReminderDays: 365, category: "Car", icon: "checkmark.seal.fill"),
        ],
        "Digital": [
            ActivityTemplate(id: "backup", name: "Backup computer", suggestedReminderDays: 30, category: "Digital", icon: "externaldrive.fill"),
            ActivityTemplate(id: "password_update", name: "Update passwords", suggestedReminderDays: 90, category: "Digital", icon: "key.fill"),
            ActivityTemplate(id: "software_update", name: "System software updates", suggestedReminderDays: 30, category: "Digital", icon: "arrow.down.circle.fill"),
            ActivityTemplate(id: "photo_backup", name: "Backup photos", suggestedReminderDays: 30, category: "Digital", icon: "photo.fill"),
            ActivityTemplate(id: "subscription_review", name: "Review subscriptions", suggestedReminderDays: 90, category: "Digital", icon: "creditcard.fill"),
            ActivityTemplate(id: "clean_inbox", name: "Clean email inbox", suggestedReminderDays: 7, category: "Digital", icon: "envelope.fill"),
        ],
        "Finance": [
            ActivityTemplate(id: "credit_report", name: "Check credit report", suggestedReminderDays: 365, category: "Finance", icon: "doc.text.fill"),
            ActivityTemplate(id: "budget_review", name: "Review budget", suggestedReminderDays: 30, category: "Finance", icon: "chart.pie.fill"),
            ActivityTemplate(id: "investment_review", name: "Review investments", suggestedReminderDays: 90, category: "Finance", icon: "chart.line.uptrend.xyaxis"),
            ActivityTemplate(id: "insurance_review", name: "Review insurance policies", suggestedReminderDays: 365, category: "Finance", icon: "shield.fill"),
            ActivityTemplate(id: "bills_audit", name: "Audit recurring bills", suggestedReminderDays: 90, category: "Finance", icon: "dollarsign.circle.fill"),
        ],
        "Personal": [
            ActivityTemplate(id: "contact_friends", name: "Reach out to friends", suggestedReminderDays: 30, category: "Personal", icon: "person.2.fill"),
            ActivityTemplate(id: "journal", name: "Journal entry", suggestedReminderDays: 7, category: "Personal", icon: "book.fill"),
            ActivityTemplate(id: "goal_review", name: "Review personal goals", suggestedReminderDays: 90, category: "Personal", icon: "target"),
            ActivityTemplate(id: "closet_purge", name: "Purge closet", suggestedReminderDays: 180, category: "Personal", icon: "tshirt.fill"),
            ActivityTemplate(id: "donation", name: "Donate to charity", suggestedReminderDays: 30, category: "Personal", icon: "heart.fill"),
        ]
    ]

    static var allCategoriesOrdered: [String] {
        ["Home", "Health", "Car", "Digital", "Finance", "Personal"]
    }
}
