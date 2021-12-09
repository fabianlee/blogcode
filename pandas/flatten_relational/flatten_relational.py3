#!/usr/bin/env python3
# encoding=utf8
#
# Flattens out AdventureWorks relational database Sales orders
#
# https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/oltp-install-script
#
# Requirement:
#   pip3 install pandas --user
#
import sys
import argparse
import datetime
import pandas as pd



######### MAIN ##########################

ap = argparse.ArgumentParser()
ap.add_argument('-r', '--rows', type=int, default="500", help="number of sales rows to process")
ap.add_argument('-d', '--debug', action="store_true", help="whether to show debug print")
args = ap.parse_args()
rows = args.rows
debug = args.debug
print("Showing {} max sales rows, debug={}".format(rows,debug))

# read relational CSV files into DataFrames
sales_data = pd.read_csv("SalesOrderHeader.csv",encoding="unicode_escape",sep="\t",nrows=rows)
creditcard_data = pd.read_csv("CreditCard.csv",encoding="unicode_escape",sep="\t")
address_data = pd.read_csv("Address.csv",encoding="unicode_escape",sep="\t")
state_data = pd.read_csv("StateProvince8.csv",encoding="unicode_escape",sep="\t",on_bad_lines="warn",header=0)

# define columns since these files do not have headers
creditcard_data.columns = ["id","cardtype","cardnumber","expmonth","expyear","modifieddate"]
address_data.columns = ["id","line1","line2","city","state","postalcode","spatialloc","guid","modifieddate"]
state_data.columns = ["id","code","regioncode","isstateprovince","name","territoryid","guid","modifieddata"]
sales_data.columns = ["id","revision","orderdate","duedate","shipdate","status","onlineflag","salesnum","ponum","acctnum","custid","salespersonid","territoryid","billtoaddressid","shiptoaddressid","shipmethodid","ccid","ccapproval","currencyrateid","subtotal","taxamt","freight","totaldue","comment","guid","modifieddate"]



# build final flattened DataFrame
flattened_results = pd.DataFrame( columns = [ "order.id","order.date","address.city","address.state","sales.tax","sales.total","credit.type" ] )

# go through each row of Sales (SalesOrderHeader.csv), resolve relational foreign keys
for _,sales_row in sales_data.iterrows():

    # lookup address by id (Address.csv)
    address_row = address_data[address_data['id'] == sales_row["billtoaddressid"]].iloc[0]
    # lookup state by id (StateProvince8.csv)
    state_res = state_data[state_data['id'] == address_row['state']]
    # lookup credit card by id (CreditCard.csv)
    card_res = creditcard_data[creditcard_data['id'] == sales_row["ccid"]]

    # show Sale, but only if state and card resolved
    if not state_res.empty and not card_res.empty:
      # get first row of state results
      state_row = state_res.iloc[0]
      # get first row of card results
      card_row = card_res.iloc[0]
      # convert str to datetime
      order_date = pd.to_datetime( sales_row["orderdate"] )

      # add result row to final DataFrame
      flattened_results.loc[len(flattened_results.index)] = [
          sales_row['id'],
          order_date,
          address_row['city'],
          state_row['name'],
          sales_row['taxamt'],
          sales_row['totaldue'],
          card_row['cardtype'],
          ]

      if debug:
        print("ORDER {} on {} from {},{} for ${} charged to {} calc taxrate {}".format(
            sales_row['id'],
            order_date.strftime('%a %Y-%m-%d'),
            address_row['city'],
            state_row['name'],
            sales_row["totaldue"],
            card_row["cardtype"],sales_row['taxamt']/sales_row['totaldue'])
            )

# write DataFrame to csv, leave off internal id
flattened_results.to_csv("flattened_sales_data.csv", index=False)

# sample of flattened results
print("")
print(flattened_results)



# derive new DataFrame, grouped by state
flattened_and_grouped = flattened_results.groupby(['address.state']).sum()

# create synthesized tax rate column based on tax/total
flattened_and_grouped = flattened_and_grouped.assign(synthtaxrate = lambda x: x['sales.tax']/x['sales.total'] )

# write grouped DataFrame to csv
flattened_and_grouped.to_csv("flattened_sales_by_state.csv")

# format tax and total columns into currency for viewing
for col in ['sales.tax','sales.total']:
  flattened_and_grouped[col] = flattened_and_grouped[col].apply(lambda x: "${:.1f}k".format((x/1000)))
# format tax rate float to 3 significant decimal points
flattened_and_grouped['synthtaxrate'] = flattened_and_grouped['synthtaxrate'].apply(lambda x: "{0:.3f}".format(x) )

print("\n\n=== TOTAL TAX AND SALES BY STATE =======================")
with pd.option_context('display.max_rows',10):
  print(flattened_and_grouped)



