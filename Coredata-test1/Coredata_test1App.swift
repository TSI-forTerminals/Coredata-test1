//
//  Coredata_test1App.swift
//  Coredata-test1
//
//  Created by εε·δΈη on 2022/10/19.
//

import SwiftUI

@main
struct Coredata_test1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
