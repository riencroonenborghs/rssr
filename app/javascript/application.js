// Entry point for the build script in your package.json
import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { BrowserRouter } from "react-router"
import App from "./components/App"
import { SettingsProvider } from "./lib/settings"

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("root")
  if (!container) return

  const session = {
    signedIn: container.dataset.signedIn === "true",
    signInPath: container.dataset.signInPath,
    signOutPath: container.dataset.signOutPath,
    jobsPath: container.dataset.jobsPath
  }

  createRoot(container).render(
    <StrictMode>
      <BrowserRouter>
        <SettingsProvider>
          <App session={session} />
        </SettingsProvider>
      </BrowserRouter>
    </StrictMode>
  )
})
