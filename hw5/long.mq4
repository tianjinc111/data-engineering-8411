//+------------------------------------------------------------------+
//|                                                      long.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string SymbolToTrade = "USDCHF";
double TotalTradeVolume = 1000000;
double FirstWindowVolume = TotalTradeVolume * 0.20;
double SecondWindowVolume = TotalTradeVolume * 0.30;
double LotSize = 10000;

double AvgExecutionPrice1 = 0;
int TradesExecuted1 = 0;

double AvgExecutionPrice2 = 0;
int TradesExecuted2 = 0;

datetime lastTradeTime;

double ThirdWindowVolume = TotalTradeVolume * 0.20;

double AvgExecutionPrice3 = 0;
int TradesExecuted3 = 0;

double NonExecutedVolume = 0;

double FourthWindowVolume = TotalTradeVolume * 0.30;

double AvgExecutionPrice4 = 0;
int TradesExecuted4 = 0;


double TotalNonExecutedAmount = 0;
double TotalExecutedAmount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    EventSetTimer(60 * 6);  // Set a timer to call OnTimer() every 6 minutes
    lastTradeTime = TimeCurrent();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    datetime currentTime = TimeLocal();
    int currentHour = TimeHour(currentTime);
    Print(currentHour);
    Print(currentTime);

    // First execution window 15, 17
    if (currentHour >= 15 && currentHour < 17)
    {
        double executedVolume = TradesExecuted1 * LotSize;

        if (executedVolume < FirstWindowVolume)
        {
            double lots = CalculateLotSize(LotSize);
            int ticket = OrderSend(SymbolToTrade, OP_BUY, lots, Ask, 3, 0, 0, "USDCHF First Window", 0, 0, clrGreen);

            if (ticket < 0)
            {
                Print("Error opening order: ", GetLastError());
            }
            else
            {
                Print("Order opened successfully: ", ticket);
                TradesExecuted1++;
                AvgExecutionPrice1 = ((AvgExecutionPrice1 * (TradesExecuted1 - 1)) + Ask) / TradesExecuted1;
                lastTradeTime = currentTime;
}
}
            Print(AvgExecutionPrice1);
}



    // Second execution window
    if (currentHour >= 19 && currentHour < 22)
    {
        double executedVolume = TradesExecuted2 * LotSize;

        if (executedVolume < SecondWindowVolume)
        {
            double lots = CalculateLotSize(LotSize);
            int orderType;

            if (Bid >= AvgExecutionPrice1)
            {
                orderType = OP_BUY;
            }
            else
            {
                return;
            }

            int ticket = OrderSend(SymbolToTrade, orderType, lots, (orderType == OP_BUY) ? Ask : Bid, 3, 0, 0, "USDCHF Second Window", 0, 0, clrBlue);

            if (ticket < 0)
            {
                Print("Error opening order: ", GetLastError());
            }
            else
            {
                Print("Order opened successfully: ", ticket);
                TradesExecuted2++;
                double executedPrice = (orderType == OP_BUY) ? Ask : Bid;
                AvgExecutionPrice2 = ((AvgExecutionPrice2 * (TradesExecuted2 - 1)) + executedPrice) / TradesExecuted2;
                lastTradeTime = currentTime;
            }
        }

        NonExecutedVolume = SecondWindowVolume - TradesExecuted2 * LotSize;



}

             
       // Third execution window
if (currentHour >= 23 || currentHour < 1)
{
    double updatedThirdWindowVolume = ThirdWindowVolume + NonExecutedVolume;
    double executedVolume = TradesExecuted3 * LotSize;

    if (executedVolume < updatedThirdWindowVolume)
    {
        double lots = CalculateLotSize(LotSize);
        int orderType;

        if (Bid >= AvgExecutionPrice2)
        {
            orderType = OP_BUY;
        }
        else
        {
            return;
        }

        int ticket = OrderSend(SymbolToTrade, orderType, lots, (orderType == OP_BUY) ? Ask : Bid, 3, 0, 0, "USDCHF Third Window", 0, 0, clrYellow);

        if (ticket < 0)
        {
            Print("Error opening order: ", GetLastError());
        }
        else
        {
            Print("Order opened successfully: ", ticket);
            TradesExecuted3++;
            double executedPrice = (orderType == OP_BUY) ? Ask : Bid;
            AvgExecutionPrice3 = ((AvgExecutionPrice3 * (TradesExecuted3 - 1)) + executedPrice) / TradesExecuted3;
            lastTradeTime = currentTime;
        }
    }

    NonExecutedVolume = updatedThirdWindowVolume - TradesExecuted3 * LotSize;

    Print("NonExecutedVolume:", NonExecutedVolume);
    Print("Average", AvgExecutionPrice3);
}

// Fourth execution window
if (currentHour >= 3 && currentHour < 6)
{
    double updatedFourthWindowVolume = FourthWindowVolume + NonExecutedVolume;
    double executedVolume = TradesExecuted4 * LotSize;

    if (executedVolume < updatedFourthWindowVolume)
    {
        double lots = CalculateLotSize(LotSize);
        int orderType;

        if (Bid >= AvgExecutionPrice3)
        {
            orderType = OP_BUY;
        }
        else
        {
            return;
        }

        int ticket = OrderSend(SymbolToTrade, orderType, lots, (orderType == OP_BUY) ? Ask : Bid, 3, 0, 0, "USDCHF Fourth Window", 0, 0, clrPurple);

        if (ticket < 0)
        {
            Print("Error opening order: ", GetLastError());
        }
        else
        {
            Print("Order opened successfully: ", ticket);
            TradesExecuted4++;
            double executedPrice = (orderType == OP_BUY) ? Ask : Bid;
            AvgExecutionPrice4 = ((AvgExecutionPrice4 * (TradesExecuted4 - 1)) + executedPrice) / TradesExecuted4;
            lastTradeTime = currentTime;
        }
    }

    executedVolume = TradesExecuted4 * LotSize;
    TotalExecutedAmount = (TradesExecuted1 * LotSize) + (TradesExecuted2 * LotSize) + (TradesExecuted3 * LotSize) + executedVolume;
    TotalNonExecutedAmount = updatedFourthWindowVolume - executedVolume;

    Print("TotalExecutedAmount:", TotalExecutedAmount);
    Print("TotalNonExecutedAmount:", TotalNonExecutedAmount);
    Print("Average", AvgExecutionPrice4);
}

}

    
    


//+------------------------------------------------------------------+

