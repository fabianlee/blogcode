#!/usr/bin/env python3
# encoding=utf8
#
# Flattens out Employee sample database from mysql
# illustrates how DataFrame can be created from calls to relational database
#
# Module requirement:
#   pip3 install pandas mysql-client mysql-connector --user
#
import sys
import argparse
import datetime
import pandas as pd
import mysql.connector




######### MAIN ##########################

ap = argparse.ArgumentParser()
ap.add_argument('-r', '--rows', type=int, default="500", help="number of sales rows to process")
ap.add_argument('-H', '--host', default="172.17.0.2", help="IP address of MariaDB server")
ap.add_argument('-u', '--user', default="root", help="user for MariaDB server")
ap.add_argument('-p', '--password', default="thepassword", help="password for MariaDB server")
ap.add_argument('-d', '--debug', action="store_true", help="whether to show debug print")
args = ap.parse_args()
rows = args.rows
debug = args.debug
dbhost = args.host
print("Processing {} max rows, debug={}".format(rows,debug))

# connect to MariaDB server
db_conn = mysql.connector.connect(
      host=args.host,
      user=args.user,
      passwd=args.password,
      database="employees"
    )
# simplest test DB connection
all_tables = pd.read_sql("show tables",db_conn)
print(all_tables)


#
# APPROACH #1:
# pull DataFrame in single SQL complex query
#
print("\n\n")
print("=================================================")
print("  DataFrame using single complex SQL")
print("=================================================")

employee_data = pd.read_sql("""
        SELECT d.dept_no,d.dept_name,e.emp_no,e.first_name, e.last_name, t.title 
        FROM employees e
        INNER JOIN dept_emp de ON e.emp_no=de.emp_no
        INNER JOIN departments d ON d.dept_no=de.dept_no
        INNER JOIN titles t ON e.emp_no=t.emp_no
        WHERE d.dept_name='Finance'
        """,
        db_conn)
print(employee_data)




#
# APPROACH #2:
# pull multiple DataFrame and use pandas.merge to flatten
#
print("\n\n")
print("=================================================")
print("  Multiple DataFrame merged by pandas")
print("=================================================")

# select list of employee ids in Finance
departments_and_employees = pd.read_sql("""
        SELECT d.dept_no,d.dept_name,de.emp_no
        FROM departments d, dept_emp de
        WHERE d.dept_name='Finance' AND d.dept_no=de.dept_no
        """,
        db_conn)

# select employees in Finace
#employees_from_department = pd.read_sql("""
#        SELECT de.dept_no,e.emp_no,e.last_name,e.first_name
#        FROM dept_emp de, employees e
#        WHERE de.dept_no in (select dept_no from departments where dept_name='Finance')
#        """,
#        db_conn)

employees_with_titles = pd.read_sql("""
        SELECT e.emp_no,e.first_name,e.last_name,t.title
        FROM employees e
        INNER JOIN titles t ON e.emp_no,t.emp_no
        """,
        db_conn)

employees_merged = pd.merge(employees_with_titles,departments_and_employees,how="left",left_on="emp_no",right_on="emp_no",suffixes=(None,"_t") )
print(employees_merged)

sys.exit(0)

# read relational CSV files into DataFrames
sales_data = pd.read_csv("SalesOrderHeader.csv",encoding="unicode_escape",sep="\t",nrows=rows)
creditcard_data = pd.read_csv("CreditCard.csv",encoding="unicode_escape",sep="\t")
address_data = pd.read_csv("Address.csv",encoding="unicode_escape",sep="\t")
state_data = pd.read_csv("StateProvince8.csv",encoding="unicode_escape",sep="\t",on_bad_lines="warn",header=0)

# define columns since these files do not have headers
# prefixed names (e.g "add." "state.") makes it easier to identify join source later
creditcard_data.columns = ["cc.id","cc.cardtype","cc.cardnumber","cc.expmonth","cc.expyear","cc.modifieddate"]
address_data.columns = ["add.id","add.line1","add.line2","add.city","add.state","add.postalcode","add.spatialloc","add.guid","add.modifieddate"]
state_data.columns = ["state.id","state.code","state.regioncode","state.isstateprovince","state.name","state.territoryid","state.guid","state.modifieddata"]
sales_data.columns = ["id","revision","orderdate","duedate","shipdate","status","onlineflag","salesnum","ponum","acctnum","custid","salespersonid","territoryid","billtoaddressid","shiptoaddressid","shipmethodid","ccid","ccapproval","currencyrateid","subtotal","taxamt","freight","totaldue","comment","guid","modifieddate"]

# inner join on Address add.state-> state.stateid
address_data = pd.merge(address_data,state_data,how="left",left_on="add.state",right_on="state.id",suffixes=(None,"_s") )
if debug:
  address_data.to_csv("address_with_state.csv",index=False)

# inner join on Sales billtoaddressid -> add.id
sales_data = pd.merge(sales_data,address_data,how="left",left_on="billtoaddressid",right_on="add.id",suffixes=(None,"_a") )

# inner join on Sales ccid -> cc.id
sales_data = pd.merge(sales_data,creditcard_data,how="left",left_on="ccid",right_on="cc.id",suffixes=(None,"_c") )

# write out fully expanded Sales data
if debug:
  sales_data.to_csv("sales_with_full_adddress_and_cc.csv",index=False)

# derive new DataFrame, with just a few columns we want to analyze
sales_data_select_columns = sales_data[ ["state.name", "taxamt", "totaldue"]  ]
# sum up the total taxes and purchased, by State
flattened_and_grouped = sales_data_select_columns.groupby(['state.name']).sum()

# create synthesized mean tax rate column based on tax/total
flattened_and_grouped = flattened_and_grouped.assign(meantaxrate = lambda x: x['taxamt']/x['totaldue'] )

# write raw grouped DataFrame to csv
if debug:
  flattened_and_grouped.to_csv("sales_grouped_by_state.csv")

# format tax and total columns into currency for viewing
for col in ['taxamt','totaldue']:
  flattened_and_grouped[col] = flattened_and_grouped[col].apply(lambda x: "${:.1f}k".format((x/1000)))
# format tax rate float to 3 significant decimal points
flattened_and_grouped['meantaxrate'] = flattened_and_grouped['meantaxrate'].apply(lambda x: "{0:.3f}".format(x) )

print("\n\n=== TOTAL TAX AND SALES BY STATE =======================")
with pd.option_context('display.max_rows',10):
  print(flattened_and_grouped)



