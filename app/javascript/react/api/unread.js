import { api } from "./client"

export function fetchUnread(page = 1) {
  return api.get(`/unread?page=${page}`)
}
