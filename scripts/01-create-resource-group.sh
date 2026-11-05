#!/usr/bin/env bash
set -euo pipefail

# Recursos compartilhados
GROUP="rg-zeroviagem"
LOCATION="chilecentral"
SKU="B1"
PLAN="plan-zeroviagem"
KEYVAULT_NAME="kv-zeroviagem"
DEPLOY_IDENTITY_NAME="id-zeroviagem-deploy"

# Recursos individuais
APP_JAVA="app-zeroviagem-java"
APP_DOTNET="app-zeroviagem-dotnet"
APP_AI="app-zeroviagem-ai"

# Registrar provedores
az provider register --namespace Microsoft.Resources --wait
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.KeyVault --wait
az provider register --namespace Microsoft.ManagedIdentity --wait

# Resource Group
az group create \
  -n "$GROUP" \
  -l "$LOCATION"

# App Service Plan compartilhado
az appservice plan create \
  -g "$GROUP" \
  -n "$PLAN" \
  -l "$LOCATION" \
  --sku "$SKU" \
  --is-linux

# App Service Java
az webapp create \
  -g "$GROUP" \
  --plan "$PLAN" \
  -n "$APP_JAVA" \
  --runtime "JAVA:17-java17"

# App Service .NET
az webapp create \
  -g "$GROUP" \
  --plan "$PLAN" \
  -n "$APP_DOTNET" \
  --runtime "DOTNETCORE:8.0"

# App Service IA (Python)
az webapp create \
  -g "$GROUP" \
  --plan "$PLAN" \
  -n "$APP_AI" \
  --runtime "PYTHON:3.11"

# Key Vault compartilhado
az keyvault create \
  -g "$GROUP" \
  -n "$KEYVAULT_NAME" \
  -l "$LOCATION" \
  --enable-rbac-authorization true

# Identidade gerenciada para deploy
az identity create \
  -g "$GROUP" \
  -n "$DEPLOY_IDENTITY_NAME" \
  -l "$LOCATION"

# Identidade gerenciada das aplicações
az webapp identity assign \
  -g "$GROUP" \
  -n "$APP_JAVA"

az webapp identity assign \
  -g "$GROUP" \
  -n "$APP_DOTNET"

az webapp identity assign \
  -g "$GROUP" \
  -n "$APP_AI"

echo "Infraestrutura GS2 provisionada."
