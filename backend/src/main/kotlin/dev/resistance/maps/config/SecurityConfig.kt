package dev.resistance.maps.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.SessionManagementConfigurer
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain

@Configuration
@EnableMethodSecurity(prePostEnabled = true)
class SecurityConfig {
    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .cors { }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { auth ->
                auth
                    .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                    .requestMatchers("/actuator/health").permitAll()
                    // Public marker endpoints
                    .requestMatchers("/api/markers/public", "/api/markers/public/**").permitAll()
                    .requestMatchers("/api/markers/shared/**").permitAll()
                    .requestMatchers(HttpMethod.POST, "/api/markers/*/verify-password").permitAll()
                    // Public route endpoints
                    .requestMatchers("/api/routes/public", "/api/routes/public/**").permitAll()
                    .requestMatchers("/api/routes/shared/**").permitAll()
                    .requestMatchers(HttpMethod.POST, "/api/routes/*/verify-password").permitAll()
                    // Public list endpoints
                    .requestMatchers("/api/lists/public", "/api/lists/public/**").permitAll()
                    .requestMatchers("/api/lists/shared/**").permitAll()
                    .requestMatchers(HttpMethod.POST, "/api/lists/*/verify-password").permitAll()
                    // File download (inline content)
                    .requestMatchers(HttpMethod.GET, "/api/files/*").permitAll()
                    // Admin
                    .requestMatchers("/admin/**").hasRole("SUPERADMIN")
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { jwt ->
                    val conv = JwtAuthenticationConverter()
                    conv.setJwtGrantedAuthoritiesConverter(KeycloakJwtRoleConverter())
                    jwt.jwtAuthenticationConverter(conv)
                }
            }
            .csrf { it.disable() }
        return http.build()
    }
}
