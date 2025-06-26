
package com.eucomida.pedido.application.ports.in;

import com.eucomida.pedido.domain.enums.Status;
import java.util.UUID;

@FunctionalInterface
public interface ConsultarStatusPedidoUseCase {
    Status consultar(UUID pedidoId);
}
