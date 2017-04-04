#! /usr/bin/python
#
# Purpose: copies index from ES source instance to ES dest instance
#
# Author: Fabian Lee
#
# References:
# https://www.elastic.co/guide/en/elasticsearch/client/python-api/current/index.html
# http://elasticsearch-py.readthedocs.io/en/master/
#
# Prerequisite:
# pip install elasticsearch
#

import sys
import subprocess
import argparse
from datetime import date,timedelta

# constant for elasticdump binary
ESDUMP = "/usr/local/lib/node_modules/elasticdump/bin/elasticdump"

# check for mandatory src/dest arguments
if len(sys.argv) < 5:
  print "USAGE: baseIndexName src dest ndays [--dry-run]"
  print "EXAMPLE: myindex http://127.0.0.1:9200/ http://127.0.0.1:9200/"
  sys.exit(1)

# sanitize command line arguments
baseIndexName = sys.argv[1]
src = sys.argv[2]
dst = sys.argv[3]
ndays = int(sys.argv[4])
dryrun = False
if len(sys.argv)>5 and "--dry-run"==sys.argv[5]:
  dryrun = True
if not src.endswith("/"):
  src = src + "/"
if not dst.endswith("/"):
  dst = dst + "/"

# shows command line arguments
print "baseIndexName: " + baseIndexName
print "src: " + src
print "dst: " + dst
print "ndays: {0:d}".format(ndays)
print "dryrun: {0}".format(dryrun)

today = date.today()
todaystr = today.strftime('%Y.%m.%d')
print "today: " + todaystr

# establish connection to elasticsearch
from elasticsearch import Elasticsearch
import elasticsearch.exceptions
es_src = Elasticsearch(src)
es_dst = Elasticsearch(dst)

# loop from yesterday, then back ndays
for i in range(1,ndays):
  yesterday = today - timedelta(i)
  yesterdaystr = yesterday.strftime('%Y.%m.%d')
  indexPattern = baseIndexName + "-" + yesterdaystr
  print "----------------------------------------"
  print "src today-{0:d}: {1}".format(i,indexPattern)

  # check for index existence in src using ES API
  data_src = None
  try:
    data_src = es_src.indices.get(index=indexPattern)
    print "index {0} exists on src, continuing to elasticdump".format(indexPattern)
    #print data_src
  except elasticsearch.exceptions.NotFoundError:
    print "index {0} does not exist on source, skipping".format(indexPattern)
    continue
  except:
    print "fatal error contacting ES source",sys.exc_info()
    raise

  # check for index existence in dest using ES API
  data_dst = None
  try:
    data_dst = es_dst.indices.get(index=indexPattern)
  except elasticsearch.exceptions.NotFoundError:
    print "index {0} does not exists on dest, continuing to elasticdump".format(indexPattern)
  except:
    print "fatal error contacting ES destination",sys.exc_info()
    raise

  # only do dump if target does not already have index
  if data_dst is None:
      cmd = "{0} --input={1}{3} --output={2}{3}".format(ESDUMP,src,dst,indexPattern)
      # actually call elasticdump or do dry run
      if dryrun:
        print "--dry-run " + cmd
      else:
        print cmd
        print subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE).stdout.read()
  else:
    print "skipping index {0} because it already exists on destination".format(indexPattern)

