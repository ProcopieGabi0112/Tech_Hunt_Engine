package com.techhunter.tech_hunter_engine_api.config;


import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("TechHunter Engine API")
                        .version("1.0.0")
                        .description("Tech Hunter Engine - endpoints map")
                        .contact(new Contact()
                                .name("Procopie Gabriel")
                                .email("procopiegabi@gmail,com")
                                .url("https://github.com/ProcopieGabi0112")
                        )
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")
                        )
                );
    }
}