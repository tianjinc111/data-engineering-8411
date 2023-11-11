import requests
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime, timedelta
from polygon import RESTClient
from sqlalchemy import inspect

api_key = "beBybSi8daPgsTp5yx5cHtHpYcrjp5Jq"
client = RESTClient(api_key=api_key)

# Define the currency pairs to use
tickers = ["C:EURUSD", "C:USDCAD", "C:USDCHF"]

# Create the SQLite database connection
engine = create_engine('sqlite:///jincheng_fx_data.db')

# Function to process and store data for a given ticker
def process_ticker(ticker):
    # Get data for the specified date range
    date_from = "2023-03-30"
    date_to = "2023-03-30"
    fxdata = client.get_aggs(ticker=ticker, multiplier=1, timespan="minute", from_=date_from, to=date_to)

    # Filter for two consecutive hours
    df = pd.DataFrame([{"timestamp": fx.timestamp, "fx_rate": fx.close} for fx in fxdata])
    df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')

    df = df[(df['timestamp'].dt.hour >= 0) & (df['timestamp'].dt.hour < 2)]


    df["entry_timestamp"] = datetime.utcnow()

    # store the dataframe into the sqllite databased, 
    df.to_sql(f'{ticker[2:]}_data', engine, if_exists='replace', index=False)
    
    print(df)


# for each ticker, repeated the process
for ticker in tickers:
    process_ticker(ticker)

    
    


# Get a list of all table names in the SQLite database
def get_table_names(engine):
    inspector = inspect(engine)
    table_names = inspector.get_table_names()
    return table_names

# Print all table names in the database
table_names = get_table_names(engine)
print("Table names in the SQLite database:")
for table_name in table_names:
    print(table_name)

    
    

query1 = f'SELECT * FROM USDCHF_data'
df_USDCHF_data = pd.read_sql_query(query1, engine)
print(f"USDCHF_data: {df_USDCHF_data}" )

USDCHF_data_average = df_USDCHF_data['fx_rate'].mean()
print(f'USDCHF_data_average:  {USDCHF_data_average}')

filename = "USDCHF_data"
df_USDCHF_data.to_csv(filename, index=False)




query2 = f'SELECT * FROM EURUSD_data'
df_EURUSD_data = pd.read_sql_query(query2, engine)
print(f"EURUSD_data: {df_EURUSD_data}" )

EURUSD_data_average = df_EURUSD_data['fx_rate'].mean()
print(f"EURUSD_data_average: {EURUSD_data_average}")
filename2 = "df_EURUSD_data"
df_EURUSD_data.to_csv(filename2, index=False)


query3 = f'SELECT * FROM USDCAD_data'
df_USDCAD_data = pd.read_sql_query(query3, engine)
print(f"USDCAD_data: {df_USDCAD_data}")
USDCAD_data_average = df_USDCAD_data['fx_rate'].mean()
print(f'USDCAD_data_average:  {USDCAD_data_average}')
filename3 = "df_USDCAD_data"
df_USDCAD_data.to_csv(filename3, index=False)

