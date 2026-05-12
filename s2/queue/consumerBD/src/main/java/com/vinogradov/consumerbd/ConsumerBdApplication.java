package com.vinogradov.consumerbd;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ConsumerBdApplication implements CommandLineRunner {

    private final WorkerService workerService;

    public ConsumerBdApplication(WorkerService workerService) {
        this.workerService = workerService;
    }

    public static void main(String[] args) {
        SpringApplication.run(ConsumerBdApplication.class, args);
    }

    @Override
    public void run(String... args) {
        workerService.startWorker();
    }

}
