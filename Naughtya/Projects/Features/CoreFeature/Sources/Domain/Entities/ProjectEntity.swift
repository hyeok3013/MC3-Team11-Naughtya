//
//  ProjectEntity.swift
//  CoreFeature
//
//  Created by byo on 2023/07/17.
//  Copyright © 2023 Naughtya. All rights reserved.
//

import Foundation

public class ProjectEntity: Codable, Equatable, Identifiable {
    public internal(set) var category: String
    public internal(set) var goals: String?
    public internal(set) var startedAt: Date?
    public internal(set) var endedAt: Date?
    public internal(set) var todos: [TodoEntity] = []
    public internal(set) var deletedTodos: [TodoEntity] = []
    public internal(set) var isSelected: Bool
    public internal(set) var isBookmarked: Bool

    public init(
        category: String,
        goals: String? = nil,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        todos: [TodoEntity] = [],
        deletedTodos: [TodoEntity] = [],
        isSelected: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.category = category
        self.goals = goals
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.todos = todos
        self.deletedTodos = deletedTodos
        self.isSelected = isSelected
        self.isBookmarked = isBookmarked
    }

    public var id: String {
        category
    }

    public var isEnded: Bool {
        guard let endedAt = endedAt else {
            return false
        }
        return endedAt.timeIntervalSinceNow < Date.now.timeIntervalSinceNow
    }

    public static func == (lhs: ProjectEntity, rhs: ProjectEntity) -> Bool {
        lhs === rhs
    }
}
