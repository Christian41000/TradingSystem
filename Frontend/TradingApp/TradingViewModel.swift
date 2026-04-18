//
//  TradingViewModel.swift
//  TradingApp
//
//  ViewModel for Trading System
//

import Foundation
import Combine

class TradingViewModel: ObservableObject {
    @Published var account: Account = Account()
    @Published var orders: [Order] = []
    @Published var positions: [Position] = []
    @Published var isInitialized: Bool = false
    
    private var backend: TradingBackend?
    private var updateTimer: Timer?
    
    func initialize() {
        backend = TradingBackend()
        backend?.initializeAccount(
            accountId: "ACC-001",
            name: "Personal Trading Account",
            initialCash: 100000.0
        )
        
        refreshData()
        
        // Auto-refresh every 5 seconds (simulate market updates)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.simulateMarketUpdates()
            self?.refreshData()
        }
        
        isInitialized = true
    }
    
    func refreshData() {
        guard let backend = backend else { return }
        
        account = backend.getAccount()
        orders = backend.getOrders()
        positions = backend.getPositions()
    }
    
    func submitMarketOrder(symbol: String, side: OrderSide, quantity: Double) {
        guard let backend = backend else { return }
        
        _ = backend.submitOrder(
            symbol: symbol,
            type: .market,
            side: side,
            quantity: quantity
        )
        
        refreshData()
    }
    
    func submitLimitOrder(symbol: String, side: OrderSide, quantity: Double, price: Double) {
        guard let backend = backend else { return }
        
        _ = backend.submitOrder(
            symbol: symbol,
            type: .limit,
            side: side,
            quantity: quantity,
            price: price
        )
        
        refreshData()
    }
    
    func cancelOrder(orderId: String) {
        guard let backend = backend else { return }
        
        _ = backend.cancelOrder(orderId: orderId)
        refreshData()
    }
    
    private func simulateMarketUpdates() {
        guard let backend = backend else { return }
        
        // Simulate price changes for common symbols
        let symbols = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN"]
        
        for symbol in symbols {
            let basePrice: Double = [
                "AAPL": 175.0,
                "GOOGL": 140.0,
                "MSFT": 380.0,
                "TSLA": 250.0,
                "AMZN": 180.0
            ][symbol] ?? 100.0
            
            // Random fluctuation ±2%
            let fluctuation = Double.random(in: -0.02...0.02)
            let newPrice = basePrice * (1 + fluctuation)
            
            backend.updateMarketPrice(symbol: symbol, price: newPrice)
        }
    }
}
