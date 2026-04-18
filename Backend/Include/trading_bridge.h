#ifndef TRADING_BRIDGE_H
#define TRADING_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

// Opaque handle to the C++ broker engine
typedef void* BrokerEngineHandle;

// Order types
typedef enum {
    OrderType_Market = 0,
    OrderType_Limit = 1,
    OrderType_StopLoss = 2,
    OrderType_StopLimit = 3
} COrderType;

// Order sides
typedef enum {
    OrderSide_Buy = 0,
    OrderSide_Sell = 1
} COrderSide;

// Order status
typedef enum {
    OrderStatus_Pending = 0,
    OrderStatus_Submitted = 1,
    OrderStatus_PartiallyFilled = 2,
    OrderStatus_Filled = 3,
    OrderStatus_Cancelled = 4,
    OrderStatus_Rejected = 5
} COrderStatus;

// C-compatible Order struct
typedef struct {
    const char* id;
    const char* symbol;
    COrderType type;
    COrderSide side;
    double quantity;
    double price;
    double stopPrice;
    COrderStatus status;
    double filledQuantity;
    double averageFillPrice;
} COrder;

// C-compatible Position struct
typedef struct {
    const char* symbol;
    double quantity;
    double averageEntryPrice;
    double currentPrice;
    double unrealizedPnL;
    double realizedPnL;
} CPosition;

// C-compatible Account struct
typedef struct {
    const char* id;
    const char* name;
    double cashBalance;
    double buyingPower;
    double portfolioValue;
    double totalEquity;
} CAccount;

// Bridge functions
BrokerEngineHandle create_broker_engine();
void destroy_broker_engine(BrokerEngineHandle handle);

void initialize_account(BrokerEngineHandle handle, const char* accountId, const char* name, double initialCash);
CAccount get_account(BrokerEngineHandle handle);

const char* submit_order(BrokerEngineHandle handle, COrder* order);
bool cancel_order(BrokerEngineHandle handle, const char* orderId);

// Get orders count
int get_orders_count(BrokerEngineHandle handle);
COrder get_order_at(BrokerEngineHandle handle, int index);

// Get positions count
int get_positions_count(BrokerEngineHandle handle);
CPosition get_position_at(BrokerEngineHandle handle, int index);

void update_market_price(BrokerEngineHandle handle, const char* symbol, double price);

#ifdef __cplusplus
}
#endif

#endif // TRADING_BRIDGE_H
