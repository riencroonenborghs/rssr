import React from "react"
import { createRoot } from "react-dom/client"
import App from "./react/App"
import { SettingsProvider } from "./react/context/SettingsContext"

const root = document.getElementById("react-root")
if (root) {
  createRoot(root).render(
    <SettingsProvider>
      <App />
    </SettingsProvider>
  )
}
