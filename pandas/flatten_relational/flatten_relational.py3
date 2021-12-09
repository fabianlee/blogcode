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
ap.add_argument('-r', '--rows', type=int, default="20", help="number of sales rows to process")
args = ap.parse_args()
rows = args.rows

# read CSV files into DataFrames
sales_data = pd.read_csv("SalesOrderHeader.csv",encoding="unicode_escape",sep="\t",nrows=rows)
creditcard_data = pd.read_csv("CreditCard.csv",encoding="unicode_escape",sep="\t")
address_data = pd.read_csv("Address.csv",encoding="unicode_escape",sep="\t")
state_data = pd.read_csv("StateProvince8.csv",encoding="unicode_escape",sep="\t",on_bad_lines="warn",header=0)

creditcard_data.columns = ["id","cardtype","cardnumber","expmonth","expyear","modifieddate"]
#print(creditcard_data)

address_data.columns = ["id","line1","line2","city","state","postalcode","spatialloc","guid","modifieddate"]
#print(address_data)

state_data.columns = ["id","code","regioncode","isstateprovince","name","territoryid","guid","modifieddata"]
#print(state_data)

sales_data.columns = ["id","revision","orderdate","duedate","shipdate","status","onlineflag","salesnum","ponum","acctnum","custid","salespersonid","territoryid","billtoaddressid","shiptoaddressid","shipmethodid","ccid","ccapproval","currencyrateid","subtotal","taxamt","freight","totaldue","comment","guid","modifieddate"]
#print(sales_data)


# go through each row of Sales, resolve relational database keys (SalesOrderHeader.csv)
for _,sales_row in sales_data.iterrows():

    # lookup address by id (Address.csv)
    address_row = address_data[address_data['id'] == sales_row["billtoaddressid"]].iloc[0]
    # lookup state by id (StateProvince8.csv)
    state_res = state_data[state_data['id'] == address_row['state']]
    # lookup credit card by id (CreditCard.csv)
    card_res = creditcard_data[creditcard_data['id'] == sales_row["ccid"]]

    # show Sale if state and card are resolved
    if not state_res.empty and not card_res.empty:
      # get first row of state results
      state_row = state_res.iloc[0]
      # get first row of card results
      card_row = card_res.iloc[0]
      # convert str to datetime
      order_date = pd.to_datetime( sales_row["orderdate"] )
      print("ORDER on {} from {},{} for ${} charged to {}".format(
          order_date.strftime('%a %Y-%m-%d'),
          address_row['city'],
          state_row['name'],
          sales_row["totaldue"],
          card_row["cardtype"]))

# TODO take DataFrame created above and group by state then write to CSV
