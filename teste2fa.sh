#!/bin/bash

# === CONFIGURAÇÕES ===
KEYCLOAK_HOST="http://localhost:8080"
REALM="eucomida"
CLIENT_ID="pedido-service"
USERNAME="cliente2"       # <-- Usuário com 2FA
PASSWORD="cliente123"     # <-- Senha do usuário

# --- OBTENÇÃO DO TOKEN JWT COM 2FA ---
echo "🔐 Solicitando token de acesso para usuário com 2FA: $USERNAME..."

# 1. PEGUE O CÓDIGO ATUAL DO SEU APP AUTENTICADOR E COLOQUE AQUI
OTP_CODE="123456" # <--- SUBSTITUA PELO CÓDIGO DE 6 DÍGITOS VÁLIDO

if [ "$OTP_CODE" == "123456" ]; then
    echo -e "\n\033[1;33mAVISO: Por favor, edite este script e substitua '123456' pelo código 2FA atual do seu aplicativo.\033[0m\n"
fi

RESPONSE=$(curl -s \
  -X POST "${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}" \
  -d "totp=${OTP_CODE}") # <--- O NOVO PARÂMETRO ESSENCIAL

ACCESS_TOKEN=$(echo $RESPONSE | jq -r .access_token)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Falha ao obter token. Verifique se o código 2FA está correto e não expirou."
  echo "   Resposta do Keycloak: $RESPONSE"
  exit 1
fi

echo "✅ Token obtido com sucesso para usuário com 2FA!"
echo
echo "🔗 Token JWT (parcial):"
echo "${ACCESS_TOKEN:0:80}..."

# A partir daqui, o resto do script que chama a API de pedidos funciona da mesma forma
# ...