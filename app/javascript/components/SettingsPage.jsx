import { ENTRY_LAYOUTS, THEMES, useSettings } from "../lib/settings"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"

const THEME_OPTIONS = {
  system: { label: "System", description: "Follow this device's light or dark setting." },
  light: { label: "Light", description: "Dark text on a light background." },
  dark: { label: "Dark", description: "Light text on a dark background." }
}

const LAYOUT_OPTIONS = {
  regular: { label: "Regular", description: "Entries with their images." },
  compact: { label: "Compact", description: "No images and less spacing, to fit more entries." }
}

function OptionGroup({ legend, name, values, options, value, onChange }) {
  return (
    <fieldset>
      <legend className="text-xs font-semibold tracking-wide text-gray-500 uppercase">{legend}</legend>
      <div className="mt-3 space-y-2">
        {values.map((option) => (
          <label
            key={option}
            className="flex cursor-pointer gap-3 rounded-xl border border-gray-200 bg-surface p-3.5 shadow-sm transition-colors hover:border-brand/40 has-[:checked]:border-brand has-[:checked]:bg-brand/6 has-[:checked]:ring-1 has-[:checked]:ring-brand"
          >
            <input
              type="radio"
              name={name}
              value={option}
              checked={value === option}
              onChange={() => onChange(option)}
              className="mt-1 accent-brand"
            />
            <span>
              <span className="block text-sm font-medium">{options[option].label}</span>
              <span className="mt-0.5 block text-sm text-gray-500">{options[option].description}</span>
            </span>
          </label>
        ))}
      </div>
    </fieldset>
  )
}

// Display settings; they are saved in this browser.
export default function SettingsPage() {
  const { settings, updateSettings } = useSettings()

  return (
    <>
      <ListColumn>
        <ListHeader title="Settings" />
        <form className="space-y-7 p-4 md:p-5">
          <OptionGroup
            legend="Theme"
            name="theme"
            values={THEMES}
            options={THEME_OPTIONS}
            value={settings.theme}
            onChange={(theme) => updateSettings({ theme })}
          />
          <OptionGroup
            legend="Entry layout"
            name="entryLayout"
            values={ENTRY_LAYOUTS}
            options={LAYOUT_OPTIONS}
            value={settings.entryLayout}
            onChange={(entryLayout) => updateSettings({ entryLayout })}
          />
          <p className="text-xs text-gray-500">Settings are saved in this browser.</p>
        </form>
      </ListColumn>
      <DetailColumn>
        <Message>Changes apply straight away.</Message>
      </DetailColumn>
    </>
  )
}
