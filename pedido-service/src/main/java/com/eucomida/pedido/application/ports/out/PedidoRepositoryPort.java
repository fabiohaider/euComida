
package com.eucomida.pedido.application.ports.out;

import com.eucomida.pedido.domain.model.Pedido;
import java.util.Optional;
import java.util.UUID;

public interface PedidoRepositoryPort {
    Pedido salvar(Pedido pedido);
    Optional<Pedido> buscarPorId(UUID id);
}
