//
//  TradingAppApp.swift
//  TradingApp
//
//  SwiftUI Interface for Personal Trading System
//

import SwiftUI

@main
struct TradingAppApp: App {
    @StateObject private var tradingViewModel = TradingViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tradingViewModel)
                .onAppear {
                    tradingViewModel.initialize()
                }
        }
    }
}
