//
//  TodoItemView.swift
//  CoreFeature
//
//  Created by byo on 2023/07/18.
//  Copyright © 2023 Naughtya. All rights reserved.
//

import SwiftUI

public struct TodoItemView: View {
    private static let dailyTodoListStore: DailyTodoListStore = .shared
    private static let dailyTodoListUseCase: DailyTodoListUseCase = MockDailyTodoListUseCase()
    private static let todoUseCase: TodoUseCase = MockTodoUseCase()

    public let todo: TodoModel
    public let isBacklog: Bool
    public let isDummy: Bool
    public let isBlockedToEdit: Bool
    public let dragDropDelegate: DragDropDelegate
    @State private var title: String
    @State private var absoluteRect: CGRect!
    @State private var isHovered = false
    @State private var isBeingDragged = false

    public init(
        todo: TodoModel,
        isBacklog: Bool = false,
        isDummy: Bool = false,
        isBlockedToEdit: Bool = false,
        dragDropDelegate: DragDropDelegate = DragDropManager.shared
    ) {
        self.todo = todo
        self.isBacklog = isBacklog
        self.isDummy = isDummy
        self.isBlockedToEdit = isBlockedToEdit
        self.dragDropDelegate = dragDropDelegate
        self.title = todo.title
    }

    public var body: some View {
        GeometryReader { geometry in
            let absoluteRect = geometry.frame(in: .global)
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Text("🖱️")
                        .opacity(isHovered ? 1 : 0)
                        .animation(.easeOut, value: isHovered)
                    Button(todo.isCompleted ? "✅" : "◻️") {
                        toggleCompleted()
                    }
                    .buttonStyle(.borderless)
                    if !isBacklog {
                        Text("[\(todo.category)]")
                            .font(.headline)
                    }
                    ZStack {
                        TextField(text: $title) {
                            placeholder
                        }
                        .textFieldStyle(.plain)
                        Color.white
                            .opacity(isBlockedToEdit ? 0.01 : 0)
                    }
                    Button("🔄") {
                        toggleDaily()
                    }
                    .buttonStyle(.borderless)
                    Button("🚮") {
                        delete()
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                Spacer()
            }
            .onAppear {
                registerAbsoluteRect(absoluteRect)
            }
            .onChange(of: absoluteRect) {
                guard !(isBeingDragged || isDummy) else {
                    return
                }
                registerAbsoluteRect($0)
            }
            .onChange(of: isBeingDragged) {
                guard !$0 else {
                    return
                }
                registerAbsoluteRect(absoluteRect)
            }
        }
        .frame(height: 40)
        .background(.white)
        .opacity(opacity)
        .gesture(
            DragGesture()
                .onChanged {
                    let itemLocation = absoluteRect.origin + $0.location - $0.startLocation
                    if !isBeingDragged {
                        dragDropDelegate.startToDrag(
                            todo.entity,
                            size: absoluteRect.size,
                            itemLocation: itemLocation
                        )
                    } else {
                        dragDropDelegate.drag(
                            todo.entity,
                            itemLocation: itemLocation
                        )
                    }
                    isBeingDragged = true
                }
                .onEnded {
                    dragDropDelegate.drop(
                        todo.entity,
                        touchLocation: absoluteRect.origin + $0.location
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isBeingDragged = false
                    }
                }
        )
        .onHover {
            isHovered = $0
        }
        .onSubmit {
            updateTitle()
        }
        .onDisappear {
            dragDropDelegate.unregisterAbsoluteRect(todo.entity)
        }
    }

    private var placeholder: some View {
        Text("Todo")
            .foregroundColor(.gray)
    }

    private var opacity: CGFloat {
        if isDummy || isBeingDragged {
            return 0.5
        } else {
            return 1
        }
    }

    private func registerAbsoluteRect(_ rect: CGRect) {
        absoluteRect = rect
        dragDropDelegate.registerAbsoluteRect(
            todo.entity,
            rect: rect
        )
    }

    private func updateTitle() {
        Task {
            try await Self.todoUseCase.update(
                todo.entity,
                title: title
            )
        }
    }

    private func toggleDaily() {
        Task {
            if todo.entity.isDaily {
                try await Self.dailyTodoListUseCase.removeTodoFromDaily(todo.entity)
            } else {
                try await Self.dailyTodoListUseCase.addTodoToDaily(
                    todo: todo.entity,
                    dailyTodoList: Self.dailyTodoListStore.currentDailyTodoList
                )
            }
        }
    }

    private func toggleCompleted() {
        Task {
            if todo.entity.isCompleted {
                try await Self.todoUseCase.undoCompleted(todo.entity)
            } else {
                try await Self.todoUseCase.complete(
                    todo.entity,
                    date: .now
                )
            }
        }
    }

    private func delete() {
        Task {
            try await Self.todoUseCase.delete(todo.entity)
        }
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemView(todo: .from(entity: TodoEntity.sample))
    }
}
