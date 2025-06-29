# Changelog

Todas as mudanças significativas do projeto **euComida** serão documentadas aqui.

Este projeto segue o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
e adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [1.0.2] - 2025-06-28
### Adicionado
- Suporte a autenticação 2FA (dois fatores) usando OTP (One-Time Password) integrado ao Keycloak.
- Fluxo de autenticação configurado com `Browser - Conditional OTP` e `auth-otp-form`.
- Usuário `cliente2` exigido a registrar 2FA na primeira autenticação (ação requerida `CONFIGURE_OTP`).
- Validação de código TOTP via aplicativo autenticador (ex: Google Authenticator, Authy).

### Alterado
- Atualização do fluxo `browser` no Keycloak para condicionar o uso de OTP apenas a usuários com 2FA ativo.


---

## [1.0.1] - 2025-06-27
### Adicionado
- Exposição da versão da aplicação via endpoint `/actuator/info`
- Suporte a changelog documentado para controle de releases
- Ambiente de observabilidade completo (Prometheus, Grafana, OpenTelemetry Collector e Loki)

### Corrigido
- Ajuste da configuração do Keycloak para permitir acesso externo ao admin console
- Correção no issuer-uri para funcionar com comunicação entre containers

---

## [1.0.0] - 2025-06-25
### Adicionado
- MVP do serviço `pedido-service` com endpoints REST:
    - Criação de pedidos (`POST /pedidos`)
    - Consulta de status do pedido (`GET /pedidos/{id}/status`)
- Integração com Keycloak para autenticação OAuth2/JWT
- Banco de dados PostgreSQL configurado via Docker
- Gateway de API com Kong em modo declarativo
- Exportador Prometheus para PostgreSQL
- Containerização completa com Docker Compose
- Importação automatizada de realm no Keycloak
