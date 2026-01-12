#!/bin/bash
#
# Shows how to use either aws CLI JMESPath syntax to query for AWS DB instances that are standalone (and not part of cluster membership)
# OR alternatively using jq to filter
#

echo "===== DB Instances that are standalone, no cluster membership"

echo "using aws cli only, show DB instances that are standalone"
aws rds describe-db-instances --no-cli-pager --query "DBInstances[?DBClusterIdentifier==null].DBInstanceIdentifier" --output text
echo "using aws cli and jq, show DB instances that are standalone"
aws rds describe-db-instances --no-cli-pager | jq '.DBInstances[] | select(has("DBClusterIdentifier")|not).DBInstanceIdentifier' -r

echo "=====DB Instances that are member of cluster"

echo "using aws cli only, show DB instances that are part of Cluster membership"
aws rds describe-db-instances --no-cli-pager --query "DBInstances[?DBClusterIdentifier!=null].DBInstanceIdentifier" --output text
echo "using aws cli and jq, show DB instances that are part of Cluster membership"
aws rds describe-db-instances --no-cli-pager | jq '.DBInstances[] | select(has("DBClusterIdentifier")).DBInstanceIdentifier' -r
