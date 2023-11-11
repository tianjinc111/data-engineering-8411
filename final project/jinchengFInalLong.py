import oandapyV20
import oandapyV20.endpoints.orders as orders
import oandapyV20.endpoints.pricing as pricing
from oandapyV20.contrib.requests import MarketOrderRequest
from oandapyV20 import API
from oandapyV20.exceptions import V20Error
import datetime as dt
import time
from datetime import datetime, timedelta
import pymongo
from pymongo import MongoClient
import pandas as pd

access_token = "d19623d5bf78fd7963cefceac42d4f4f-b44442f20cf7ccbc585a9ed99f783e27"
account_number = "101-001-25509304-001"


# Replace the following with your MongoDB connection string
mongo_conn_str = "mongodb://localhost:27017/"
client = MongoClient(mongo_conn_str)
# Replace 'your_database' and 'your_collection' with your desired database and collection names
db = client['usd_chf_long']


try:
    client = oandapyV20.API(access_token=access_token, environment="practice")
except V20Error as e:
    print("Error: {}".format(e))

api = API(access_token=access_token)

instrument = "USD_CHF"


def place_market_order(units, buy=True):
    if not buy:
        units = -units
    mo = MarketOrderRequest(instrument=instrument, units=units)
    ordr = orders.OrderCreate(account_number, data=mo.data)
    try:
        response = api.request(ordr)
        return response
    except V20Error as e:
        print("Error: {}".format(e))
        return None

def get_price():
    params = {"instruments": instrument}
    pr = pricing.PricingInfo(account_number, params=params)
    try:
        response = api.request(pr)
        prices = response["prices"][0]["bids"][0]["price"]
        return float(prices)
    except V20Error as e:
        print("Error: {}".format(e))
        return None

