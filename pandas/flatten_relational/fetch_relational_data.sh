#!/bin/bash

echo "Fetching relevant csv datafiles from Microsoft AdventureWorks relational database..."

for f in StateProvince.csv SalesOrderHeader.csv Address.csv CreditCard.csv instawdb.sql; do
  [ -f $f ] || wget -q https://github.com/microsoft/sql-server-samples/raw/master/samples/databases/adventure-works/oltp-install-script/$f
done

# some files are in utf-16 with multi-char separator
# they would be cleaned like this
#iconv -f utf-16 -t utf-8 BusinessEntity.csv -o BusinessEntity8.csv
#cat BusinessEntity8.csv | tr -d "+" | sed  's/&\|$//' > BusinessEntity-clean.csv

# convert from utf-16 to utf-8 for proper parsing by pandas
iconv -f utf-16 -t utf-8 StateProvince.csv -o StateProvince8.csv

ls -l *.csv
