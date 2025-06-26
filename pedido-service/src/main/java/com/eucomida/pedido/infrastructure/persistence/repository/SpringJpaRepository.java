
package com.eucomida.pedido.infrastructure.persistence.repository;

import com.eucomida.pedido.infrastructure.persistence.entity.PedidoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SpringJpaRepository extends JpaRepository<PedidoEntity, UUID> {
}