def main():
    
    # intial variables
    total_order = 100000
    

    # time duration
    start_time1 = datetime.now().replace(hour=15, minute=0, second=0, microsecond=0)
    end_time1 = start_time1 + timedelta(hours=2)

    start_time2 = datetime.now().replace(hour=19, minute=0, second=0, microsecond=0)
    end_time2 = start_time2 + timedelta(hours =3)
    
    start_time3 = datetime.now().replace(hour=23, minute=0, second=0, microsecond=0)
    end_time3 = start_time3 + timedelta(hours = 2)
    
    start_time4 = datetime.now().replace(hour=3, minute=0, second=0, microsecond=0)
    end_time4 = start_time4 + timedelta(hours = 2)
    
    start_time5 = end_time4 + timedelta(minutes=30)
    end_time5 = start_time5 + timedelta(minutes=30)
    
    start_time6 = end_time5 
    end_time6 = start_time6 + timedelta(hours= 3)
    
    
    #tables
    orders_df_window1 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])
    orders_df_window2 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])
    orders_df_window3 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])
    orders_df_window4 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])
    orders_df_window5 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])
    orders_df_window6 = pd.DataFrame(columns=["Execution Window", "Time", "Instrument", "Units", "Price"])

    # variable for window one
    units_per_order_first_window = 1000 
    executed_units1 = 0
    total_price1 = 0
    
    # variable for window two
    executed_units2 = 0
    non_executed_units2 = 0
    total_price2 = 0
    units_per_order_second_window = 1000
    
    # variable for window three
    units_per_order_third_window = (20000 + non_executed_units2) // 20
    executed_units3 = 0
    non_executed_units3 = 0
    total_price3 = 0
    units_to_be_executed_third_window = 20000 + non_executed_units2
    
    # variable for window four
    units_per_order_fourth_window = (30000 + non_executed_units3) // 30
    executed_units4 = 0
    non_executed_units4 = 0
    total_price4 = 0
    units_to_be_executed_fourth_window = 30000 + non_executed_units3

    

    

    
    
    
    # first execution window

    
    while datetime.now() < start_time1:
        time.sleep(1)

    while datetime.now() >= start_time1 and datetime.now() < end_time1:
        if executed_units1 < total_order * 0.2:
            response = place_market_order(units_per_order_first_window)
            if response is not None:
                executed_units1 += units_per_order_first_window
                price = get_price()
                total_price1 += units_per_order_first_window * price
                orders_df_window1 = orders_df_window1.append({"Execution Window": 1, "Time": datetime.now(), "Instrument": instrument, "Units": units_per_order_first_window, "Price": price}, ignore_index=True)
                print(f"price: {price}")
            time.sleep(6 * 60)

    avg_price1 = total_price1 / executed_units1 if executed_units1 > 0 else None
    print(f"First execution window: Executed {executed_units1} units, Average price {avg_price1}")
    print(orders_df_window1)
    
    
    
    # second execution window

    
    while datetime.now() < start_time2:
        time.sleep(1)

    while datetime.now() >= start_time2 and datetime.now() < end_time2:
        if executed_units2 < total_order * 0.3:
        
            if get_price() >= avg_price1:
                response = place_market_order(units_per_order_second_window)
                if response is not None:
                    executed_units2 += units_per_order_second_window
                    price = get_price()
                    total_price2 += units_per_order_second_window * price
                    orders_df_window2 = orders_df_window2.append({"Execution Window": 2, "Time": datetime.now(), "Instrument": instrument, "Units": units_per_order_second_window, "Price": price}, ignore_index=True)

                else:
                    non_executed_units2 += units_per_order_second_window
            else:
                non_executed_units2 += units_per_order_second_window
        time.sleep(6 * 60)
        
    avg_price2 = (total_price1 + total_price2) / (executed_units1 + executed_units2) if executed_units2 > 0 else avg_price1
    print(f"Second execution window: Executed {executed_units2} units, Non-executed {non_executed_units2} units, Average price {avg_price2}")
    print(orders_df_window2)
    
    
    
    
    
    # Third execution window


    while datetime.now() < start_time3:
        time.sleep(1)

    while datetime.now() >= start_time3 and datetime.now() < end_time3:
        if executed_units3 < units_to_be_executed_third_window:

            if get_price() is not None and get_price() >= avg_price2:
                response = place_market_order(units_per_order_third_window)
                if response is not None:
                    executed_units3 += units_per_order_third_window
                    price = get_price()
                    total_price3 += units_per_order_third_window * price
                    orders_df_window3 = orders_df_window3.append({"Execution Window": 3, "Time": datetime.now(), "Instrument": instrument, "Units": units_per_order_third_window, "Price": price}, ignore_index=True)

                else:
                    non_executed_units3 += units_per_order_third_window
            else:
                non_executed_units3 += units_per_order_third_window
        time.sleep(6 * 60)

    avg_price3 = (total_price1 + total_price3 + total_price2) / (executed_units1 + executed_units2 + executed_units3) if executed_units3 > 0 else avg_price2
    
    print(f"Third execution window: Executed {executed_units3} units, Non-executed {non_executed_units3} units, Average price {avg_price3}")
    print(orders_df_window3)

    
    
    
    
    
    # Fourth execution window
    
    while datetime.now() < start_time4:
        time.sleep(1)
    

    while datetime.now() >= start_time4 and datetime.now() < end_time4:
        if executed_units4 < units_to_be_executed_fourth_window:
        
        
            if get_price() is not None and get_price() >= avg_price3:
                response = place_market_order(units_per_order_fourth_window)
                if response is not None:
                    executed_units4 += units_per_order_fourth_window
                    price = get_price()
                    total_price4 += units_per_order_fourth_window * price
                    orders_df_window4 = orders_df_window4.append({"Execution Window": 4, "Time": datetime.now(), "Instrument": instrument, "Units": units_per_order_fourth_window, "Price": price}, ignore_index=True)

                else:
                    non_executed_units4 += units_per_order_fourth_window
            else:
                non_executed_units4 += units_per_order_fourth_window
        time.sleep(6 * 60)

    avg_price4 = (total_price1 + total_price3 + total_price2 + total_price4) / (executed_units1 + executed_units2 + executed_units3 + executed_units4) if executed_units4 > 0 else avg_price3
    
    print(f"Fourth execution window: Executed {executed_units4} units, Non-executed {non_executed_units4} units, Average price {avg_price4}")
    print(orders_df_window4)
    
    
    #calculate the numbers
    executed_units_all = []
    executed_units_all.append(executed_units1)
    executed_units_all.append(executed_units2)
    executed_units_all.append(executed_units3)
    executed_units_all.append(executed_units4)
                          
    non_executed_list = []
    non_executed_list.append(non_executed_units2)
    non_executed_list.append(non_executed_units3)
    non_executed_list.append(non_executed_units4)
                          
    total_actual_executed = sum(executed_units_all)
    total_non_executed_units = sum(non_executed_list)                      
    weighted_avg_price = (total_price1 + total_price2 + total_price3 + total_price4) / total_actual_executed
                          
                          
    
    
    print(f"weighted_avg_price: {weighted_avg_price}")
    print(f"Total non-executed units: {total_non_executed_units}")
    
    while datetime.now() < start_time5:
        time.sleep(1)
                          
                          
    while datetime.now() >= start_time5 and datetime.now() < end_time5:
        current_price = get_price()
        if current_price is not None and current_price >= weighted_avg_price:

            units_to_buy = int(0.5 * total_non_executed_units)
            response = place_market_order(units_to_buy)
            if response is not None:
                price = get_price()
                orders_df_window5 = orders_df_window5.append({"Execution Window": 5, "Time": datetime.now(), "Instrument": instrument, "Units": units_to_buy, "Price": price}, ignore_index=True)
                break
        time.sleep(60)

    
    print(orders_df_window5)
          
          
            
    
    # New execution window 6

    
    while datetime.now() < start_time6:
        time.sleep(1)
          
            
    executed_units_window5 = orders_df_window5["Units"].sum()
    total_executed_units = total_actual_executed + executed_units_window5
          
          

          


    units_to_sell = int(0.2 * total_order)
    total_units_sold = 0

    while datetime.now() >= start_time6 and datetime.now() < end_time6:
        current_price = get_price()
        if current_price is not None:
            if current_price and current_price >= weighted_avg_price and executed_units_window5 == 0.5 * total_non_executed_units:
                units_to_buy = int(0.5 * total_non_executed_units)
                print(units_to_buy)
                response = place_market_order(units_to_buy)
                if response is not None:
                    print(f"window 6 {price} and average{weighted_avg_price}")
                    price = get_price()
                    orders_df_window6 = orders_df_window6.append({"Execution Window": 6, "Time": datetime.now(), "Instrument": instrument, "Units": units_to_buy, "Price": price}, ignore_index=True)
                    break
                    
            elif executed_units_window5 != 0.5 * total_non_executed_units and current_price < weighted_avg_price:
                if total_units_sold < units_to_sell:
                    units_to_sell_now = 1000
                    response = place_market_order(units_to_sell_now, buy=False)
                    if response is not None:
                        price = get_price()
                        orders_df_window6 = orders_df_window6.append({"Execution Window": 6, "Time": datetime.now(), "Instrument": instrument, "Units": -units_to_sell_now, "Price": price}, ignore_index=True)
                        total_units_sold += units_to_sell_now
                        total_executed_units -= units_to_sell_now
                        
        time.sleep(60)
        
    print(orders_df_window6)
    
    
    order_table_list = [orders_df_window1,orders_df_window2,orders_df_window3,orders_df_window4,orders_df_window5,orders_df_window6]
    
    
    return order_table_list
          
          
    
                          
                          
                          

if __name__ == "__main__":
    
    
    order_table_list = main()



    for idx, window in enumerate(order_table_list):
        if not window.empty:
            window_to_store = window.to_dict("records")
            collection_name = f"window{idx + 1}"
            collection = db[collection_name]
            collection.insert_many(window_to_store)
                          
                          
    
        
                
