//
//  Meal.swift
//  Momentum
//  Domain model for meal tracking
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation

struct Meal: Identifiable, Codable {
    let id: UUID
    var date: Date
    var name: String
    var mealType: MealType
    
    // Macros
    var calories: Int
    var protein: Int // grams
    var carbs: Int? // grams
    var fats: Int? // grams
    
    // Optional details
    var notes: String?
    var foodItems: [FoodItem]
    
    // Metadata
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String,
        mealType: MealType,
        calories: Int = 0,
        protein: Int = 0,
        carbs: Int? = nil,
        fats: Int? = nil,
        notes: String? = nil,
        foodItems: [FoodItem] = [],
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.mealType = mealType
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.notes = notes
        self.foodItems = foodItems
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Food Item Model

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var servings: Double
    var servingSize: String
    var calories: Int
    var protein: Int
    var carbs: Int?
    var fats: Int?
    
    init(
        id: UUID = UUID(),
        name: String,
        servings: Double = 1.0,
        servingSize: String = "serving",
        calories: Int = 0,
        protein: Int = 0,
        carbs: Int? = nil,
        fats: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.servings = servings
        self.servingSize = servingSize
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
    }
}

// MARK: - Supporting Enums

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snack: return 3
        }
    }
}

// MARK: - Helper Extensions

extension Meal {
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var macroSummary: String {
        var summary = "\(calories) cal • \(protein)g protein"
        if let carbs = carbs {
            summary += " • \(carbs)g carbs"
        }
        if let fats = fats {
            summary += " • \(fats)g fat"
        }
        return summary
    }
}

// MARK: - Macro Totals Helper

struct MacroTotals {
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fats: Int = 0
    
    mutating func add(_ meal: Meal) {
        calories += meal.calories
        protein += meal.protein
        carbs += meal.carbs ?? 0
        fats += meal.fats ?? 0
    }
}
