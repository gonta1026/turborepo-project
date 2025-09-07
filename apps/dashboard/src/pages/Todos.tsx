import {
  type ModelsTodoPriority,
  type RequestCreateTodoRequest,
  type RequestUpdateTodoRequest,
  type ResponseErrorResponse,
  useDeleteApiV1TodosId,
  useGetApiV1Todos,
  usePostApiV1Todos,
  usePutApiV1TodosId,
} from '@repo/api-client'
import { Header } from '@repo/ui'
import { useState } from 'react'

export const Todos = () => {
  const [newTodo, setNewTodo] = useState<RequestCreateTodoRequest>({
    title: '',
    description: '',
    priority: 'medium' as ModelsTodoPriority,
  })

  // React Query hooks
  const {
    data: todosResponse,
    isLoading,
    error: todosError,
    refetch,
  } = useGetApiV1Todos({
    query: {
      retry: 0, // リトライを無効化してエラーをすぐに表示
    },
  })
  const { error: createTodoError, mutate: createTodoMutation, isPending } = usePostApiV1Todos()
  const updateTodoMutation = usePutApiV1TodosId({
    mutation: {
      onSuccess: () => refetch(),
    },
  })
  const deleteTodoMutation = useDeleteApiV1TodosId({
    mutation: {
      onSuccess: () => refetch(),
    },
  })

  const todos = todosResponse?.data?.data || []

  const createTodo = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newTodo.title.trim()) return
    createTodoMutation({ data: newTodo })
  }

  // createTodoのエラーをログ出力
  const toggleTodo = (id: number, completed: boolean) => {
    const updateData: RequestUpdateTodoRequest = {
      completed: !completed,
    }
    updateTodoMutation.mutate({
      id,
      data: updateData,
    })
  }

  const deleteTodo = (id: number) => {
    if (!confirm('Are you sure you want to delete this todo?')) return

    deleteTodoMutation.mutate({ id })
  }

  const getPriorityColor = (priority: ModelsTodoPriority) => {
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
        {createTodoError && <ErrorResponse error={createTodoError} />}
        {todosError && <ErrorResponse error={todosError} />}

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
                onChange={(e) => setNewTodo({ ...newTodo, priority: e.target.value as ModelsTodoPriority })}
                style={{ width: '100%', padding: '8px', marginBottom: '10px' }}
              >
                <option value="low">Low Priority</option>
                <option value="medium">Medium Priority</option>
                <option value="high">High Priority</option>
              </select>
            </div>
            <button
              type="submit"
              disabled={isPending}
              style={{
                backgroundColor: isPending ? '#95a5a6' : '#2ed573',
                color: 'white',
                padding: '10px 20px',
                border: 'none',
                borderRadius: '4px',
                cursor: isPending ? 'not-allowed' : 'pointer',
              }}
            >
              {isPending ? 'Creating...' : 'Create TODO'}
            </button>
          </form>
        </div>

        <div className="todos-container">
          <h2>TODO List</h2>
          {isLoading ? (
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
                          Created:{' '}
                          {todo.created_at ? new Date(String(todo.created_at)).toLocaleDateString() : 'Unknown'}
                        </span>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: '5px', marginLeft: '10px' }}>
                      <button
                        type="button"
                        onClick={() => toggleTodo(todo.id || 0, todo.completed || false)}
                        disabled={updateTodoMutation.isPending}
                        style={{
                          backgroundColor: updateTodoMutation.isPending
                            ? '#95a5a6'
                            : todo.completed
                              ? '#ffa502'
                              : '#2ed573',
                          color: 'white',
                          border: 'none',
                          padding: '5px 10px',
                          borderRadius: '3px',
                          cursor: updateTodoMutation.isPending ? 'not-allowed' : 'pointer',
                          fontSize: '12px',
                        }}
                      >
                        {updateTodoMutation.isPending ? '...' : todo.completed ? 'Undo' : 'Complete'}
                      </button>
                      <button
                        type="button"
                        onClick={() => deleteTodo(todo.id || 0)}
                        disabled={deleteTodoMutation.isPending}
                        style={{
                          backgroundColor: deleteTodoMutation.isPending ? '#95a5a6' : '#ff4757',
                          color: 'white',
                          border: 'none',
                          padding: '5px 10px',
                          borderRadius: '3px',
                          cursor: deleteTodoMutation.isPending ? 'not-allowed' : 'pointer',
                          fontSize: '12px',
                        }}
                      >
                        {deleteTodoMutation.isPending ? '...' : 'Delete'}
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

const ErrorResponse = ({ error }: { error: ResponseErrorResponse }) => {
  return (
    <div
      style={{
        backgroundColor: '#ff4757',
        color: 'white',
        padding: '10px',
        borderRadius: '4px',
      }}
    >
      {error.message}
      {/* バリデーションエラー詳細表示 */}
      {error.details.length > 0 && (
        <div style={{ marginTop: '10px' }}>
          <strong>入力エラー:</strong>
          <ul style={{ textAlign: 'left', margin: '5px 0', paddingLeft: '20px' }}>
            {error.details.map((validationError, index: number) => (
              <li key={`${validationError.field}-${index}`}>{validationError.message}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
