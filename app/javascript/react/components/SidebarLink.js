import React from "react"

export default function SidebarLink({ item, active, onClick }) {
  return (
    <a
      href={item.path}
      className={`sidebar-link${active ? " active" : ""}`}
      onClick={(e) => { e.preventDefault(); onClick(item) }}
    >
      <span>{item.label}</span>
      {item.badge != null && <span className="badge">{item.badge}</span>}
    </a>
  )
}
