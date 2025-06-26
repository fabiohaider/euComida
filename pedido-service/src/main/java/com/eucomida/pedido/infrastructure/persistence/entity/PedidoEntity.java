
package com.eucomida.pedido.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "pedidos")
@Getter
@Setter
@NoArgsConstructor
@SuppressWarnings("unused")
public class PedidoEntity {

    @Id
    private UUID id;

    @Column(name = "cliente_id", nullable = false)
    private UUID clienteId;

    @Enumerated(EnumType.STRING)
    private com.eucomida.pedido.domain.enums.Status status;

    @Column(name = "data_criacao")
    private Instant dataCriacao;

}
