package com.vinogradov.consumerbd;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Optional;

@Repository
public class ConsumerRepository {

    private final JdbcTemplate jdbcTemplate;

    public ConsumerRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public Optional<Task> pollTask(String workerId) {
        String selectSql = """
                SELECT id, payload, attempts, priority, created_at FROM autoservice_schema.tasks
                WHERE status = 'ready' AND scheduled_at <= now()
                ORDER BY priority DESC, created_at ASC
                FOR UPDATE SKIP LOCKED LIMIT 1
                """;

        Optional<Task> task = jdbcTemplate.query(selectSql, new TaskRowMapper()).stream().findFirst();

        if (task.isPresent()) {
            String updateSql = """
                    UPDATE autoservice_schema.tasks
                    SET status = 'running', worker_id = ?
                    WHERE id = ?
                    """;
            jdbcTemplate.update(updateSql, workerId, task.get().getId());
        }

        return task;
    }

    @Transactional
    public void markCompleted(long taskId) {
        String sql = "UPDATE autoservice_schema.tasks SET status = 'completed' WHERE id = ?";
        jdbcTemplate.update(sql, taskId);
    }

    @Transactional
    public void markFailed(long taskId, int newAttempts, Timestamp newScheduledAt, boolean deadLetter) {
        String sql;
        if (deadLetter) {
            sql = "UPDATE autoservice_schema.tasks SET status = 'dead_letter', attempts = ? WHERE id = ?";
            jdbcTemplate.update(sql, newAttempts, taskId);
        } else {
            sql = "UPDATE autoservice_schema.tasks SET status = 'ready', attempts = ?, scheduled_at = ? WHERE id = ?";
            jdbcTemplate.update(sql, newAttempts, newScheduledAt, taskId);
        }
    }

    private static class TaskRowMapper implements RowMapper<Task> {
        @Override
        public Task mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new Task(
                    rs.getLong("id"),
                    rs.getString("payload"),
                    rs.getInt("attempts"),
                    rs.getInt("priority"),
                    rs.getTimestamp("created_at")
            );
        }
    }
}
