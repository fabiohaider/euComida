#!/bin/bash

echo "🧼 Limpando ambiente Docker..."
docker compose down -v --remove-orphans && docker system prune -af --volumes

echo "🚀 Subindo a stack completa em segundo plano..."
docker compose up -d --build --force-recreate

wait_for_service() {
    local service_name=$1
    local check_command=$2

    echo -n "⏳ Aguardando o serviço '$service_name' ficar pronto..."
    # O comando eval é usado para executar o comando de verificação passado como string
    while ! eval "$check_command"; do
        echo -n "."
        sleep 2
    done
    echo " ✅"
}

wait_for_service "db (PostgreSQL Principal)" "[ \"\$(docker inspect -f '{{.State.Health.Status}}' postgres)\" = \"healthy\" ]"

wait_for_service "kong" "curl --silent --fail http://localhost:8001/status > /dev/null"
wait_for_service "keycloak" "curl --silent --fail -k http://localhost:8080/realms/eucomida > /dev/null" # -k por causa do .local, se precisar

wait_for_service "loki" "curl --silent --fail http://localhost:3100/ready"
wait_for_service "prometheus" "curl --silent --fail http://localhost:9090/-/healthy > /dev/null"
wait_for_service "grafana" "curl --silent --fail http://localhost:3000/api/health > /dev/null"
wait_for_service "otel-collector" "docker compose logs otel-collector 2>&1 | grep -q 'Everything is ready. Begin running and processing data.'"

echo -e "\n🎉 \033[1;32mStack completa! Todos os serviços estão prontos para uso.\033[0m"