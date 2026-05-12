package com.vinogradov.producerbd;

import org.postgresql.util.PGobject;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;

@Repository
public class ProducerRepository {

    private final JdbcTemplate jdbcTemplate;

    public ProducerRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public void createTaskWithinBusinessTransaction(String payload, int priority) {
        try {
            // Фиктивный UPDATE в существующей таблице предметной области (branch_office)
            // Сначала проверим, есть ли запись с id=1, если нет - вставим
            jdbcTemplate.update("INSERT INTO autoservice_schema.branch_office (id, address, phone_number) " +
                            "VALUES (1, 'Test Address', 'Test Phone') " +
                            "ON CONFLICT (id) DO UPDATE SET phone_number = EXCLUDED.phone_number");

            // Создаем PGobject для JSONB
            PGobject jsonObject = new PGobject();
            jsonObject.setType("jsonb");
            jsonObject.setValue(payload);

            // Вставка задачи в таблицу tasks
            jdbcTemplate.update(
                    "INSERT INTO autoservice_schema.tasks (payload, priority, status, scheduled_at) VALUES (?, ?, 'ready', NOW())",
                    jsonObject,
                    priority
            );
        } catch (SQLException e) {
            throw new RuntimeException("Ошибка при создании задачи", e);
        }
    }
}
