// JSON requests to the Rails API, sending the CSRF token for writes.
export class ApiError extends Error {
  constructor(status, message) {
    super(message)
    this.status = status
  }
}

export async function apiRequest(path, { method = "GET", body, signal } = {}) {
  const response = await fetch(path, {
    method,
    signal,
    headers: {
      "Accept": "application/json",
      ...(body && { "Content-Type": "application/json" }),
      ...(method !== "GET" && { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content })
    },
    body: body && JSON.stringify(body)
  })

  if (!response.ok) {
    const data = await response.json().catch(() => ({}))
    throw new ApiError(response.status, data.error || `Request failed (${response.status})`)
  }
  return response.status === 204 ? null : response.json()
}
