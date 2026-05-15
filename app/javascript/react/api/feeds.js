import { api } from "./client"

export function fetchFeeds() {
  return api.get("/feeds")
}
