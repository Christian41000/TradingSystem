//
//  TradingBackend.swift
//  TradingApp
//
//  Swift interface to C++ Trading Backend
//

import Foundation

// MARK: - C Types Mapping

enum COrderType: UInt32 {
    case market = 0
    case limit = 1
    case stopLoss = 2
    case stopLimit = 3
}

enum COrderSide: UInt32 {
    case buy = 0
    case sell = 1
}

enum COrderStatus: UInt32 {
    case pending = 0
    case submitted = 1
    case partiallyFilled = 2
    case filled = 3
    case cancelled = 4
    case rejected = 5
}

struct COrder {
    var id: UnsafePointer<CChar>?
    var symbol: UnsafePointer<CChar>?
    var type: COrderType
    var side: COrderSide
    var quantity: Double
    var price: Double
    var stopPrice: Double
    var status: COrderStatus
    var filledQuantity: Double
    var averageFillPrice: Double
}

struct CPosition {
    var symbol: UnsafePointer<CChar>?
    var quantity: Double
    var averageEntryPrice: Double
    var currentPrice: Double
    var unrealizedPnL: Double
    var realizedPnL: Double
}

struct CAccount {
    var id: UnsafePointer<CChar>?
    var name: UnsafePointer<CChar>?
    var cashBalance: Double
    var buyingPower: Double
    var portfolioValue: Double
    var totalEquity: Double
}

// MARK: - C++ Bridge Functions

@_silgen_name("create_broker_engine")
func create_broker_engine() -> UnsafeMutableRawPointer?

@_silgen_name("destroy_broker_engine")
func destroy_broker_engine(_ handle: UnsafeMutableRawPointer?)

@_silgen_name("initialize_account")
func initialize_account(_ handle: UnsafeMutableRawPointer?, 
                        _ accountId: UnsafePointer<CChar>?, 
                        _ name: UnsafePointer<CChar>?, 
                        _ initialCash: Double)

@_silgen_name("get_account")
func get_account(_ handle: UnsafeMutableRawPointer?) -> CAccount

@_silgen_name("submit_order")
func submit_order(_ handle: UnsafeMutableRawPointer?, 
                  _ order: UnsafeMutablePointer<COrder>?) -> UnsafePointer<CChar>?

@_silgen_name("cancel_order")
func cancel_order(_ handle: UnsafeMutableRawPointer?, 
                  _ orderId: UnsafePointer<CChar>?) -> Bool

