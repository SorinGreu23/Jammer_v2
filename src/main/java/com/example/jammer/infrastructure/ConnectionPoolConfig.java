package com.example.jammer.infrastructure;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ConnectionPoolConfig {
    private static final String DATABASE_URL_KEY = "spring.datasource.url";
    private static final String USERNAME_KEY = "spring.datasource.username";
    private static final String PASSWORD_KEY = "spring.datasource.password";
    private static final String DRIVER_CLASS_KEY = "spring.datasource.driver-class-name";

    @Value("${" + DATABASE_URL_KEY + "}")
    private String databaseUrl;

    @Value("${" + USERNAME_KEY + "}")
    private String username;

    @Value("${" + PASSWORD_KEY + "}")
    private String password;

    @Value("${" + DRIVER_CLASS_KEY + "}")
    private String driverClassName;

    @Bean
    public HikariDataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(databaseUrl);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName(driverClassName);

        // config settings
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setIdleTimeout(300000);
        config.setMaxLifetime(600000);
        config.setConnectionTimeout(30000);

        return new HikariDataSource(config);
    }
}
