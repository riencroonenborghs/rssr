import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react"

// Display settings, kept in this browser's localStorage (so they also work signed out).
// app/views/layouts/application.html.erb reads the theme too, to apply it before the first paint.
export const ENTRY_LAYOUTS = ["regular", "compact"]
export const THEMES = ["system", "light", "dark"]
// The width of the list column (column 2) in pixels, from md up.
export const LIST_WIDTH = { min: 256, max: 640, default: 384 }
const DEFAULTS = { entryLayout: "regular", theme: "system", listWidth: LIST_WIDTH.default }
const STORAGE_KEY = "rssreader.settings"

function load() {
  try {
    const stored = JSON.parse(window.localStorage.getItem(STORAGE_KEY) ?? "{}")
    return {
      ...DEFAULTS,
      ...(ENTRY_LAYOUTS.includes(stored.entryLayout) && { entryLayout: stored.entryLayout }),
      ...(THEMES.includes(stored.theme) && { theme: stored.theme }),
      ...(Number.isFinite(stored.listWidth) && {
        listWidth: Math.min(LIST_WIDTH.max, Math.max(LIST_WIDTH.min, stored.listWidth))
      })
    }
  } catch {
    return DEFAULTS
  }
}

// Sets the "dark" class on <html>; with the system theme, follows the device's preference live.
function useTheme(theme) {
  useEffect(() => {
    const media = window.matchMedia("(prefers-color-scheme: dark)")
    const apply = () => {
      const dark = theme === "dark" || (theme === "system" && media.matches)
      document.documentElement.classList.toggle("dark", dark)
    }

    apply()
    if (theme !== "system") return
    media.addEventListener("change", apply)
    return () => media.removeEventListener("change", apply)
  }, [theme])
}

const SettingsContext = createContext({ settings: DEFAULTS, updateSettings: () => {} })

export function SettingsProvider({ children }) {
  const [settings, setSettings] = useState(load)
  useTheme(settings.theme)

  const updateSettings = useCallback((changes) => {
    setSettings((current) => {
      const next = { ...current, ...changes }
      try {
        window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next))
      } catch {
        // Storage can be unavailable (e.g. private browsing); the setting then lasts for this visit.
      }
      return next
    })
  }, [])

  const value = useMemo(() => ({ settings, updateSettings }), [settings, updateSettings])
  return <SettingsContext.Provider value={value}>{children}</SettingsContext.Provider>
}

export const useSettings = () => useContext(SettingsContext)
