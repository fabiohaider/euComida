package com.eucomida.pedido.infrastructure.controller;

import com.eucomida.pedido.application.ports.in.ConsultarStatusPedidoUseCase;
import com.eucomida.pedido.application.ports.in.CriarPedidoUseCase;
import com.eucomida.pedido.domain.enums.Status;
import com.eucomida.pedido.domain.model.Pedido;
import com.eucomida.pedido.infrastructure.controller.dto.PedidoRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/pedidos")
@SuppressWarnings("unused")
public class PedidoController {

    private final CriarPedidoUseCase criarPedido;
    private final ConsultarStatusPedidoUseCase consultarStatus;

    public PedidoController(CriarPedidoUseCase criarPedido, ConsultarStatusPedidoUseCase consultarStatus) {
        this.criarPedido = criarPedido;
        this.consultarStatus = consultarStatus;
    }

    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping
    public Pedido criarPedido(@Valid @RequestBody PedidoRequest request) throws RuntimeException {
        return criarPedido.criar(request.clienteId());
    }

    @ResponseStatus(HttpStatus.OK)
    @GetMapping("/{id}/status")
    public Status statusPedido(@PathVariable UUID id) {
        return consultarStatus.consultar(id);
    }

}