#!/bin/bash

echo "Fetching relevant csv datafiles from Microsoft AdventureWorks relational database..."

for f in StateProvince.csv Address.csv BusinessEntity.csv SalesOrderHeader.csv Address.csv CreditCard.csv instawdb.sql; do
  [ -f $f ] || wget https://github.com/microsoft/sql-server-samples/raw/master/samples/databases/adventure-works/oltp-install-script/$f
done

# convert from utf-16 to utf-8 for parsing
iconv -f utf-16 -t utf-8 BusinessEntity.csv -o BusinessEntity8.csv
# cleanup multi-character separator
cat BusinessEntity8.csv | tr -d "+" | sed  's/&\|$//' > BusinessEntity-clean.csv

iconv -f utf-16 -t utf-8 StateProvince.csv -o StateProvince8.csv

ls -l *.csv
