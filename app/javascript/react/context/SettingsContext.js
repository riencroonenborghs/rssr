import React, { createContext, useContext, useState, useEffect } from "react"

const SettingsContext = createContext(null)

export function SettingsProvider({ children }) {
  const [theme, setTheme] = useState(() => localStorage.getItem("rssr:theme") || "auto")
  const [density, setDensity] = useState(() => localStorage.getItem("rssr:density") || "comfortable")

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem("rssr:theme", theme)
  }, [theme])

  useEffect(() => {
    localStorage.setItem("rssr:density", density)
  }, [density])

  return (
    <SettingsContext.Provider value={{ theme, setTheme, density, setDensity }}>
      {children}
    </SettingsContext.Provider>
  )
}

export function useSettings() {
  return useContext(SettingsContext)
}
