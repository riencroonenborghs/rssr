import { useCallback, useEffect, useState } from "react"
import { apiRequest } from "./api"

// Loads a GET endpoint whenever the path changes, ignoring responses for previous paths.
export default function useApi(path) {
  const [state, setState] = useState({ data: null, error: null, loading: true })

  useEffect(() => {
    if (!path) return
    const controller = new AbortController()
    setState({ data: null, error: null, loading: true })

    apiRequest(path, { signal: controller.signal })
      .then((data) => setState({ data, error: null, loading: false }))
      .catch((error) => {
        if (error.name !== "AbortError") setState({ data: null, error, loading: false })
      })

    return () => controller.abort()
  }, [path])

  const setData = useCallback((update) => setState((current) => ({ ...current, data: update(current.data) })), [])
  return { ...state, setData }
}
