package com.vinogradov.producerbd;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ProducerBdApplication implements CommandLineRunner {

    private final ProducerService producerService;

    public ProducerBdApplication(ProducerService producerService) {
        this.producerService = producerService;
    }

    public static void main(String[] args) {
        SpringApplication.run(ProducerBdApplication.class, args);
    }

    @Override
    public void run(String... args) {
        producerService.startLoadTesting();
    }

}
