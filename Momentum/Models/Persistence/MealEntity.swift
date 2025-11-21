//
//  MealEntity.swift
//  Momentum
//  SwiftData persistence model for Meal
//
//  Created by Oved Ramirez on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class MealEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var name: String
    var mealTypeRaw: String
    
    var calories: Int
    var protein: Int
    var carbs: Int?
    var fats: Int?
    
    var notes: String?
    
    @Relationship(deleteRule: .cascade)
    var foodItems: [FoodItemEntity]?
    
    var createdAt: Date
    var lastUpdated: Date
    
    init(from meal: Meal) {
        self.id = meal.id
        self.date = meal.date
        self.name = meal.name
        self.mealTypeRaw = meal.mealType.rawValue
        self.calories = meal.calories
        self.protein = meal.protein
        self.carbs = meal.carbs
        self.fats = meal.fats
        self.notes = meal.notes
        self.foodItems = meal.foodItems.map { FoodItemEntity(from: $0) }
        self.createdAt = meal.createdAt
        self.lastUpdated = meal.lastUpdated
    }
    
    func toDomain() -> Meal {
        Meal(
            id: id,
            date: date,
            name: name,
            mealType: MealType(rawValue: mealTypeRaw) ?? .breakfast,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats,
            notes: notes,
            foodItems: foodItems?.map { $0.toDomain() } ?? [],
            createdAt: createdAt,
            lastUpdated: lastUpdated
        )
    }
}

@Model
final class FoodItemEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var servings: Double
    var servingSize: String
    var calories: Int
    var protein: Int
    var carbs: Int?
    var fats: Int?
    
    init(from foodItem: FoodItem) {
        self.id = foodItem.id
        self.name = foodItem.name
        self.servings = foodItem.servings
        self.servingSize = foodItem.servingSize
        self.calories = foodItem.calories
        self.protein = foodItem.protein
        self.carbs = foodItem.carbs
        self.fats = foodItem.fats
    }
    
    func toDomain() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            servings: servings,
            servingSize: servingSize,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats
        )
    }
}
