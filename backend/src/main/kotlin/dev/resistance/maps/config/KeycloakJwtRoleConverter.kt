package dev.resistance.maps.config

import org.springframework.core.convert.converter.Converter
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt

class KeycloakJwtRoleConverter : Converter<Jwt, Collection<GrantedAuthority>> {
    override fun convert(jwt: Jwt): Collection<GrantedAuthority> {
        val realmAccess = jwt.claims["realm_access"] as? Map<*, *> ?: return emptyList()
        val roles = realmAccess["roles"] as? Collection<*> ?: emptyList<Any>()
        return roles.mapNotNull { r ->
            val role = r?.toString()?.uppercase() ?: return@mapNotNull null
            SimpleGrantedAuthority("ROLE_${role}")
        }
    }
}
