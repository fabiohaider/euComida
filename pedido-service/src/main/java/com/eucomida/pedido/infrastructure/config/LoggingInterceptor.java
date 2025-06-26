
package com.eucomida.pedido.infrastructure.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Optional;
import java.util.UUID;

@Component
@SuppressWarnings("unused")
public class LoggingInterceptor implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        String traceId = Optional.ofNullable(((HttpServletRequest) request).getHeader("X-Trace-Id"))
                                 .orElse(UUID.randomUUID().toString());

        MDC.put("traceId", traceId);

        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            MDC.put("user", auth.getName());
        }

        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
