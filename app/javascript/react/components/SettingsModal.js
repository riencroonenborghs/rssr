import React, { useEffect } from "react"
import { useSettings } from "../context/SettingsContext"

const THEMES = [
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
  { value: "auto", label: "Auto" },
]

const DENSITIES = [
  { value: "comfortable", label: "Comfortable" },
  { value: "compact", label: "Compact" },
]

function OptionGroup({ label, options, value, onChange }) {
  return (
    <div className="mb-5">
      <p className="section-label mb-2">{label}</p>
      <div className="flex gap-2">
        {options.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => onChange(opt.value)}
            className="flex-1 py-2 px-3 rounded text-[0.8rem] border cursor-pointer transition-colors duration-150"
            style={{
              background: value === opt.value ? "var(--accent)" : "var(--hover-bg)",
              color: value === opt.value ? "#0f1117" : "var(--text-primary)",
              borderColor: value === opt.value ? "var(--accent)" : "var(--border)",
              fontWeight: value === opt.value ? 600 : 400,
            }}
          >
            {opt.label}
          </button>
        ))}
      </div>
    </div>
  )
}

export default function SettingsModal({ onClose, userEmail }) {
  const { theme, setTheme, density, setDensity } = useSettings()

  useEffect(() => {
    function onKey(e) { if (e.key === "Escape") onClose() }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [onClose])

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-start"
      onClick={onClose}
    >
      <div
        className="mb-4 ml-4 w-[220px] rounded-lg p-4 shadow-xl"
        style={{ background: "var(--sidebar-surface)", border: "1px solid var(--border)" }}
        onClick={(e) => e.stopPropagation()}
      >
        {userEmail && (
          <div className="mb-4 pb-3 border-b" style={{ borderColor: "var(--border)" }}>
            <p className="section-label mb-1">Signed in as</p>
            <p className="text-[0.78rem] truncate" style={{ color: "var(--text-primary)" }}>
              {userEmail}
            </p>
          </div>
        )}

        <OptionGroup label="Theme" options={THEMES} value={theme} onChange={setTheme} />
        <OptionGroup label="Density" options={DENSITIES} value={density} onChange={setDensity} />
      </div>
    </div>
  )
}
