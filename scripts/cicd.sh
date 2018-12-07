#!/bin/bash

# Create Projects
oc new-project tasks-dev --display-name="Tasks - DEV"
oc new-project tasks-test --display-name="Tasks - TEST"
oc new-project tasks-prod --display-name="Tasks - PROD"
oc new-project cicd-dev --display-name="CI/CD - DEV"

# Grant Jenkins Access to Projects
oc policy add-role-to-group edit system:serviceaccounts:cicd-dev -n tasks-dev
oc policy add-role-to-group edit system:serviceaccounts:cicd-dev -n tasks-test
oc policy add-role-to-group edit system:serviceaccounts:cicd-dev -n tasks-prod

# Deploy Demo
oc new-app -n cicd-dev jenkins-persistent
oc new-app -n cicd-dev -f /root/advanced_deployment_homework/yaml/cicd-template.yaml

# Waiting for project to complete  and then Start Pipeline
echo "Waiting for cicd-demo-installer to complete..."
sleep 300
echo "Starting Pipeline: tasks-pipeline..."
oc start-build tasks-pipeline

# sleep for 10 minutes to allow pipeline to finish
sleep 600
oc set resources dc/tasks --requests=cpu=100m -n tasks-prod
oc autoscale dc/tasks --min 1 --max 5 --cpu-percent=80 -n tasks-prod