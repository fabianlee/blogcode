#!/bin/bash

# enter virtualenv created earlier
source awscli/bin/activate

# install boto3 python sdk for aws
pip install boto3 --upgrade

# exit virtualenv
deactivate
