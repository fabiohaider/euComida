package com.eucomida.pedido.infrastructure.config;

import io.micrometer.core.instrument.binder.system.ProcessorMetrics;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@SuppressWarnings("unused")
public class MicrometerConfig {

    @Bean
    public ProcessorMetrics processorMetrics() {
        return new ProcessorMetrics();
    }

}
