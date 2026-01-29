//
//  RoomTemplate.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/22/26.
//

import Foundation

struct RoomTemplate: Identifiable {
    let id = UUID()
    let roomName: String
    let emoji: String
    let description: String
    let activities: [TemplateActivity]
}

struct TemplateActivity: Identifiable {
    let id = UUID()
    let name: String
    let suggestedEmoji: String?
    let suggestedFrequency: String?  // Informational only, NOT enforced
    let categoryName: String  // Matches existing Category.name for assignment
}

struct RoomTemplateData {
    static let allRooms: [RoomTemplate] = [kitchen, bathroom, livingRoom, bedroom, laundryUtility]

    // MARK: - Kitchen Template

    static let kitchen = RoomTemplate(
        roomName: "Kitchen",
        emoji: "🍽️",
        description: "Common kitchen maintenance activities",
        activities: [
            TemplateActivity(name: "Do dishes", suggestedEmoji: "🧼", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Load dishwasher", suggestedEmoji: "🍽️", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Unload dishwasher", suggestedEmoji: "🍽️", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Wipe counters", suggestedEmoji: "✨", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Wipe stove top", suggestedEmoji: "🔥", suggestedFrequency: "Often done after cooking", categoryName: "Home"),
            TemplateActivity(name: "Take out trash", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done every few days", categoryName: "Home"),
            TemplateActivity(name: "Put away clean dishes", suggestedEmoji: "🍽️", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Sweep floor", suggestedEmoji: "🧹", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Mop floor", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean sink", suggestedEmoji: "💧", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Empty fridge of leftovers", suggestedEmoji: "🥡", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean microwave", suggestedEmoji: "📻", suggestedFrequency: "Usually done every few weeks", categoryName: "Home"),
            TemplateActivity(name: "Refill paper towels", suggestedEmoji: "🧻", suggestedFrequency: "As needed", categoryName: "Home"),
            TemplateActivity(name: "Check trash or recycling", suggestedEmoji: "♻️", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean fridge shelves", suggestedEmoji: "🧊", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe cabinet fronts", suggestedEmoji: "🚪", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean oven", suggestedEmoji: "🔥", suggestedFrequency: "Often done every few months", categoryName: "Home"),
            TemplateActivity(name: "Clean dishwasher filter", suggestedEmoji: "🔧", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Organize pantry", suggestedEmoji: "📦", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe backsplash", suggestedEmoji: "✨", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Check expiration dates", suggestedEmoji: "📅", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean range hood", suggestedEmoji: "💨", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Deep clean freezer", suggestedEmoji: "🧊", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wash trash can", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Replace sponge or scrubbers", suggestedEmoji: "🧽", suggestedFrequency: "As needed", categoryName: "Home")
        ]
    )

    // MARK: - Bathroom Template

    static let bathroom = RoomTemplate(
        roomName: "Bathroom",
        emoji: "🚿",
        description: "Common bathroom cleaning and maintenance",
        activities: [
            TemplateActivity(name: "Wipe sink", suggestedEmoji: "🚰", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Wipe mirror", suggestedEmoji: "🪞", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Hang towels", suggestedEmoji: "🧺", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Pick up floor", suggestedEmoji: "🧹", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Empty trash", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean toilet", suggestedEmoji: "🚽", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean shower", suggestedEmoji: "🚿", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean bathtub", suggestedEmoji: "🛁", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean bathroom sink", suggestedEmoji: "🚰", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Mop bathroom floor", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Replace towels", suggestedEmoji: "🧺", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Refill toilet paper", suggestedEmoji: "🧻", suggestedFrequency: "As needed", categoryName: "Home"),
            TemplateActivity(name: "Clean shower drain", suggestedEmoji: "💧", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wash bath mats", suggestedEmoji: "🧺", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean soap dispensers", suggestedEmoji: "🧴", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe cabinets", suggestedEmoji: "🚪", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean toilet brush", suggestedEmoji: "🧹", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Replace shower curtain liner", suggestedEmoji: "🚿", suggestedFrequency: "Often done every few months", categoryName: "Home"),
            TemplateActivity(name: "Clean grout", suggestedEmoji: "🧽", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Deep clean shower tiles", suggestedEmoji: "✨", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Check for mold or mildew", suggestedEmoji: "🔍", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean exhaust fan", suggestedEmoji: "💨", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Reorganize toiletries", suggestedEmoji: "🧴", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Replace toothbrushes", suggestedEmoji: "🪥", suggestedFrequency: "Usually every 3 months", categoryName: "Health"),
            TemplateActivity(name: "Wash bathroom trash can", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done monthly", categoryName: "Home")
        ]
    )

    // MARK: - Living Room Template

    static let livingRoom = RoomTemplate(
        roomName: "Living Room",
        emoji: "🛋️",
        description: "Common living room cleaning and tidying",
        activities: [
            TemplateActivity(name: "Pick up clutter", suggestedEmoji: "🧹", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Straighten pillows", suggestedEmoji: "🛋️", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Fold blankets", suggestedEmoji: "🧺", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Clear surfaces", suggestedEmoji: "✨", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Put items away", suggestedEmoji: "📦", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Dust surfaces", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Vacuum floor", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Vacuum couch", suggestedEmoji: "🛋️", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe coffee table", suggestedEmoji: "☕", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean TV screen", suggestedEmoji: "📺", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Empty living room trash", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Dust baseboards", suggestedEmoji: "🧹", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean windows", suggestedEmoji: "🪟", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wipe light switches", suggestedEmoji: "💡", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe remote controls", suggestedEmoji: "📺", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Organize shelves", suggestedEmoji: "📚", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Rotate cushions", suggestedEmoji: "🛋️", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean under furniture", suggestedEmoji: "🧹", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wash throw blankets", suggestedEmoji: "🧺", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wash pillow covers", suggestedEmoji: "🧺", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Deep clean rugs", suggestedEmoji: "🧹", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean vents", suggestedEmoji: "💨", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Check cords and cables", suggestedEmoji: "🔌", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Reorganize storage bins", suggestedEmoji: "📦", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Declutter items", suggestedEmoji: "♻️", suggestedFrequency: "Often done seasonally", categoryName: "Home")
        ]
    )

    // MARK: - Bedroom Template

    static let bedroom = RoomTemplate(
        roomName: "Bedroom",
        emoji: "🛏️",
        description: "Common bedroom cleaning and maintenance",
        activities: [
            TemplateActivity(name: "Make bed", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done daily", categoryName: "Home"),
            TemplateActivity(name: "Pick up clothes", suggestedEmoji: "👕", suggestedFrequency: "Often done daily", categoryName: "Home"),
            TemplateActivity(name: "Put away laundry", suggestedEmoji: "🧺", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clear nightstand", suggestedEmoji: "🕯️", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Air out room", suggestedEmoji: "💨", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Change sheets", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done every 1-2 weeks", categoryName: "Home"),
            TemplateActivity(name: "Dust bedroom surfaces", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Vacuum bedroom floor", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Empty bedroom trash", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Wipe mirrors", suggestedEmoji: "🪞", suggestedFrequency: "Often done weekly", categoryName: "Home"),
            TemplateActivity(name: "Wash pillows", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Rotate mattress", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean under bed", suggestedEmoji: "🧹", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Organize dresser", suggestedEmoji: "👕", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Declutter closet", suggestedEmoji: "👔", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wash comforter", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean bedroom baseboards", suggestedEmoji: "🧹", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Wipe door handles", suggestedEmoji: "🚪", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean light fixtures", suggestedEmoji: "💡", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Reorganize bedside items", suggestedEmoji: "📚", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Swap seasonal clothes", suggestedEmoji: "👕", suggestedFrequency: "Usually twice a year", categoryName: "Personal"),
            TemplateActivity(name: "Check smoke detector", suggestedEmoji: "🔥", suggestedFrequency: "Usually done every few months", categoryName: "Home"),
            TemplateActivity(name: "Wash curtains", suggestedEmoji: "🪟", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean bedroom vents", suggestedEmoji: "💨", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Donate unused clothes", suggestedEmoji: "♻️", suggestedFrequency: "Often done seasonally", categoryName: "Personal")
        ]
    )

    // MARK: - Laundry / Utility Template

    static let laundryUtility = RoomTemplate(
        roomName: "Laundry / Utility",
        emoji: "🧺",
        description: "Common laundry and utility area activities",
        activities: [
            TemplateActivity(name: "Start laundry", suggestedEmoji: "🧺", suggestedFrequency: "Often done a few times a week", categoryName: "Home"),
            TemplateActivity(name: "Move laundry to dryer", suggestedEmoji: "🔄", suggestedFrequency: "Often done after washing", categoryName: "Home"),
            TemplateActivity(name: "Fold laundry", suggestedEmoji: "👕", suggestedFrequency: "Often done after drying", categoryName: "Home"),
            TemplateActivity(name: "Put laundry away", suggestedEmoji: "📦", suggestedFrequency: "Often done after folding", categoryName: "Home"),
            TemplateActivity(name: "Empty lint trap", suggestedEmoji: "🔥", suggestedFrequency: "Usually after each load", categoryName: "Home"),
            TemplateActivity(name: "Wash towels", suggestedEmoji: "🧺", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Wash bedding", suggestedEmoji: "🛏️", suggestedFrequency: "Usually done every 1-2 weeks", categoryName: "Home"),
            TemplateActivity(name: "Clean laundry surfaces", suggestedEmoji: "✨", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Sweep laundry room floor", suggestedEmoji: "🧹", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Empty laundry room trash", suggestedEmoji: "🗑️", suggestedFrequency: "Usually done weekly", categoryName: "Home"),
            TemplateActivity(name: "Clean washing machine", suggestedEmoji: "🧼", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Clean dryer vent", suggestedEmoji: "💨", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wipe washer and dryer exterior", suggestedEmoji: "✨", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Organize laundry supplies", suggestedEmoji: "🧴", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Restock detergent", suggestedEmoji: "🧴", suggestedFrequency: "As needed", categoryName: "Home"),
            TemplateActivity(name: "Deep clean utility sink", suggestedEmoji: "🚰", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Check hoses", suggestedEmoji: "🔧", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Clean behind machines", suggestedEmoji: "🧹", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Declutter storage shelves", suggestedEmoji: "📦", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Wash laundry baskets", suggestedEmoji: "🧺", suggestedFrequency: "Usually done monthly", categoryName: "Home"),
            TemplateActivity(name: "Replace dryer sheets", suggestedEmoji: "🧺", suggestedFrequency: "As needed", categoryName: "Home"),
            TemplateActivity(name: "Clean floor drains", suggestedEmoji: "💧", suggestedFrequency: "Usually done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Check for water leaks", suggestedEmoji: "💧", suggestedFrequency: "Often done monthly", categoryName: "Home"),
            TemplateActivity(name: "Review laundry schedule", suggestedEmoji: "📅", suggestedFrequency: "Often done seasonally", categoryName: "Home"),
            TemplateActivity(name: "Replace worn supplies", suggestedEmoji: "🔄", suggestedFrequency: "As needed", categoryName: "Home")
        ]
    )
}
