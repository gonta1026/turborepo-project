DROP INDEX IF EXISTS idx_todos_priority;
ALTER TABLE todos DROP COLUMN IF EXISTS priority;