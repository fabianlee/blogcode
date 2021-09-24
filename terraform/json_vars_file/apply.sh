#!/bin/bash
terraform init
terraform apply -var-file=variable-values.json -auto-approve
