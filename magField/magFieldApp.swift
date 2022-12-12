//
//  magFieldApp.swift
//  magField
//
//  Created by J Lambert on 05/12/2022.
//

import SwiftUI
import CoreMotion


@main
struct magFieldApp: App {
        
    @ObservedObject
    var viewModel = MagFieldVM()

    var body: some Scene {
        WindowGroup {
            ContentView(model: viewModel)
        }
    }
}
