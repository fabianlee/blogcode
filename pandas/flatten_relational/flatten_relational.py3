#!/usr/bin/env python3
# encoding=utf8
#
# Flattens out AdventureWorks relational database orders
#
# Requirement:
#   pip3 install pandas --user
#
import sys
import argparse
import io
import csv
import datetime
import pandas as pd


# look for application name given id
def resolve_app_id(app_id):
    return app_data[app_data['id'] == app_id].iloc[0]['name']

# look for tenant name given id
def resolve_tenant_id(tenant_id):
    return tenant_data[tenant_data['id'] == tenant_id].iloc[0]['company_name']

# look for swift container id in either 'tenant_id' or 'name' column of subscriptions
# multiple rows can be returned because swift container id matches back to tenant (which can have multiple subs)
#
def resolve_swift_container_id(swift_id):
    tenant_res = sub_data[sub_data['tenant_id'] == swift_id]
    if not tenant_res.empty:
        return "TENANTID",tenant_res

    sub_res = sub_data[sub_data['name'] == swift_id]
    if not sub_res.empty:
        return "TENANTNAME",sub_res

    # did not find resolution
    return None,None


######### MAIN ##########################

ap = argparse.ArgumentParser()
ap.add_argument('-d', '--datacenter', default="li3_prod", help="datacenter env name")
args = ap.parse_args()
datacenter = args.datacenter

MAX_SALES = 100


# read CSV files into DataFrames
sales_data = pd.read_csv("SalesOrderHeader.csv",encoding="unicode_escape",sep="\t",nrows=MAX_SALES)
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


sys.exit(0)
