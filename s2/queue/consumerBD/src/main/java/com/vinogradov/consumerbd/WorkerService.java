package com.vinogradov.consumerbd;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Optional;
import java.util.Random;

@Service
public class WorkerService {

    private static final Logger logger = LoggerFactory.getLogger(WorkerService.class);
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");
    private final Random random = new Random();

    private final ConsumerRepository consumerRepository;
    private final String workerId;

    public WorkerService(
            ConsumerRepository consumerRepository,
            @Value("${consumer.worker-id:worker-1}") String workerId
    ) {
        this.consumerRepository = consumerRepository;
        this.workerId = workerId;
    }

    public void startWorker() {
        logger.info("Воркер {} запущен", workerId);

        while (!Thread.currentThread().isInterrupted()) {
            try {
                Optional<Task> taskOpt = consumerRepository.pollTask(workerId);

                if (taskOpt.isPresent()) {
                    Task task = taskOpt.get();
                    String createdAtStr = task.getCreatedAt().toLocalDateTime().format(TIME_FORMATTER);
                    logger.info("[{}] Взял задачу ID={}, Priority={}, CreatedAt={}", workerId, task.getId(), task.getPriority(), createdAtStr);

                    Thread.sleep(50);

                    if (random.nextDouble() < 0.9) {
                        consumerRepository.markCompleted(task.getId());
                        logger.info("[{}] Завершил задачу ID={}", workerId, task.getId());
                    } else {
                        int newAttempts = task.getAttempts() + 1;
                        boolean deadLetter = newAttempts > 3;

                        if (deadLetter) {
                            consumerRepository.markFailed(task.getId(), newAttempts, null, true);
                            logger.warn("[{}] Перевел задачу ID={} в dead_letter (превышено количество попыток)", workerId, task.getId());
                        } else {
                            Timestamp newScheduledAt = Timestamp.valueOf(LocalDateTime.now().plusMinutes(newAttempts * 5L));
                            consumerRepository.markFailed(task.getId(), newAttempts, newScheduledAt, false);
                            logger.info("[{}] Перенес задачу ID={} на повторное выполнение (попытка {})", workerId, task.getId(), newAttempts);
                        }
                    }
                } else {
                    Thread.sleep(1000);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.info("Воркер {} остановлен", workerId);
            } catch (Exception e) {
                logger.error("Ошибка в воркере {}", workerId, e);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }
}
