#!/usr/bin/env python3
# encoding=utf8
#
# Flattens out Employee sample database from live MariaDB databse
# illustrates how DataFrame can be created from calls to relational database
#
# blog: https://fabianlee.org/2021/12/11/python-constructing-dataframe-from-a-relational-database-with-pandas/
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
ap.add_argument('-H', '--host', default="172.17.0.2", help="IP address of MariaDB server")
ap.add_argument('-u', '--user', default="root", help="user for MariaDB server")
ap.add_argument('-p', '--password', default="thepassword", help="password for MariaDB server")
ap.add_argument('-d', '--debug', action="store_true", help="whether to show debug print")
args = ap.parse_args()
debug = args.debug

# connect to MariaDB server
db_conn = mysql.connector.connect(
      host=args.host,
      user=args.user,
      passwd=args.password,
      database="employees"
    )
# simplest test of DB connection
all_tables = pd.read_sql("show tables",db_conn)
#print(all_tables)

department_name = "Finance"

# lookup finance department ID from database
#try:
#  cursor = db_conn.cursor()
#  statement = "SELECT dept_no from departments where dept_name=%s"
#  data = (department_name,)
#  cursor.execute(statement, data)
#  for (thenum) in cursor:
#    department_no = thenum[0]
#except mysql.connector.Error as e:
#  print(f"Error finding department number from database: {e}")
#print("department_no = {}".format(department_no))


#
# APPROACH #1:
# pull DataFrame in single SQL complex query
#
print("")
print("=================================================")
print("  DataFrame using single SQL with complex join")
print("=================================================")

employee_data = pd.read_sql("""
        SELECT d.dept_no,d.dept_name,e.emp_no,e.first_name, e.last_name, t.title 
        FROM employees e
        INNER JOIN dept_emp de ON e.emp_no=de.emp_no
        INNER JOIN departments d ON d.dept_no=de.dept_no
        INNER JOIN titles t ON e.emp_no=t.emp_no
        WHERE d.dept_name='{}'
        """.format(department_name),
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

print("Select department info for each employee in {}...".format(department_name))
# can filter by dept_name because it is available
dept_info = pd.read_sql("""
        SELECT d.dept_no,d.dept_name,de.emp_no
        FROM departments d, dept_emp de
        WHERE d.dept_name='{}' AND d.dept_no=de.dept_no
        """.format(department_name),
        db_conn)

print("Select titles just for {} group..".format(department_name))
# need to filter by dept_no because name is not available
titles = pd.read_sql("""
        SELECT t.emp_no,t.title
        FROM titles t
        INNER JOIN dept_emp de ON de.emp_no=t.emp_no
        WHERE de.dept_no = (select de.dept_no from departments de where de.dept_name='{}')
        """.format(department_name),
        db_conn)

print("Select employees in {}...".format(department_name))
employees_from_dept = pd.read_sql("""
        SELECT de.dept_no,e.emp_no,e.last_name,e.first_name
        FROM employees e
        INNER JOIN dept_emp de ON de.emp_no=e.emp_no
        WHERE de.dept_no = (select de.dept_no from departments de where de.dept_name='{}')
        """.format(department_name),
        db_conn)

# merge department and employee data
employees_merged = pd.merge(dept_info,employees_from_dept,how="left",left_on="emp_no",right_on="emp_no",suffixes=(None,"_e") )
# additional merge of titles
employees_merged = pd.merge(employees_merged,titles,how="left",left_on="emp_no",right_on="emp_no",suffixes=(None,"_e") )

print(employees_merged)

