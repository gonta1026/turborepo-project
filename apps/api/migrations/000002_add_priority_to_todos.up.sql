ALTER TABLE todos 
ADD COLUMN priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high'));

CREATE INDEX idx_todos_priority ON todos(priority);