@_silgen_name("get_orders_count")
func get_orders_count(_ handle: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("get_order_at")
func get_order_at(_ handle: UnsafeMutableRawPointer?, _ index: Int32) -> COrder

@_silgen_name("get_positions_count")
func get_positions_count(_ handle: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("get_position_at")
func get_position_at(_ handle: UnsafeMutableRawPointer?, _ index: Int32) -> CPosition

@_silgen_name("update_market_price")
func update_market_price(_ handle: UnsafeMutableRawPointer?, 
                         _ symbol: UnsafePointer<CChar>?, 
                         _ price: Double)

// MARK: - Swift Wrapper

class TradingBackend {
    private var engineHandle: UnsafeMutableRawPointer?
    
    init() {
        engineHandle = create_broker_engine()
    }
    
    deinit {
        destroy_broker_engine(engineHandle)
    }
    
    func initializeAccount(accountId: String, name: String, initialCash: Double) {
        guard let handle = engineHandle else { return }
        accountId.withCString { accountIdPtr in
            name.withCString { namePtr in
                initialize_account(handle, accountIdPtr, namePtr, initialCash)
            }
        }
    }
    
    func getAccount() -> Account {
        guard let handle = engineHandle else { return Account() }
        let cAccount = get_account(handle)
        
        return Account(
            id: cAccount.id.map(String.init(cString:)) ?? "",
            name: cAccount.name.map(String.init(cString:)) ?? "",
            cashBalance: cAccount.cashBalance,
            buyingPower: cAccount.buyingPower,
            portfolioValue: cAccount.portfolioValue,
            totalEquity: cAccount.totalEquity
        )
    }
    
    func submitOrder(symbol: String, type: OrderType, side: OrderSide, 
                     quantity: Double, price: Double = 0) -> String? {
        guard let handle = engineHandle else { return nil }
        
        var cOrder = COrder(
            id: nil,
            symbol: nil,
            type: COrderType(rawValue: type.rawValue) ?? .market,
            side: COrderSide(rawValue: side.rawValue) ?? .buy,
            quantity: quantity,
            price: price,
            stopPrice: 0,
            status: .pending,
            filledQuantity: 0,
            averageFillPrice: 0
        )
        
        var orderId: String?
        symbol.withCString { symbolPtr in
            cOrder.symbol = symbolPtr
            if let resultPtr = submit_order(handle, &cOrder) {
                orderId = String(cString: resultPtr)
            }
        }
        
        return orderId
    }
    
    func cancelOrder(orderId: String) -> Bool {
        guard let handle = engineHandle else { return false }
        
        var result = false
        orderId.withCString { orderIdPtr in
            result = cancel_order(handle, orderIdPtr)
        }
        
        return result
    }
    
    func getOrders() -> [Order] {
        guard let handle = engineHandle else { return [] }
        
        let count = get_orders_count(handle)
        var orders: [Order] = []
        
        for i in 0..<count {
            let cOrder = get_order_at(handle, i)
            orders.append(Order(from: cOrder))
        }
        
        return orders
    }
    
    func getPositions() -> [Position] {
        guard let handle = engineHandle else { return [] }
        
        let count = get_positions_count(handle)
        var positions: [Position] = []
        
        for i in 0..<count {
            let cPos = get_position_at(handle, i)
            positions.append(Position(from: cPos))
        }
        
        return positions
    }
    
    func updateMarketPrice(symbol: String, price: Double) {
        guard let handle = engineHandle else { return }
        
        symbol.withCString { symbolPtr in
            update_market_price(handle, symbolPtr, price)
        }
    }
}

// MARK: - Swift Models

enum OrderType: UInt32 {
    case market = 0
    case limit = 1
    case stopLoss = 2
    case stopLimit = 3
}

enum OrderSide: UInt32 {
    case buy = 0
    case sell = 1
}

enum OrderStatus: UInt32 {
    case pending = 0
    case submitted = 1
    case partiallyFilled = 2
    case filled = 3
    case cancelled = 4
    case rejected = 5
}

struct Order {
    let id: String
    let symbol: String
    let type: OrderType
    let side: OrderSide
    let quantity: Double
    let price: Double
    let status: OrderStatus
    let filledQuantity: Double
    let averageFillPrice: Double
    
    init(from cOrder: COrder) {
        self.id = cOrder.id.map(String.init(cString:)) ?? ""
        self.symbol = cOrder.symbol.map(String.init(cString:)) ?? ""
        self.type = OrderType(rawValue: cOrder.type.rawValue) ?? .market
        self.side = OrderSide(rawValue: cOrder.side.rawValue) ?? .buy
        self.quantity = cOrder.quantity
        self.price = cOrder.price
        self.status = OrderStatus(rawValue: cOrder.status.rawValue) ?? .pending
        self.filledQuantity = cOrder.filledQuantity
        self.averageFillPrice = cOrder.averageFillPrice
    }
}

struct Position {
    let symbol: String
    let quantity: Double
    let averageEntryPrice: Double
    let currentPrice: Double
    let unrealizedPnL: Double
    let realizedPnL: Double
    
    init(from cPos: CPosition) {
        self.symbol = cPos.symbol.map(String.init(cString:)) ?? ""
        self.quantity = cPos.quantity
        self.averageEntryPrice = cPos.averageEntryPrice
        self.currentPrice = cPos.currentPrice
        self.unrealizedPnL = cPos.unrealizedPnL
        self.realizedPnL = cPos.realizedPnL
    }
    
    var totalValue: Double {
        return quantity * currentPrice
    }
}

struct Account {
    let id: String
    let name: String
    let cashBalance: Double
    let buyingPower: Double
    let portfolioValue: Double
    let totalEquity: Double
    
    init() {
        self.id = ""
        self.name = ""
        self.cashBalance = 0
        self.buyingPower = 0
        self.portfolioValue = 0
        self.totalEquity = 0
    }
}
