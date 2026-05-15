const JSON_HEADERS = { "Accept": "application/json", "Content-Type": "application/json" }

async function request(path, options = {}) {
  const res = await fetch(`/api/v1${path}`, { ...options, headers: { ...JSON_HEADERS, ...options.headers } })
  if (!res.ok) throw new Error(`API error ${res.status}: ${path}`)
  return res.json()
}

export const api = {
  get: (path) => request(path),
  post: (path, body) => request(path, { method: "POST", body: JSON.stringify(body) }),
  patch: (path, body) => request(path, { method: "PATCH", body: JSON.stringify(body) }),
  delete: (path) => request(path, { method: "DELETE" }),
}
