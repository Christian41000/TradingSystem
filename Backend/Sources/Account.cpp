#include "Account.hpp"
#include <algorithm>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <random>

namespace Trading {

BrokerEngine::BrokerEngine() {}

BrokerEngine::~BrokerEngine() {}

void BrokerEngine::initializeAccount(const std::string& accountId, const std::string& name, double initialCash) {
    account_.id = accountId;
    account_.name = name;
    account_.cashBalance = initialCash;
    account_.buyingPower = initialCash;
    account_.portfolioValue = 0;
    account_.totalEquity = initialCash;
}

Account BrokerEngine::getAccount() const {
    return account_;
}

std::string BrokerEngine::submitOrder(const Order& order) {
    Order newOrder = order;
    newOrder.id = "ORD-" + std::to_string(orders_.size() + 1);
    newOrder.status = OrderStatus::Submitted;
    newOrder.createdAt = std::chrono::system_clock::now();
    newOrder.updatedAt = newOrder.createdAt;
    
    // Simulate order execution (in real system, this would connect to a broker API)
    double marketPrice = 0;
    
    // Simple price simulation for demo
    static std::mt19937 gen(42);
    static std::uniform_real_distribution<> dis(95.0, 105.0);
    
    if (newOrder.type == OrderType::Market) {
        marketPrice = dis(gen);
        executeOrder(newOrder, marketPrice);
    } else if (newOrder.type == OrderType::Limit) {
        marketPrice = dis(gen);
        if ((newOrder.side == OrderSide::Buy && marketPrice <= newOrder.price) ||
            (newOrder.side == OrderSide::Sell && marketPrice >= newOrder.price)) {
            executeOrder(newOrder, marketPrice);
        } else {
            newOrder.status = OrderStatus::Pending;
        }
    }
    
    orders_.push_back(newOrder);
    updatePortfolioValues();
    
    return newOrder.id;
}

bool BrokerEngine::cancelOrder(const std::string& orderId) {
    for (auto& order : orders_) {
        if (order.id == orderId && order.status == OrderStatus::Submitted) {
            order.status = OrderStatus::Cancelled;
            order.updatedAt = std::chrono::system_clock::now();
            return true;
        }
    }
    return false;
}

std::vector<Order> BrokerEngine::getOrders() const {
    return orders_;
}

std::vector<Order> BrokerEngine::getOrdersByStatus(OrderStatus status) const {
    std::vector<Order> filtered;
    std::copy_if(orders_.begin(), orders_.end(), std::back_inserter(filtered),
                 [status](const Order& o) { return o.status == status; });
    return filtered;
}

std::vector<Position> BrokerEngine::getPositions() const {
    return positions_;
}

Position BrokerEngine::getPosition(const std::string& symbol) const {
    for (const auto& pos : positions_) {
        if (pos.symbol == symbol) {
            return pos;
        }
    }
    return Position();
}

void BrokerEngine::updateMarketPrice(const std::string& symbol, double price) {
    for (auto& pos : positions_) {
        if (pos.symbol == symbol) {
            pos.currentPrice = price;
            pos.unrealizedPnL = (price - pos.averageEntryPrice) * pos.quantity;
            pos.updatedAt = std::chrono::system_clock::now();
        }
    }
    updatePortfolioValues();
}

void BrokerEngine::updatePortfolioValues() {
    double portfolioValue = 0;
    for (const auto& pos : positions_) {
        portfolioValue += pos.getTotalValue();
    }
    account_.portfolioValue = portfolioValue;
    account_.totalEquity = account_.cashBalance + portfolioValue;
    account_.buyingPower = account_.cashBalance; // Simplified
}

void BrokerEngine::executeOrder(Order& order, double marketPrice) {
    double totalCost = order.quantity * marketPrice;
    
    if (order.side == OrderSide::Buy) {
        if (totalCost > account_.cashBalance) {
            order.status = OrderStatus::Rejected;
            return;
        }
        
        account_.cashBalance -= totalCost;
        updatePosition(order.symbol, order.quantity, marketPrice, OrderSide::Buy);
    } else { // Sell
        updatePosition(order.symbol, order.quantity, marketPrice, OrderSide::Sell);
        account_.cashBalance += totalCost;
    }
    
    order.filledQuantity = order.quantity;
    order.averageFillPrice = marketPrice;
    order.status = OrderStatus::Filled;
    order.updatedAt = std::chrono::system_clock::now();
}

void BrokerEngine::updatePosition(const std::string& symbol, double quantity, double price, OrderSide side) {
    auto it = std::find_if(positions_.begin(), positions_.end(),
                           [&symbol](const Position& p) { return p.symbol == symbol; });
    
    if (it == positions_.end()) {
        if (side == OrderSide::Buy) {
            Position newPos;
            newPos.symbol = symbol;
            newPos.quantity = quantity;
            newPos.averageEntryPrice = price;
            newPos.currentPrice = price;
            newPos.openedAt = std::chrono::system_clock::now();
            newPos.updatedAt = newPos.openedAt;
            positions_.push_back(newPos);
        }
    } else {
        if (side == OrderSide::Buy) {
            double totalCost = it->quantity * it->averageEntryPrice + quantity * price;
            it->quantity += quantity;
            it->averageEntryPrice = totalCost / it->quantity;
        } else {
            double realizedPnL = (price - it->averageEntryPrice) * quantity;
            it->realizedPnL += realizedPnL;
            it->quantity -= quantity;
            
            if (it->quantity <= 0) {
                positions_.erase(it);
                return;
            }
        }
        it->currentPrice = price;
        it->updatedAt = std::chrono::system_clock::now();
    }
}

} // namespace Trading
