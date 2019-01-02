#
# Runs smoke test on AWS SDK for Python
# list regions
#

# boto3 library
import boto3

# create client
ec2 = boto3.client('ec2')

# Retrieves all regions/endpoints that work with EC2
response = ec2.describe_regions()
#print('Regions:', response['Regions'])

# prints each region details
for region in response['Regions']:
      print("Name: {:16} Endpoint: {}".format(region['RegionName'],region['Endpoint']))

