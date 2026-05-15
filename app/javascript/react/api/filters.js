import { api } from "./client"

export function fetchFilters() { return api.get("/filters") }
export function createFilter(comparison, value) { return api.post("/filters", { filter: { comparison, value } }) }
export function deleteFilter(id) { return api.delete(`/filters/${id}`) }
