#ifndef ACCOUNT_HPP
#define ACCOUNT_HPP

#include <string>
#include <vector>
#include <memory>
#include "Order.hpp"
#include "Position.hpp"

namespace Trading {

struct Account {
    std::string id;
    std::string name;
    double cashBalance;
    double buyingPower;
    double portfolioValue;
    double totalEquity;
    
    Account() : cashBalance(0), buyingPower(0), portfolioValue(0), totalEquity(0) {}
};

class BrokerEngine {
public:
    BrokerEngine();
    ~BrokerEngine();
    
    // Account management
    void initializeAccount(const std::string& accountId, const std::string& name, double initialCash);
    Account getAccount() const;
    
    // Order management
    std::string submitOrder(const Order& order);
    bool cancelOrder(const std::string& orderId);
    std::vector<Order> getOrders() const;
    std::vector<Order> getOrdersByStatus(OrderStatus status) const;
    
    // Position management
    std::vector<Position> getPositions() const;
    Position getPosition(const std::string& symbol) const;
    
    // Market data simulation (for demo purposes)
    void updateMarketPrice(const std::string& symbol, double price);
    
    // Portfolio calculations
    void updatePortfolioValues();
    
private:
    Account account_;
    std::vector<Order> orders_;
    std::vector<Position> positions_;
    
    void executeOrder(Order& order, double marketPrice);
    void updatePosition(const std::string& symbol, double quantity, double price, OrderSide side);
};

} // namespace Trading

#endif // ACCOUNT_HPP
