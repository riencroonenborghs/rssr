import { api } from "./client"

export function fetchTag(id, page = 1) {
  return api.get(`/tags/${id}?page=${page}`)
}
