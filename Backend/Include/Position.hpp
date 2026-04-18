#ifndef POSITION_HPP
#define POSITION_HPP

#include <string>
#include <chrono>

namespace Trading {

struct Position {
    std::string symbol;
    double quantity;
    double averageEntryPrice;
    double currentPrice;
    double unrealizedPnL;
    double realizedPnL;
    std::chrono::system_clock::time_point openedAt;
    std::chrono::system_clock::time_point updatedAt;
    
    Position() : quantity(0), averageEntryPrice(0), currentPrice(0), 
                 unrealizedPnL(0), realizedPnL(0) {}
    
    double getTotalValue() const {
        return quantity * currentPrice;
    }
    
    double getCostBasis() const {
        return quantity * averageEntryPrice;
    }
};

} // namespace Trading

#endif // POSITION_HPP
