//
//  DailyTodoListViewModel.swift
//  CoreFeature
//
//  Created by byo on 2023/07/19.
//  Copyright © 2023 Naughtya. All rights reserved.
//

import Foundation
import Combine

@MainActor
public final class DailyTodoListViewModel: ObservableObject {
    private static let dailyTodoListStore: DailyTodoListStore = .shared
    private static let dailyTodoListUseCase: DailyTodoListUseCase = MockDailyTodoListUseCase()

    @Published public var dailyTodoList: DailyTodoListModel?
    private var isTodayFetched = false
    private var cancellable = Set<AnyCancellable>()

    public init() {
        setupFetchingData()
    }

    public var dateTitle: String {
        dailyTodoList?.dateTitle ?? ""
    }

    public func fetchTodayIfNeeded() {
        guard !isTodayFetched else {
            return
        }
        isTodayFetched = true
        let dateString = Date.today.getDateString()
        fetchDailyTodoList(dateString: dateString)
    }

    public func gotoOneDayBefore() {
        guard let oneDayBefore = dailyTodoList?.date.getOneDayBefore() else {
            return
        }
        fetchDailyTodoList(dateString: oneDayBefore.getDateString())
    }

    public func gotoOneDayAfter() {
        guard let oneDayAfter = dailyTodoList?.date.getOneDayAfter() else {
            return
        }
        fetchDailyTodoList(dateString: oneDayAfter.getDateString())
    }

    private func setupFetchingData() {
        Self.dailyTodoListStore.objectWillChange
            .debounce(
                for: .milliseconds(10),
                scheduler: DispatchQueue.global(qos: .userInitiated)
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [unowned self] _ in
                guard let dateString = dailyTodoList?.dateString else {
                    return
                }
                fetchDailyTodoList(dateString: dateString)
            }
            .store(in: &cancellable)
    }

    private func fetchDailyTodoList(dateString: String) {
        Task {
            if let existing = try await Self.dailyTodoListUseCase.readByDate(dateString: dateString) {
                dailyTodoList = .from(entity: existing)
            } else {
                let new = try await Self.dailyTodoListUseCase.create(dateString: dateString)
                dailyTodoList = .from(entity: new)
            }
        }
    }
}
