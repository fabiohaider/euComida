#!/bin/bash

KEYCLOAK_HOST="http://localhost:8080"
API_HOST="http://localhost:8000"
REALM="eucomida"
CLIENT_ID="pedido-service"
ADMIN="admin"
ADMIN_PASSWD="admin"
USERNAME="cliente1"
PASSWORD="cliente123"
ADMIN_CLIENT_ID="admin-cli"
CLIENTE_ID_PARA_TESTE="c41b3f00-49e8-4cf7-8126-2872f243f10f"
STATUSOTP="N"
URL_OTP="http://localhost:8080/realms/eucomida/account"

print_header() {
    echo ""
    echo "================================================================"
    echo " $1"
    echo "================================================================"
}

print_header "1. Verificando se OTP está Cadastrado no Authenticator"
echo "🔐 Obtendo token de Administrador..."

TOKEN_ADMIN=$(curl -s \
  -X POST "${KEYCLOAK_HOST}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${ADMIN_CLIENT_ID}" \
  -d "username=${ADMIN}" \
  -d "password=${ADMIN_PASSWD}" \
  | jq -r .access_token)


if [[ -z "$TOKEN_ADMIN" || "$TOKEN_ADMIN" == "null" ]]; then
  echo "❌ Erro ao obter token de Administrador. Verifique usuário/senha e se o Keycloak está no ar."
  exit 1
fi

echo "📋 Verificando usuário $USERNAME no realm '$REALM'..."

USERS=$(curl -s -H "Authorization: Bearer $TOKEN_ADMIN" "$KEYCLOAK_HOST/admin/realms/$REALM/users")

  echo ""

while read -r user; do
  ID=$(echo "$user" | jq -r .id)
  USERNAMEOTP=$(echo "$user" | jq -r .username)

  CREDS=$(curl -s -H "Authorization: Bearer $TOKEN_ADMIN" "$KEYCLOAK_HOST/admin/realms/$REALM/users/$ID/credentials")

  OTP_PRESENT=$(echo "$CREDS" | jq '[.[] | select(.type == "otp")] | length')

  if [[ "$OTP_PRESENT" -gt 0 ]]; then
    STATUS="Usuário com OTP Cadastrado"
  else
    STATUS="Primeiro Cadastre no OTP e Authenticator"
  fi

  if [[ "$USERNAMEOTP" == "$USERNAME" && "$OTP_PRESENT" -gt 0 ]]; then
    STATUSOTP="Y"
  fi

  printf "%-24s| %s\n" "$USERNAMEOTP" "$STATUS"
done < <(echo "$USERS" | jq -c '.[]')

echo ""

if [ "$STATUSOTP" == "Y" ]; then
  echo "✅ $USERNAME Cadastrado no Authenticastor"
  echo ""
else
  echo "❌ $USERNAME Precisa cadastro no OTP e Authenticator"
    echo ""
fi

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  powershell.exe -Command "Start-Process '$URL_OTP'"
else
  case "$OSTYPE" in
    linux*)   xdg-open "$URL_OTP" ;;
    darwin*)  open "$URL_OTP" ;;
    msys*|cygwin*) cmd.exe /c start "$URL_OTP" ;;
    *)        echo "Abra manualmente: $URL_OTP" ;;
  esac
fi

read -n 1 -s -r -p "Cadastre no Authenticator e pressione qualquer tecla para continuar"
echo

print_header "2. Solicitando Token de Acesso (Keycloak)"
echo "🔐 Para o usuário: $USERNAME..."
echo ""

read -p "Digite o código OTP: " TOTP
RESPONSE=$(curl -s \
  -X POST "${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}" \
  -d "totp=${TOTP}")

echo ""

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r .access_token)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Falha ao obter token. Resposta do Keycloak:"
  echo "$RESPONSE"
  exit 1
fi

echo "✅ Token obtido com sucesso!"

print_header "3. Criando um Novo Pedido (POST /pedidos) Kong Gateway --> Pedido-Service"

POST_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST "${API_HOST}/api/v1/pedidos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{\"clienteId\": \"${CLIENTE_ID_PARA_TESTE}\"}")

HTTP_BODY=$(echo "$POST_RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$POST_RESPONSE" | tail -n1 | cut -d: -f2)

if [ "$HTTP_STATUS" -ne 201 ]; then
    echo "❌ Falha ao criar o pedido. Status: $HTTP_STATUS"
    echo "   Resposta: $HTTP_BODY"
    exit 1
fi

PEDIDO_ID=$(echo "$HTTP_BODY" | jq -r .id)

echo "✅ Pedido criado com sucesso!"
echo "   ID do Pedido: $PEDIDO_ID"

print_header "4. Consultando Status do Pedido Criado (GET /pedidos/{id}/status) Kong Gateway --> Pedido-Service"
echo "🔎 Consultando o pedido com ID: ${PEDIDO_ID}..."

GET_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X GET "${API_HOST}/api/v1/pedidos/${PEDIDO_ID}/status" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

HTTP_BODY_GET=$(echo "$GET_RESPONSE" | sed '$d')
HTTP_STATUS_GET=$(echo "$GET_RESPONSE" | tail -n1 | cut -d: -f2)

if [ "$HTTP_STATUS_GET" -ne 200 ]; then
    echo "❌ Falha ao consultar o status. Status: $HTTP_STATUS_GET"
    echo "   Resposta: $HTTP_BODY_GET"
    exit 1
fi

echo "✅ Status consultado com sucesso!"
echo "   Resposta (Status): $HTTP_BODY_GET"
echo ""
echo -e "\033[1;32m🎉  Script de teste de fluxo completo finalizado com sucesso!\033[0m"