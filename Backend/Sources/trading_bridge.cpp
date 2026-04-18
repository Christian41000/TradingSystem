#include "trading_bridge.h"
#include "Account.hpp"
#include <vector>
#include <string>
#include <cstring>

using namespace Trading;

// Helper to convert C++ OrderStatus to COrderStatus
COrderStatus toCOrderStatus(OrderStatus status) {
    switch (status) {
        case OrderStatus::Pending: return OrderStatus_Pending;
        case OrderStatus::Submitted: return OrderStatus_Submitted;
        case OrderStatus::PartiallyFilled: return OrderStatus_PartiallyFilled;
        case OrderStatus::Filled: return OrderStatus_Filled;
        case OrderStatus::Cancelled: return OrderStatus_Cancelled;
        case OrderStatus::Rejected: return OrderStatus_Rejected;
        default: return OrderStatus_Pending;
    }
}

// Helper to convert COrderType to OrderType
OrderType toOrderType(COrderType type) {
    switch (type) {
        case OrderType_Limit: return OrderType::Limit;
        case OrderType_StopLoss: return OrderType::StopLoss;
        case OrderType_StopLimit: return OrderType::StopLimit;
        default: return OrderType::Market;
    }
}

// Helper to convert COrderSide to OrderSide
OrderSide toOrderSide(COrderSide side) {
    return (side == OrderSide_Sell) ? OrderSide::Sell : OrderSide::Buy;
}

// Static storage for string returns (simplified for demo)
static std::vector<std::string> idStorage;

extern "C" {

BrokerEngineHandle create_broker_engine() {
    return new BrokerEngine();
}

void destroy_broker_engine(BrokerEngineHandle handle) {
    delete static_cast<BrokerEngine*>(handle);
}

void initialize_account(BrokerEngineHandle handle, const char* accountId, const char* name, double initialCash) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    engine->initializeAccount(std::string(accountId), std::string(name), initialCash);
}

CAccount get_account(BrokerEngineHandle handle) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    Account acc = engine->getAccount();
    
    CAccount cAcc;
    cAcc.id = acc.id.c_str();
    cAcc.name = acc.name.c_str();
    cAcc.cashBalance = acc.cashBalance;
    cAcc.buyingPower = acc.buyingPower;
    cAcc.portfolioValue = acc.portfolioValue;
    cAcc.totalEquity = acc.totalEquity;
    
    return cAcc;
}

const char* submit_order(BrokerEngineHandle handle, COrder* order) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    
    Order cppOrder;
    cppOrder.symbol = std::string(order->symbol);
    cppOrder.type = toOrderType(order->type);
    cppOrder.side = toOrderSide(order->side);
    cppOrder.quantity = order->quantity;
    cppOrder.price = order->price;
    cppOrder.stopPrice = order->stopPrice;
    
    std::string orderId = engine->submitOrder(cppOrder);
    
    // Store ID for return (in production, use proper memory management)
    idStorage.push_back(orderId);
    return idStorage.back().c_str();
}

bool cancel_order(BrokerEngineHandle handle, const char* orderId) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    return engine->cancelOrder(std::string(orderId));
}

int get_orders_count(BrokerEngineHandle handle) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    return static_cast<int>(engine->getOrders().size());
}

COrder get_order_at(BrokerEngineHandle handle, int index) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    auto orders = engine->getOrders();
    
    COrder cOrder;
    if (index >= 0 && index < static_cast<int>(orders.size())) {
        const auto& order = orders[index];
        
        // Store strings temporarily (simplified)
        static std::vector<std::string> tempStrings;
        tempStrings.push_back(order.id);
        tempStrings.push_back(order.symbol);
        
        cOrder.id = tempStrings[tempStrings.size() - 2].c_str();
        cOrder.symbol = tempStrings.back().c_str();
        cOrder.type = static_cast<COrderType>(order.type);
        cOrder.side = static_cast<COrderSide>(order.side);
        cOrder.quantity = order.quantity;
        cOrder.price = order.price;
        cOrder.stopPrice = order.stopPrice;
        cOrder.status = toCOrderStatus(order.status);
        cOrder.filledQuantity = order.filledQuantity;
        cOrder.averageFillPrice = order.averageFillPrice;
    }
    
    return cOrder;
}

int get_positions_count(BrokerEngineHandle handle) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    return static_cast<int>(engine->getPositions().size());
}

CPosition get_position_at(BrokerEngineHandle handle, int index) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    auto positions = engine->getPositions();
    
    CPosition cPos;
    if (index >= 0 && index < static_cast<int>(positions.size())) {
        const auto& pos = positions[index];
        
        static std::vector<std::string> tempStrings;
        tempStrings.push_back(pos.symbol);
        cPos.symbol = tempStrings.back().c_str();
        
        cPos.quantity = pos.quantity;
        cPos.averageEntryPrice = pos.averageEntryPrice;
        cPos.currentPrice = pos.currentPrice;
        cPos.unrealizedPnL = pos.unrealizedPnL;
        cPos.realizedPnL = pos.realizedPnL;
    } else {
        cPos.symbol = "";
        cPos.quantity = 0;
        cPos.averageEntryPrice = 0;
        cPos.currentPrice = 0;
        cPos.unrealizedPnL = 0;
        cPos.realizedPnL = 0;
    }
    
    return cPos;
}

void update_market_price(BrokerEngineHandle handle, const char* symbol, double price) {
    auto* engine = static_cast<BrokerEngine*>(handle);
    engine->updateMarketPrice(std::string(symbol), price);
}

} // extern "C"
