CREATE TABLE IF NOT EXISTS autoservice_schema.tasks (
    id BIGSERIAL PRIMARY KEY,
    payload JSONB,
    status VARCHAR NOT NULL DEFAULT 'ready' CHECK (status IN ('ready', 'running', 'completed', 'failed', 'dead_letter')),
    priority INT NOT NULL DEFAULT 0,
    attempts INT NOT NULL DEFAULT 0,
    scheduled_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    worker_id VARCHAR
);

-- Триггер для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION autoservice_schema.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON autoservice_schema.tasks
FOR EACH ROW EXECUTE FUNCTION autoservice_schema.update_updated_at_column();


CREATE INDEX idx_tasks_ready_priority_scheduled
ON autoservice_schema.tasks (priority DESC, scheduled_at)
WHERE status = 'ready';