
package com.eucomida.pedido.application.ports.in;

import com.eucomida.pedido.domain.model.Pedido;
import java.util.UUID;

@FunctionalInterface
public interface CriarPedidoUseCase {
    Pedido criar(UUID clienteId);
}
