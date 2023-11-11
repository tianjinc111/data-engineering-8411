//+------------------------------------------------------------------+
//|                                                      testing.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int RunningHours = 2; // Number of hours to run the script

extern double TradeVolume = 100000; // Hourly trade volume in dollars
extern string SymbolToTrade = "EURUSD"; // Currency pair to trade

unsigned int lastOrderTime = 0;
unsigned int startTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    startTime = GetTickCount();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //---
}

//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize(double tradeVolume)
{
    double tickValue = MarketInfo(SymbolToTrade, MODE_TICKVALUE);
    double tickSize = MarketInfo(SymbolToTrade, MODE_TICKSIZE);
    double lotSize = NormalizeDouble(tradeVolume / (tickValue / tickSize), 2);

    double minLot = MarketInfo(SymbolToTrade, MODE_MINLOT);
    double maxLot = MarketInfo(SymbolToTrade, MODE_MAXLOT);
    double lotStep = MarketInfo(SymbolToTrade, MODE_LOTSTEP);

    if (lotSize < minLot)
    {
        lotSize = minLot;
    }
    else if (lotSize > maxLot)
    {
        lotSize = maxLot;
    }
    else
    {
        lotSize = NormalizeDouble(MathFloor(lotSize / lotStep) * lotStep, 2);
    }

    return lotSize;
}

//+------------------------------------------------------------------+
//| Open Long EURUSD order                                           |
//+------------------------------------------------------------------+
void OpenLongEURUSDOrder()
{
    double lotSize = CalculateLotSize(TradeVolume);

    // Open a Buy position
    int ticket = OrderSend(SymbolToTrade, OP_BUY, lotSize, Ask, 3, 0, 0, "Long EURUSD Hourly", 0, 0, clrGreen);

    // Check if the order was successfully opened
    if (ticket < 0)
    {
        Print("Error opening order: ", GetLastError());
    }
    else
    {
        Print("Order opened successfully: ", ticket);
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if ((GetTickCount() - startTime) / 3600000 >= RunningHours)
    {
        Print("Reached maximum running hours, stopping the script.");
        ExpertRemove();
    }

    // Check if an hour has passed since the last order
    if (GetTickCount() - lastOrderTime >= 3600000 || lastOrderTime == 0)
    {
        lastOrderTime = GetTickCount();
        OpenLongEURUSDOrder();
    }
}
//+------------------------------------------------------------------+
