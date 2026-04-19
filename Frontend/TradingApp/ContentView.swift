import SwiftUI
import Foundation

// MARK: - ContentView Principal
struct ContentView: View {
    @StateObject private var viewModel = TradingViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
                .tag(0)
            
            OrdersView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Ordres")
                }
                .tag(1)
            
            PositionsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Positions")
                }
                .tag(2)
            
            TradeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Trade")
                }
                .tag(3)
        }
        .frame(minWidth: 900, minHeight: 650)
        .padding()
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var viewModel: TradingViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    StatCard(title: "Equity", value: String(format: "$%.2f", viewModel.account.equity), color: .blue)
                    StatCard(title: "Cash", value: String(format: "$%.2f", viewModel.account.cash), color: .green)
                    StatCard(title: "Buying Power", value: String(format: "$%.2f", viewModel.account.buyingPower), color: .orange)
                    StatCard(title: "P&L", value: String(format: "$%.2f", viewModel.account.totalPnL), 
                             color: viewModel.account.totalPnL >= 0 ? .green : .red)
                }
                
                Divider()
                
                HStack(spacing: 30) {
                    StatCard(title: "Orders", value: "\(viewModel.orders.count)", color: .purple)
                    StatCard(title: "Positions", value: "\(viewModel.positions.count)", color: .cyan)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Trading System")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { viewModel.refreshData() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Orders View
struct OrdersView: View {
    @ObservedObject var viewModel: TradingViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.orders) { order in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(order.side) \(order.quantity) \(order.symbol)")
                            .font(.headline)
                        Text("Type: \(order.type) | Status: \(order.status)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(String(format: "$%.2f", order.price))
                            .font(.monospacedDigit())
                        if let filledAt = order.filledAt {
                            Text(filledAt)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if order.status == "Pending" {
                        Button(action: { viewModel.cancelOrder(orderId: order.id) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .navigationTitle("Historique des Ordres")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { viewModel.refreshData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Positions View
struct PositionsView: View {
    @ObservedObject var viewModel: TradingViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.positions) { position in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(position.quantity) \(position.symbol)")
                            .font(.headline)
                        Text("Avg: \(String(format: "$%.2f", position.avgPrice)) | Current: \(String(format: "$%.2f", position.currentPrice))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        let pnl = position.unrealizedPnL
                        Text(String(format: "%+.2f$", pnl))
                            .font(.monospacedDigit())
                            .fontWeight(.bold)
                            .foregroundColor(pnl >= 0 ? .green : .red)
                        
                        Text(String(format: "%+.2f%%", position.pnlPercent))
                            .font(.caption)
                            .foregroundColor(pnl >= 0 ? .green : .red)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .navigationTitle("Positions Ouvertes")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { viewModel.refreshData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Trade View
struct TradeView: View {
    @ObservedObject var viewModel: TradingViewModel
    @State private var symbol = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var orderType = "Market"
    @State private var side = "Buy"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Détails de l'ordre")) {
                    Picker("Side", selection: $side) {
                        Text("Buy").tag("Buy")
                        Text("Sell").tag("Sell")
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Symbol (ex: AAPL)", text: $symbol)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Quantité", text: $quantity)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Type", selection: $orderType) {
                        Text("Market").tag("Market")
                        Text("Limit").tag("Limit")
                    }
                    .pickerStyle(.segmented)
                    
                    if orderType == "Limit" {
                        TextField("Prix Limit", text: $price)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section {
                    Button(action: submitOrder) {
                        HStack {
                            Image(systemName: side == "Buy" ? "arrow.up.circle" : "arrow.down.circle")
                            Text("\(side) Order")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(side == "Buy" ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(symbol.isEmpty || quantity.isEmpty)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Passer un Ordre")
            .alert("Ordre", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitOrder() {
        guard let qty = Int(quantity) else {
            alertMessage = "Quantité invalide"
            showingAlert = true
            return
        }
        
        let limitPrice = orderType == "Limit" ? (Double(price) ?? 0.0) : nil
        
        viewModel.placeOrder(
            symbol: symbol.uppercased(),
            side: side,
            quantity: qty,
            type: orderType,
            price: limitPrice
        )
        
        alertMessage = "Ordre \(side) \(qty) \(symbol.uppercased()) soumis !"
        showingAlert = true
        
        // Reset
        symbol = ""
        quantity = ""
        price = ""
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ContentView()
}
