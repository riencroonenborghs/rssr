// Entry point for the build script in your package.json

import "@rails/ujs"
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:before-frame-render", (event) => {
  const title = event.detail.newFrame.dataset.title;
  if (title) {
    setTimeout(() => { document.title = `RSSReader ${title}`; }, 500);
  };
});