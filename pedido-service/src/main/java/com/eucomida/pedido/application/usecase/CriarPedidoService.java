
package com.eucomida.pedido.application.usecase;

import com.eucomida.pedido.application.ports.in.CriarPedidoUseCase;
import com.eucomida.pedido.application.ports.out.PedidoRepositoryPort;
import com.eucomida.pedido.domain.model.Pedido;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@SuppressWarnings("unused")
public class CriarPedidoService implements CriarPedidoUseCase {

    private final PedidoRepositoryPort repository;

    public CriarPedidoService(PedidoRepositoryPort repository) {
        this.repository = repository;
    }

    @Override
    @Transactional
    public Pedido criar(UUID clienteId) {
        return repository.salvar(Pedido.criarNovo(clienteId));
    }
}
