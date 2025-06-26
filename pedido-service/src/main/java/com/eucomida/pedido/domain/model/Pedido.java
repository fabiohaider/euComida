
package com.eucomida.pedido.domain.model;

import com.eucomida.pedido.domain.enums.Status;

import java.time.Instant;
import java.util.UUID;

@SuppressWarnings("unused")
public record Pedido(
    UUID id,
    UUID clienteId,
    Status status,
    Instant dataCriacao
) {
    public static Pedido criarNovo(UUID clienteId) {
        return new Pedido(UUID.randomUUID(), clienteId, Status.EM_ANDAMENTO, Instant.now());
    }

    public Pedido comStatus(Status novoStatus) {
        return new Pedido(this.id, this.clienteId, novoStatus, this.dataCriacao);
    }
}
