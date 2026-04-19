import SwiftUI

// MARK: - Modèles de données
struct TradeOrder: Identifiable {
    let id: Int
    let symbol: String
    let side: String
    let quantity: Int
    let price: Double
}

// MARK: - Backend de simulation
class TradingBackend {
    private var cash: Double = 100000.0
    private var orders: [TradeOrder] = []
    private var nextOrderId: Int = 1
    
    init() {
        // Ordre initial pour la démo
        addOrder(symbol: "AAPL", side: "Buy", quantity: 10, price: 175.0)
    }
    
    func getAccountInfo() -> (cash: Double, buyingPower: Double) {
        return (cash, cash)
    }
    
    func getOrders() -> [TradeOrder] {
        return orders
    }
    
    func placeOrder(symbol: String, side: String, quantity: Int, price: Double) -> Bool {
        let execPrice = price > 0 ? price : 175.0 // Prix par défaut si market
        let cost = execPrice * Double(quantity)
        
        if side == "Buy" {
            if cash < cost { return false }
            cash -= cost
        } else {
            cash += cost
        }
        
        addOrder(symbol: symbol, side: side, quantity: quantity, price: execPrice)
        return true
    }
    
    private func addOrder(symbol: String, side: String, quantity: Int, price: Double) {
        orders.append(TradeOrder(id: nextOrderId, symbol: symbol, side: side, quantity: quantity, price: price))
        nextOrderId += 1
    }
}

// MARK: - ViewModel
class TradingViewModel: ObservableObject {
    @Published var cash: Double = 0.0
    @Published var buyingPower: Double = 0.0
    @Published var orders: [TradeOrder] = []
    
    private let backend = TradingBackend()
    
    init() {
        refreshData()
    }
    
    func refreshData() {
        let info = backend.getAccountInfo()
        self.cash = info.cash
        self.buyingPower = info.buyingPower
        self.orders = backend.getOrders()
    }
    
    func placeOrder(symbol: String, side: String, quantity: Int, price: Double) {
        _ = backend.placeOrder(symbol: symbol, side: side, quantity: quantity, price: price)
        refreshData()
    }
}

// MARK: - Vue Principale
struct ContentView: View {
    @StateObject private var viewModel = TradingViewModel()
    @State private var symbol: String = ""
    @State private var quantityText: String = ""
    @State private var selectedSide: String = "Buy"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section Compte
                    GroupBox("Compte") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Cash Disponible:")
                                Spacer()
                                Text(String(format: "$%.2f", viewModel.cash))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            HStack {
                                Text("Buying Power:")
                                Spacer()
                                Text(String(format: "$%.2f", viewModel.buyingPower))
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Section Trading
                    GroupBox("Passer un Ordre") {
                        VStack(spacing: 15) {
                            Picker("Type d'ordre", selection: $selectedSide) {
                                Text("Achat").tag("Buy")
                                Text("Vente").tag("Sell")
                            }
                            .pickerStyle(.segmented)
                            
                            TextField("Symbole (ex: AAPL)", text: $symbol)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.characters)
                            
                            TextField("Quantité", text: $quantityText)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            Button(action: submitOrder) {
                                HStack {
                                    Image(systemName: selectedSide == "Buy" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    Text(selectedSide == "Buy" ? "ACHETER" : "VENDRE")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedSide == "Buy" ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(symbol.isEmpty || quantityText.isEmpty)
                        }
                        .padding()
                    }
                    
                    // Section Historique
                    GroupBox("Historique des Ordres (\(viewModel.orders.count))") {
                        if viewModel.orders.isEmpty {
                            Text("Aucun ordre pour le moment.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.orders) { order in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(order.side == "Buy" ? "ACHAT" : "VENTE") \(order.symbol)")
                                                .fontWeight(.semibold)
                                                .foregroundColor(order.side == "Buy" ? .green : .red)
                                            Text("Qté: \(order.quantity)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(String(format: "$%.2f", order.price))
                                            .fontWeight(.bold)
                                            .monospacedDigit()
                                    }
                                    Divider()
                                }
                            }
                            .padding(.top, 5)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            viewModel.refreshData()
                        }
                    }) {
                        Label("Rafraîchir les données", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Trading System")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.refreshData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func submitOrder() {
        guard let qty = Int(quantityText), !symbol.isEmpty else { return }
        viewModel.placeOrder(
            symbol: symbol.uppercased(),
            side: selectedSide,
            quantity: qty,
            price: 0.0 // 0.0 signifie "Market Order" dans notre logique simplifiée
        )
        symbol = ""
        quantityText = ""
    }
}

// MARK: - Point d'entrée
@main
struct TradingSystemApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
