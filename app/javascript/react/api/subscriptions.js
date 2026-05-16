import { api } from "./client"

export function fetchSubscriptions() { return api.get("/subscriptions") }
export function createSubscription(url, getTitle, tags) { return api.post("/subscriptions", { subscription: { url, get_title_from_url: getTitle ? "true" : "false", tags: tags } }) }
export function deleteSubscription(id) { return api.delete(`/subscriptions/${id}`) }
