import React from "react";
import { Provider } from "react-redux";
import { BrowserRouter, Routes, Route } from "react-router";

import store from "../reducers/store";

import TopMenu from "./top_menu";
import SideMenu from "./side_menu";
import Header from "./header";
import Toast from "./toast";

import RecentView from "../views/recent_view";
import FeedView from "../views/feed_view";
import EntryView from "../views/entry_view";
import TagView from "../views/tag_view";
import BookmarksView from "../views/bookmarks_view";

function RSSReader(props) {
  const style = {
    height: "calc(100vh)"
  };

  return (
    <Provider store={store}>
      <BrowserRouter>        
        <TopMenu></TopMenu>

        <div className="flex flex-col">
          <Header></Header>

          <div className="flex flex-row">
            <SideMenu></SideMenu>

            <div className="w-full">
              <Routes>
                <Route path="/v2" element={<RecentView />} />
                <Route path="/v2/feeds/:feedId" element={<FeedView />} />
                <Route path="/v2/entries/:entryId" element={<EntryView />} />
                <Route path="/v2/tags/:tag" element={<TagView />} />
                <Route path="/v2/bookmarks" element={<BookmarksView />} />
              </Routes>
            </div>
          </div>
        </div>

        <Toast></Toast>
      </BrowserRouter>
    </Provider>
  );
}

export default RSSReader;
