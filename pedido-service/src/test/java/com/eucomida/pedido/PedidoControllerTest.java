package com.eucomida.pedido;

import com.eucomida.pedido.application.ports.in.ConsultarStatusPedidoUseCase;
import com.eucomida.pedido.application.ports.in.CriarPedidoUseCase;
import com.eucomida.pedido.domain.enums.Status;
import com.eucomida.pedido.domain.model.Pedido;
import com.eucomida.pedido.infrastructure.config.SecurityConfig;
import com.eucomida.pedido.infrastructure.controller.PedidoController;
import com.eucomida.pedido.infrastructure.controller.dto.PedidoRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.ZonedDateTime;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(PedidoController.class)
@Import({SecurityConfig.class, PedidoControllerTest.TestConfig.class})
public class PedidoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private CriarPedidoUseCase criarPedidoUseCase;

    @Autowired
    private ConsultarStatusPedidoUseCase consultarStatusPedidoUseCase;

    @Test
    @WithMockUser(username = "user", authorities = {"ROLE_user"})
    public void userPodeCriarPedido() throws Exception {
        UUID clienteId = UUID.randomUUID();
        UUID novoPedidoId = UUID.randomUUID();

        Pedido pedidoMock = new Pedido(novoPedidoId, clienteId, Status.EM_ANDAMENTO, ZonedDateTime.now().toInstant());

        Mockito.when(criarPedidoUseCase.criar(clienteId)).thenReturn(pedidoMock);

        PedidoRequest requestBody = new PedidoRequest(clienteId);

        mockMvc.perform(post("/pedidos")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(requestBody)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(pedidoMock.id().toString()))
                .andExpect(jsonPath("$.clienteId").value(clienteId.toString()));
    }

    @TestConfiguration
    static class TestConfig {

        @Bean
        public CriarPedidoUseCase criarPedidoUseCase() {
            return Mockito.mock(CriarPedidoUseCase.class);
        }

        @Bean
        public ConsultarStatusPedidoUseCase consultarStatusPedidoUseCase() {
            return Mockito.mock(ConsultarStatusPedidoUseCase.class);
        }

        @Bean
        public JwtDecoder jwtDecoder() {
            return Mockito.mock(JwtDecoder.class);
        }
    }
}