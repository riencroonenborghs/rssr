import React, { useEffect, useState, useCallback } from "react"
import { useSettings } from "../context/SettingsContext"
import { useIsMobile } from "../hooks/useIsMobile"
import { fetchSubscriptions, createSubscription, deleteSubscription } from "../api/subscriptions"
import { fetchFilters, createFilter, deleteFilter } from "../api/filters"

const THEMES = [
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
  { value: "auto", label: "Auto" },
]

const DENSITIES = [
  { value: "comfortable", label: "Comfortable" },
  { value: "compact", label: "Compact" },
]

const COMPARISONS = [
  { value: "includes", label: "contains" },
  { value: "tagged", label: "tagged with" },
]

const TABS = ["Appearance", "Subscriptions", "Filters"]

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
              color: value === opt.value ? "#fff" : "var(--text-primary)",
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

function AppearanceTab({ theme, setTheme, density, setDensity }) {
  return (
    <>
      <OptionGroup label="Theme" options={THEMES} value={theme} onChange={setTheme} />
      <OptionGroup label="Density" options={DENSITIES} value={density} onChange={setDensity} />
    </>
  )
}

function SubscriptionsTab() {
  const [subs, setSubs] = useState(null)
  const [url, setUrl] = useState("")
  const [autoTitle, setAutoTitle] = useState(true)
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState(null)

  const load = useCallback(() => {
    fetchSubscriptions().then((d) => setSubs(d.subscriptions || []))
  }, [])

  useEffect(() => { load() }, [load])

  function handleAdd(e) {
    e.preventDefault()
    if (!url.trim()) return
    setAdding(true)
    setError(null)
    createSubscription(url.trim(), autoTitle)
      .then(() => { setUrl(""); load() })
      .catch((err) => setError(err.message || "Failed to subscribe"))
      .finally(() => setAdding(false))
  }

  function handleDelete(id) {
    deleteSubscription(id).then(load)
  }

  return (
    <div>
      <form onSubmit={handleAdd} className="mb-4">
        <p className="section-label mb-2">Add feed</p>
        <input
          type="url"
          placeholder="https://example.com/feed.xml"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          className="w-full px-3 py-2 rounded text-[0.82rem] border mb-2 outline-none"
          style={{ background: "var(--hover-bg)", color: "var(--text-primary)", borderColor: "var(--border)" }}
        />
        <div className="flex items-center gap-2 mb-2">
          <input
            type="checkbox"
            id="auto-title"
            checked={autoTitle}
            onChange={(e) => setAutoTitle(e.target.checked)}
            className="cursor-pointer"
          />
          <label htmlFor="auto-title" className="text-[0.78rem] cursor-pointer" style={{ color: "var(--text-muted)" }}>
            Fetch title from URL
          </label>
        </div>
        {error && <p className="text-[0.75rem] mb-2" style={{ color: "#e05" }}>{error}</p>}
        <button
          type="submit"
          disabled={adding || !url.trim()}
          className="w-full py-2 px-3 rounded text-[0.8rem] border cursor-pointer transition-colors duration-150"
          style={{ background: "var(--accent)", color: "#fff", borderColor: "var(--accent)", opacity: adding ? 0.6 : 1 }}
        >
          {adding ? "Subscribing…" : "Subscribe"}
        </button>
      </form>

      <p className="section-label mb-2">Your feeds</p>
      {subs === null && <p className="text-[0.78rem]" style={{ color: "var(--text-muted)" }}>Loading…</p>}
      {subs?.length === 0 && <p className="text-[0.78rem]" style={{ color: "var(--text-muted)" }}>No subscriptions</p>}
      <div className="flex flex-col gap-1">
        {subs?.map((sub) => (
          <div key={sub.id} className="flex items-center justify-between gap-2 px-2 py-1 rounded"
            style={{ background: "var(--hover-bg)" }}>
            <span className="text-[0.78rem] truncate flex-1" style={{ color: "var(--text-primary)" }}>{sub.feed.title}</span>
            <button
              type="button"
              onClick={() => handleDelete(sub.id)}
              className="text-[0.7rem] border-none bg-transparent cursor-pointer shrink-0"
              style={{ color: "var(--text-muted)" }}
            >
              Remove
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}

function FiltersTab() {
  const [filters, setFilters] = useState(null)
  const [comparison, setComparison] = useState("includes")
  const [value, setValue] = useState("")
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState(null)

  const load = useCallback(() => {
    fetchFilters().then((d) => setFilters(d.filters || []))
  }, [])

  useEffect(() => { load() }, [load])

  function handleAdd(e) {
    e.preventDefault()
    if (!value.trim()) return
    setAdding(true)
    setError(null)
    createFilter(comparison, value.trim())
      .then(() => { setValue(""); load() })
      .catch((err) => setError(err.message || "Failed to add filter"))
      .finally(() => setAdding(false))
  }

  function handleDelete(id) {
    deleteFilter(id).then(load)
  }

  return (
    <div>
      <form onSubmit={handleAdd} className="mb-4">
        <p className="section-label mb-2">Add filter</p>
        <div className="flex gap-2 mb-2">
          {COMPARISONS.map((c) => (
            <button
              key={c.value}
              type="button"
              onClick={() => setComparison(c.value)}
              className="flex-1 py-1 px-2 rounded text-[0.75rem] border cursor-pointer transition-colors duration-150"
              style={{
                background: comparison === c.value ? "var(--accent)" : "var(--hover-bg)",
                color: comparison === c.value ? "#fff" : "var(--text-primary)",
                borderColor: comparison === c.value ? "var(--accent)" : "var(--border)",
              }}
            >
              {c.label}
            </button>
          ))}
        </div>
        <input
          type="text"
          placeholder="keyword or tag name"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className="w-full px-3 py-2 rounded text-[0.82rem] border mb-2 outline-none"
          style={{ background: "var(--hover-bg)", color: "var(--text-primary)", borderColor: "var(--border)" }}
        />
        {error && <p className="text-[0.75rem] mb-2" style={{ color: "#e05" }}>{error}</p>}
        <button
          type="submit"
          disabled={adding || !value.trim()}
          className="w-full py-2 px-3 rounded text-[0.8rem] border cursor-pointer transition-colors duration-150"
          style={{ background: "var(--accent)", color: "#fff", borderColor: "var(--accent)", opacity: adding ? 0.6 : 1 }}
        >
          {adding ? "Adding…" : "Add filter"}
        </button>
      </form>

      <p className="section-label mb-2">Active filters</p>
      {filters === null && <p className="text-[0.78rem]" style={{ color: "var(--text-muted)" }}>Loading…</p>}
      {filters?.length === 0 && <p className="text-[0.78rem]" style={{ color: "var(--text-muted)" }}>No filters</p>}
      <div className="flex flex-col gap-1">
        {filters?.map((f) => (
          <div key={f.id} className="flex items-center justify-between gap-2 px-2 py-1 rounded"
            style={{ background: "var(--hover-bg)" }}>
            <span className="text-[0.78rem] truncate flex-1" style={{ color: "var(--text-primary)" }}>
              <span style={{ color: "var(--text-muted)" }}>{COMPARISONS.find((c) => c.value === f.comparison)?.label} </span>
              {f.value}
            </span>
            <button
              type="button"
              onClick={() => handleDelete(f.id)}
              className="text-[0.7rem] border-none bg-transparent cursor-pointer shrink-0"
              style={{ color: "var(--text-muted)" }}
            >
              Remove
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}

function ModalContent({ userEmail, onClose }) {
  const { theme, setTheme, density, setDensity } = useSettings()
  const [tab, setTab] = useState("Appearance")

  return (
    <>
      <div className="flex items-center justify-between px-5 py-4 border-b shrink-0" style={{ borderColor: "var(--border)" }}>
        <span className="text-[0.95rem] font-semibold" style={{ color: "var(--text-primary)" }}>Settings</span>
        <button
          type="button"
          onClick={onClose}
          className="text-[1.1rem] border-none bg-transparent cursor-pointer"
          style={{ color: "var(--text-muted)" }}
        >
          ✕
        </button>
      </div>
      {userEmail && (
        <div className="px-5 py-3 border-b" style={{ borderColor: "var(--border)" }}>
          <p className="text-[0.75rem] truncate" style={{ color: "var(--text-muted)" }}>{userEmail}</p>
        </div>
      )}
      <div className="flex border-b shrink-0" style={{ borderColor: "var(--border)" }}>
        {TABS.map((t) => (
          <button
            key={t}
            type="button"
            onClick={() => setTab(t)}
            className="flex-1 py-2 text-[0.75rem] border-none cursor-pointer transition-colors duration-150"
            style={{
              background: "transparent",
              color: tab === t ? "var(--accent)" : "var(--text-muted)",
              borderBottom: tab === t ? "2px solid var(--accent)" : "2px solid transparent",
              fontWeight: tab === t ? 600 : 400,
            }}
          >
            {t}
          </button>
        ))}
      </div>
      <div className="flex-1 overflow-y-auto px-5 py-4 sidebar-scroll">
        {tab === "Appearance" && <AppearanceTab theme={theme} setTheme={setTheme} density={density} setDensity={setDensity} />}
        {tab === "Subscriptions" && <SubscriptionsTab />}
        {tab === "Filters" && <FiltersTab />}
      </div>
    </>
  )
}

export default function SettingsModal({ onClose, userEmail }) {
  const isMobile = useIsMobile()

  useEffect(() => {
    function onKey(e) { if (e.key === "Escape") onClose() }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [onClose])

  if (isMobile) {
    return (
      <div className="fixed inset-0 z-50 flex flex-col" style={{ background: "var(--sidebar-bg)" }}>
        <ModalContent userEmail={userEmail} onClose={onClose} />
      </div>
    )
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ background: "rgba(0,0,0,0.4)" }} onClick={onClose}>
      <div
        className="w-[520px] max-h-[80vh] rounded-lg shadow-xl flex flex-col overflow-hidden"
        style={{ background: "var(--sidebar-surface)", border: "1px solid var(--border)" }}
        onClick={(e) => e.stopPropagation()}
      >
        <ModalContent userEmail={userEmail} onClose={onClose} />
      </div>
    </div>
  )
}
