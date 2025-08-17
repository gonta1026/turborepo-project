import { Header } from '@repo/ui'
import { useCallback, useEffect, useState } from 'react'

interface Todo {
  id: number
  title: string
  description: string
  completed: boolean
  priority: string
  created_at: string
  updated_at: string
}

interface CreateTodoRequest {
  title: string
  description: string
  priority: string
}

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1'

export const Todos = () => {
  const [todos, setTodos] = useState<Todo[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [newTodo, setNewTodo] = useState<CreateTodoRequest>({
    title: '',
    description: '',
    priority: 'medium',
  })

  const fetchTodos = useCallback(async () => {
    try {
      setLoading(true)
      const response = await fetch(`${API_BASE_URL}/todos`)
      if (!response.ok) {
        throw new Error('Failed to fetch todos')
      }
      const data = await response.json()
      setTodos(data.data || [])
      setError(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }, [])

  const createTodo = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newTodo.title.trim()) {
      setError('Title is required')
      return
    }

    try {
      const response = await fetch(`${API_BASE_URL}/todos`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newTodo),
      })

      if (!response.ok) {
        throw new Error('Failed to create todo')
      }

      setNewTodo({ title: '', description: '', priority: 'medium' })
      fetchTodos()
      setError(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  const toggleTodo = async (id: number, completed: boolean) => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ completed: !completed }),
      })

      if (!response.ok) {
        throw new Error('Failed to update todo')
      }

      fetchTodos()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  const deleteTodo = async (id: number) => {
    if (!confirm('Are you sure you want to delete this todo?')) {
      return
    }

    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: 'DELETE',
      })

      if (!response.ok) {
        throw new Error('Failed to delete todo')
      }

      fetchTodos()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  useEffect(() => {
    fetchTodos()
  }, [fetchTodos])

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return '#ff4757'
      case 'medium':
        return '#ffa502'
      case 'low':
        return '#2ed573'
      default:
        return '#747d8c'
    }
  }

  return (
    <div className="page">
      <Header title="TODO Manager" />

      <div className="content">
        {error && (
          <div
            style={{
              backgroundColor: '#ff4757',
              color: 'white',
              padding: '10px',
              borderRadius: '4px',
              marginBottom: '20px',
            }}
          >
            {error}
          </div>
        )}

        <div className="todo-form-container">
          <h2>Create New TODO</h2>
          <form onSubmit={createTodo} className="todo-form">
            <div>
              <input
                type="text"
                placeholder="TODO Title *"
                value={newTodo.title}
                onChange={(e) => setNewTodo({ ...newTodo, title: e.target.value })}
                style={{ width: '100%', padding: '8px', marginBottom: '10px' }}
              />
            </div>
            <div>
              <textarea
                placeholder="Description"
                value={newTodo.description}
                onChange={(e) => setNewTodo({ ...newTodo, description: e.target.value })}
                style={{ width: '100%', padding: '8px', marginBottom: '10px', minHeight: '60px' }}
              />
            </div>
            <div>
              <select
                value={newTodo.priority}
                onChange={(e) => setNewTodo({ ...newTodo, priority: e.target.value })}
                style={{ width: '100%', padding: '8px', marginBottom: '10px' }}
              >
                <option value="low">Low Priority</option>
                <option value="medium">Medium Priority</option>
                <option value="high">High Priority</option>
              </select>
            </div>
            <button
              type="submit"
              style={{
                backgroundColor: '#2ed573',
                color: 'white',
                padding: '10px 20px',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              Create TODO
            </button>
          </form>
        </div>

        <div className="todos-container">
          <h2>TODO List</h2>
          {loading ? (
            <p>Loading todos...</p>
          ) : todos.length === 0 ? (
            <p>No todos found. Create your first todo above!</p>
          ) : (
            <div className="todos-list">
              {todos.map((todo) => (
                <div
                  key={todo.id}
                  className="todo-item"
                  style={{
                    border: '1px solid #ddd',
                    padding: '15px',
                    marginBottom: '10px',
                    borderRadius: '4px',
                    backgroundColor: todo.completed ? '#f8f9fa' : 'white',
                    textDecoration: todo.completed ? 'line-through' : 'none',
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <div style={{ flex: 1 }}>
                      <h3 style={{ margin: '0 0 5px 0' }}>{todo.title}</h3>
                      {todo.description && <p style={{ margin: '0 0 10px 0', color: '#666' }}>{todo.description}</p>}
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <span
                          style={{
                            backgroundColor: getPriorityColor(todo.priority),
                            color: 'white',
                            padding: '2px 8px',
                            borderRadius: '3px',
                            fontSize: '12px',
                          }}
                        >
                          {todo.priority}
                        </span>
                        <span style={{ fontSize: '12px', color: '#999' }}>
                          Created: {new Date(todo.created_at).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: '5px', marginLeft: '10px' }}>
                      <button
                        type="button"
                        onClick={() => toggleTodo(todo.id, todo.completed)}
                        style={{
                          backgroundColor: todo.completed ? '#ffa502' : '#2ed573',
                          color: 'white',
                          border: 'none',
                          padding: '5px 10px',
                          borderRadius: '3px',
                          cursor: 'pointer',
                          fontSize: '12px',
                        }}
                      >
                        {todo.completed ? 'Undo' : 'Complete'}
                      </button>
                      <button
                        type="button"
                        onClick={() => deleteTodo(todo.id)}
                        style={{
                          backgroundColor: '#ff4757',
                          color: 'white',
                          border: 'none',
                          padding: '5px 10px',
                          borderRadius: '3px',
                          cursor: 'pointer',
                          fontSize: '12px',
                        }}
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
