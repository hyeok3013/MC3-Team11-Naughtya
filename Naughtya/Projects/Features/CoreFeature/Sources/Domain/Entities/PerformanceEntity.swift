//
//  PerformanceEntity.swift
//  CoreFeature
//
//  Created by byo on 2023/07/17.
//  Copyright © 2023 Naughtya. All rights reserved.
//

import Foundation

public struct PerformanceEntity: Codable, Equatable {
    public let category: PerformanceCategory
    public let title: String
    public let todos: [TodoEntity]
}
