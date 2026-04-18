#ifndef ORDER_HPP
#define ORDER_HPP

#include <string>
#include <chrono>
#include <cstdint>

namespace Trading {

enum class OrderType {
    Market,
    Limit,
    StopLoss,
    StopLimit
};

enum class OrderSide {
    Buy,
    Sell
};

enum class OrderStatus {
    Pending,
    Submitted,
    PartiallyFilled,
    Filled,
    Cancelled,
    Rejected
};

struct Order {
    std::string id;
    std::string symbol;
    OrderType type;
    OrderSide side;
    double quantity;
    double price;          // For limit orders
    double stopPrice;      // For stop orders
    OrderStatus status;
    double filledQuantity;
    double averageFillPrice;
    std::chrono::system_clock::time_point createdAt;
    std::chrono::system_clock::time_point updatedAt;
    
    Order() : quantity(0), price(0), stopPrice(0), 
              status(OrderStatus::Pending), filledQuantity(0), averageFillPrice(0) {}
};

} // namespace Trading

#endif // ORDER_HPP
