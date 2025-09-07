/** biome-ignore-all lint/suspicious/noExplicitAny: biome */
import type { ResponseErrorResponse } from './types'

declare global {
  interface ImportMeta {
    env: {
      VITE_API_BASE_URL: string
    }
  }
}

export interface CustomRequestInit extends RequestInit {
  params?: Record<string, any>
}

export interface CustomResponse<T = any> {
  data: T
  status: number
  statusText: string
}

export interface RequestConfig {
  url: string
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
  headers?: HeadersInit
  data?: any
  params?: Record<string, any>
  signal?: AbortSignal
}

export const customInstance = async <T = any>(
  config: RequestConfig,
  options?: CustomRequestInit,
): Promise<CustomResponse<T>> => {
  const { url, method, headers: configHeaders, data, params, signal } = config
  const { ...requestOptions } = options || {}
  const API_BASE_URL = import.meta.env.VITE_API_BASE_URL
  let fullUrl = `${API_BASE_URL}${url}`
  // Handle query parameters
  if (params) {
    const searchParams = new URLSearchParams()
    Object.keys(params).forEach((key) => {
      if (params[key] !== undefined && params[key] !== null) {
        searchParams.append(key, params[key])
      }
    })

    if (searchParams.toString()) {
      fullUrl += `?${searchParams.toString()}`
    }
  }

  // Set default headers
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...configHeaders,
    ...requestOptions.headers,
  }

  const response = await fetch(fullUrl, {
    method,
    headers,
    body: data ? JSON.stringify(data) : undefined,
    signal,
    ...requestOptions,
  })

  let responseData: T
  try {
    responseData = await response.json()
  } catch {
    responseData = null as T
  }

  // HTTPエラーの場合はエラーとして扱う
  if (!response.ok) {
    console.log({ responseData })
    // バックエンドのエラーレスポンス構造に対応
    const backendError = responseData as { message?: string; error_code?: string; details?: any[] }
    const reactQueryError: ResponseErrorResponse = {
      message: backendError.message || 'エラーが発生しました',
      details: backendError.details || [],
      status: response.status,
    }

    throw reactQueryError
  }

  return {
    data: responseData,
    status: response.status,
    statusText: response.statusText,
  }
}
