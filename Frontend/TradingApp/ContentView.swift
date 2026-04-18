//
//  ContentView.swift
//  TradingApp
//
//  Main UI View for Trading System
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TradingViewModel
    @State private var selectedTab = 0
    @State private var symbol = "AAPL"
    @State private var quantity = "10"
    @State private var orderType: OrderType = .market
    @State private var limitPrice = ""
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                DashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Dashboard")
                    }
                    .tag(0)
                
                // Orders Tab
                OrdersView()
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle.fill")
                        Text("Orders")
                    }
                    .tag(1)
                
                // Positions Tab
                PositionsView()
                    .tabItem {
                        Image(systemName: "briefcase.fill")
                        Text("Positions")
                    }
                    .tag(2)
                
                // Trade Tab
                TradeView(
                    symbol: $symbol,
                    quantity: $quantity,
                    orderType: $orderType,
                    limitPrice: $limitPrice
                )
                    .tabItem {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                        Text("Trade")
                    }
                    .tag(3)
            }
            .navigationTitle("Trading System")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        VStack(alignment: .trailing) {
                            Text("Equity: $\(viewModel.account.totalEquity, specifier: "%.2f")")
                                .font(.caption)
                            Text("Cash: $\(viewModel.account.cashBalance, specifier: "%.2f")")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var viewModel: TradingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Account Summary Card
                AccountSummaryCard(account: viewModel.account)
                
                // Quick Stats
                HStack(spacing: 15) {
                    StatCard(title: "Orders", value: "\(viewModel.orders.count)", color: .blue)
                    StatCard(title: "Positions", value: "\(viewModel.positions.count)", color: .green)
                    StatCard(title: "Buying Power", value: "$\(viewModel.account.buyingPower, specifier: "%.0f")", color: .orange)
                }
                
                // Recent Orders
                if !viewModel.orders.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Orders")
                            .font(.headline)
                        
                        ForEach(viewModel.orders.suffix(5).reversed(), id: \.id) { order in
                            OrderRowView(order: order)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Orders View

struct OrdersView: View {
    @EnvironmentObject var viewModel: TradingViewModel
    
    var body: some View {
        List {
            Section(header: Text("All Orders")) {
                if viewModel.orders.isEmpty {
                    Text("No orders yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.orders.reversed(), id: \.id) { order in
                        OrderRowView(order: order)
                            .swipeActions {
                                if order.status == .submitted || order.status == .pending {
                                    Button(role: .destructive) {
                                        viewModel.cancelOrder(orderId: order.id)
                                    } label: {
                                        Label("Cancel", systemImage: "xmark.circle")
                                    }
                                }
                            }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// MARK: - Positions View

struct PositionsView: View {
    @EnvironmentObject var viewModel: TradingViewModel
    
    var body: some View {
        List {
            Section(header: Text("Current Positions")) {
                if viewModel.positions.isEmpty {
                    Text("No open positions")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.positions, id: \.symbol) { position in
                        PositionRowView(position: position)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            viewModel.refreshData()
        }
    }
}

// MARK: - Trade View

struct TradeView: View {
    @EnvironmentObject var viewModel: TradingViewModel
    @Binding var symbol: String
    @Binding var quantity: String
    @Binding var orderType: OrderType
    @Binding var limitPrice: String
    
    var body: some View {
        Form {
            Section(header: Text("Order Details")) {
                Picker("Order Type", selection: $orderType) {
                    Text("Market").tag(OrderType.market)
                    Text("Limit").tag(OrderType.limit)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Symbol (e.g., AAPL)", text: $symbol)
                    .textContentType(.none)
                    .autocapitalization(.characters)
                
                TextField("Quantity", text: $quantity)
                    .keyboardType(.decimalPad)
                
                if orderType == .limit {
                    TextField("Limit Price", text: $limitPrice)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section {
                HStack(spacing: 20) {
                    Button(action: {
                        placeOrder(side: .buy)
                    }) {
                        Label("Buy", systemImage: "arrow.up.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        placeOrder(side: .sell)
                    }) {
                        Label("Sell", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .formStyle(GroupedFormStyle())
    }
    
    private func placeOrder(side: OrderSide) {
        guard let qty = Double(quantity), qty > 0 else {
            return
        }
        
        if orderType == .market {
            viewModel.submitMarketOrder(symbol: symbol, side: side, quantity: qty)
        } else if let price = Double(limitPrice), price > 0 {
            viewModel.submitLimitOrder(symbol: symbol, side: side, quantity: qty, price: price)
        }
        
        // Reset form
        quantity = ""
        limitPrice = ""
    }
}

// MARK: - Supporting Views

struct AccountSummaryCard: View {
    let account: Account
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Total Equity")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("$\(account.totalEquity, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Cash Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(account.cashBalance, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Portfolio Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(account.portfolioValue, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(order.symbol)
                        .font(.headline)
                    Text(order.side == .buy ? "BUY" : "SELL")
                        .font(.caption)
                        .padding(4)
                        .background(order.side == .buy ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text("\(order.quantity) shares @ $\(order.averageFillPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(order.type == .market ? "Market" : "Limit")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                StatusBadge(status: order.status)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PositionRowView: View {
    let position: Position
    
    var pnlColor: Color {
        position.unrealizedPnL >= 0 ? .green : .red
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(position.symbol)
                    .font(.headline)
                Text("\(position.quantity) shares")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(position.currentPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(position.unrealizedPnL >= 0 ? "+" : "")$\(position.unrealizedPnL, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(pnlColor)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    
    var color: Color {
        switch status {
        case .filled: return .green
        case .cancelled: return .gray
        case .rejected: return .red
        case .pending, .submitted: return .orange
        case .partiallyFilled: return .blue
        }
    }
    
    var label: String {
        switch status {
        case .filled: return "Filled"
        case .cancelled: return "Cancelled"
        case .rejected: return "Rejected"
        case .pending: return "Pending"
        case .submitted: return "Submitted"
        case .partiallyFilled: return "Partial"
        }
    }
    
    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

#Preview {
    ContentView()
        .environmentObject(TradingViewModel())
}
