#!/bin/bash

KEYCLOAK_HOST="http://localhost:8080"
API_HOST="http://localhost:8000"
REALM="eucomida"
CLIENT_ID="pedido-service"
USERNAME="cliente1"
PASSWORD="cliente123"
CLIENTE_ID_PARA_TESTE="c41b3f00-49e8-4cf7-8126-2872f243f10f"

print_header() {
    echo ""
    echo "================================================="
    echo " $1"
    echo "================================================="
}

print_header "1. Solicitando Token de Acesso (Keycloak)"
echo "Para o usuário: $USERNAME..."

RESPONSE=$(curl -s \
  -X POST "${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}")

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r .access_token)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "Falha ao obter token. Resposta do Keycloak: ❌"
  echo "$RESPONSE"
  exit 1
fi

echo "Token obtido com sucesso! ✅"

print_header "2. Criando um Novo Pedido (POST /pedidos) Kong Gateway --> Pedido-Service"

POST_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST "${API_HOST}/api/v1/pedidos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{\"clienteId\": \"${CLIENTE_ID_PARA_TESTE}\"}")

HTTP_BODY=$(echo "$POST_RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$POST_RESPONSE" | tail -n1 | cut -d: -f2)

if [ "$HTTP_STATUS" -ne 201 ]; then
    echo "Falha ao criar o pedido. Status: $HTTP_STATUS ❌"
    echo "   Resposta: $HTTP_BODY"
    exit 1
fi

PEDIDO_ID=$(echo "$HTTP_BODY" | jq -r .id)

echo "Pedido criado com sucesso! ✅"
echo "   ID do Pedido: $PEDIDO_ID"

print_header "3. Consultando Status do Pedido Criado (GET /pedidos/{id}/status) Kong Gateway --> Pedido-Service"
echo "Consultando o pedido com ID: ${PEDIDO_ID}..."

GET_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X GET "${API_HOST}/api/v1/pedidos/${PEDIDO_ID}/status" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

HTTP_BODY_GET=$(echo "$GET_RESPONSE" | sed '$d')
HTTP_STATUS_GET=$(echo "$GET_RESPONSE" | tail -n1 | cut -d: -f2)

if [ "$HTTP_STATUS_GET" -ne 200 ]; then
    echo "Falha ao consultar o status. Status: $HTTP_STATUS_GET ❌"
    echo "   Resposta: $HTTP_BODY_GET"
    exit 1
fi

echo "Status consultado com sucesso! ✅"
echo "   Resposta (Status): $HTTP_BODY_GET"
echo ""
echo -e "\033[1;32mScript de teste de fluxo completo finalizado com sucesso! 🎉\033[0m"
echo""