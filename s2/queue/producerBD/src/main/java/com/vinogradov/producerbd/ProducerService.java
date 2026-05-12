package com.vinogradov.producerbd;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.UUID;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class ProducerService {

    private static final Logger logger = LoggerFactory.getLogger(ProducerService.class);
    private final Random random = new Random();

    private final ProducerRepository producerRepository;
    private final int tasksPerSecond;

    public ProducerService(
            ProducerRepository producerRepository,
            @Value("${producer.tasks-per-second:200}") int tasksPerSecond
    ) {
        this.producerRepository = producerRepository;
        this.tasksPerSecond = tasksPerSecond;
    }

    public void startLoadTesting() {
        logger.info("Начинаю нагрузочное тестирование: {} задач в секунду", tasksPerSecond);

        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        long delayMs = 1000L / tasksPerSecond;

        scheduler.scheduleAtFixedRate(this::createTask, 0, delayMs, TimeUnit.MILLISECONDS);
    }

    public void runPriorityDemonstration() {
        logger.info("--- Начинаю демонстрацию приоритета ---");

        logger.info("--- Создаю 50 обычных задач (Priority=0) ---");
        for (int i = 0; i < 50; i++) {
            String payload = String.format("{\"taskId\": \"%s\", \"type\": \"normal\", \"num\": %d}", UUID.randomUUID(), i + 1);
            producerRepository.createTaskWithinBusinessTransaction(payload, 0);
        }
        logger.info("--- Обычные задачи созданы ---");

        try {
            logger.info("--- Жду 0.1 секунд ---");
            Thread.sleep(100);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Ожидание прервано", e);
            return;
        }

        logger.info("--- Создаю 5 критических задач (Priority=100) ---");
        for (int i = 0; i < 5; i++) {
            String payload = String.format("{\"taskId\": \"%s\", \"type\": \"critical\", \"num\": %d}", UUID.randomUUID(), i + 1);
            producerRepository.createTaskWithinBusinessTransaction(payload, 100);
        }
        logger.info("--- Созданы критические задачи ---");
    }

    private void createTask() {
        try {
            String payload = String.format("{\"taskId\": \"%s\", \"data\": \"test-data-%d\"}", UUID.randomUUID(), random.nextInt(1000000));
            int priority = random.nextDouble() < 0.8 ? 0 : 100;

            producerRepository.createTaskWithinBusinessTransaction(payload, priority);

            logger.debug("Создана задача с priority={}", priority);
        } catch (Exception e) {
            logger.error("Ошибка при создании задачи", e);
        }
    }
}
