#!/bin/bash

rg=$1
servicePlanName=$2
appName=$3
dbName=$4


# Create a resource group.
az group create --location southcentralus --name $rg

# Create an App Service plan in `FREE` tier.
az appservice plan create --name $servicePlanName --resource-group $rg --sku B1 --location southcentralus --is-linux  --number-of-workers 3

# Create a web app.
az webapp create --resource-group $rg --plan $servicePlanName --name $appName -r "node|10.14"

# Configure continuous deployment from GitHub. 
# --git-token parameter is required only once per Azure account (Azure remembers token).
az webapp deployment source config --name $appName --resource-group $rg \
--repo-url 'https://github.com/dernestnelson/revature-p1 ' --branch master 

az cosmosdb create --name $dbName --resource-group $rg --kind GlobalDocumentDB

# Get the GlobalDocumentDB URL
connectionString=$(az cosmosdb list-connection-strings --name $dbName --resource-group $rg \
--query connectionStrings[0].connectionString --output tsv)

# Assign the connection string to an App Setting in the Web App
az webapp config appsettings set --name $appName --resource-group $rg \
--settings "GlobalDocumentDB_URL=$connectionString" 
