// Entry point for the build script in your package.json
// import "@hotwired/turbo-rails"
import React from "react";
import { createRoot } from "react-dom/client";

// import "./controllers"
import RSSReader from "./components/rssreader";


// // Turborails does not update the browser's URL when you click around.
// document.addEventListener("turbo:click", (event) => {
//   const url = event.detail.url;
//   const pushState = { url: url };
//   if(url.match(/add_to_playlist/) === null) {
//     window.history.pushState(pushState, "", url);
//   }
// })

// // Turborails does not update the browser's title when you click around.
// document.addEventListener("turbo:frame-render", (event) => {
//   const stream = event.detail.fetchResponse.responseHTML.then((data) => {
//     const div = document.createElement("div");
//     div.innerHTML = data;
//     const metaTitle = div.getElementsByTagName("meta_title")[0];
//     if (metaTitle !== undefined) {
//       const title = metaTitle.innerHTML;
//       document.title = `Bard - ${title}`;
//     }
//   });
// });

const rssreader = document.getElementById("rssreader");
if(rssreader !== null) {
  const root = createRoot(document.getElementById("rssreader"));
  root.render(
    <RSSReader></RSSReader>
  );  
}
