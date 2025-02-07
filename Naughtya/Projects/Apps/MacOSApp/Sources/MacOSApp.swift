//
//  MacOSApp.swift
//  MacOSApp
//
//  Created by byo on 2023/07/15.
//  Copyright © 2023 Naughtya. All rights reserved.
//

import SwiftUI
import MacOSCoreFeature

@main
struct MacOSApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                TabView {
                    DashboardView()
                        .tabItem {
                            Text("홈")
                        }
                    ProjectResultListView()
                        .tabItem {
                            Text("완료(성과)")
                        }
                    ChatView()
                        .tabItem {
                            Text("테스트")
                        }
                    TestView()
                        .tabItem {
                            Text("테스트2")
                        }
                }
                DragDropStageView()
            }
        }
    }
}
