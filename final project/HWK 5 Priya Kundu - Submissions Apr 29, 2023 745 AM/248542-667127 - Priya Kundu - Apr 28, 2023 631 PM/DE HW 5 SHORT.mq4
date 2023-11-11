//+------------------------------------------------------------------+
//|                                                DE HW 5 SHORT.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double amount = 1000000;
input string orderType = "Sell";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   Print("TWAP execution started");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("TWAP execution completed");
   EventKillTimer();
   Alert("TWAP execution completed");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
    int hour = Hour(); // Get current hour
    Print("OnTimer() function executed");
    Print(hour);

    // Initialize variables for tracking order execution
    static double totalExecuted = 0;
    static double totalNonExecuted = 0;
    static double totalAmount = 1000000;
    static double executedAmount = 0;
    static double nonExecutedAmount = 0;
    static double twapPrice = 0;
    static double window1Price = 0;
    static double window2Price = 0;
    static double window3Price = 0;
    static double window4Price = 0;
    static int unitsPerTrade = 0;
    static int tradeCounter = 0;

    // Define execution windows and number of units to execute
    if (hour >= 15 && hour < 17) {
        // First execution window: 20% of total order (200K units)
        unitsPerTrade = 10000;
        int tradesToExecute = 20;
        if (tradeCounter < tradesToExecute) {
            if (Minute() % 6 == 0) {
                double lots = unitsPerTrade / 100000.0;
                OrderSend("USDCAD", OP_BUY, lots, Ask, 2, Bid-15*Point, Bid+15*Point, "TWAP_Order");
                executedAmount += unitsPerTrade;
                tradeCounter++;
            }
        }
    } else if (hour >= 19 && hour < 22) {
        // Second execution window: 30% of total order (300K units)
        unitsPerTrade = 10000;
        int tradesToExecute = 30;
        if (tradeCounter < tradesToExecute) {
            if (Minute() % 6 == 0) {
                // Check if current price is greater than or equal to window 1 price
                if (Ask >= window1Price) {
                    double lots = unitsPerTrade / 100000.0;
                    OrderSend("USDCAD", OP_BUY, lots, Ask, 2, Bid-15*Point, Bid+15*Point, "TWAP_Order");
                    executedAmount += unitsPerTrade;
                    tradeCounter++;
                }
            }
        }
    } else if (hour >= 23 || hour < 1) {
        // Third execution window: 20% of total order (200K units)
        unitsPerTrade = (totalNonExecuted + 200000) / 20;
        int tradesToExecute = 20;
        if (tradeCounter < tradesToExecute) {
            if (Minute() % 6 == 0) {
                // Check if current price is greater than or equal to window 2 price
                if (Ask >= window2Price) {
                    double lots = unitsPerTrade / 100000.0;
                    OrderSend("USDCAD", OP_BUY, lots, Ask, 2, Bid-15*Point, Bid+15*Point, "TWAP_Order");
                    executedAmount += unitsPerTrade;
                    tradeCounter++;
                }
            }
        }
    } else if (hour >= 3 && hour < 6) {
        // Fourth execution window: 30% of total order (300K units)
        unitsPerTrade = (totalNonExecuted + nonExecutedAmount + 300000) / 30;
        int tradesToExecute = 30;
        if (tradeCounter < tradesToExecute) {
            if (Minute() % 6 == 0) {
                // Check if current price is greater than or equal to window 3 price
                if (Ask >= window3Price) {
                    double lots = unitsPerTrade / 100000.0;
                    OrderSend("USDCAD", OP_BUY, lots, Ask, 2, Bid-15*Point, Bid+15*Point, "TWAP_Order");
                    executedAmount += unitsPerTrade;
                    tradeCounter++;
                }
            }
        }
                    
      }
      
      // Calculate total executed and non-executed amounts
      double FinalNonExecuted = totalAmount - executedAmount;
      double FinalExecuted = unitsPerTrade;

      // Print results
      Print("Total executed quantity: ", DoubleToStr(FinalExecuted, 2));
      Print("Total non-executed quantity: ", DoubleToStr(FinalNonExecuted, 2));

   
  }
//+------------------------------------------------------------------+
