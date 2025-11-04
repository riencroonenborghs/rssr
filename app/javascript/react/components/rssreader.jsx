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
import SubscriptionsView from "../views/subscriptions_view";
import FiltersView from "../views/filters_view";
import ReadEntryView from "../views/read_entry_view";

import mobile from "../utils/mobile";

function RSSReader(props) {
  const style = {
    height: "calc(100vh)"
  };

  const isMobile = mobile.mobile();

  return (
    <Provider store={store}>
      <BrowserRouter>        
        <TopMenu></TopMenu>

        <div className="flex flex-col">
          <Header></Header>

          <div className="flex flex-row">
            <SideMenu isMobile={isMobile}></SideMenu>

            <div className={isMobile ? "" : "w-1/3"}>
              <Routes>
                <Route path="/" element={<RecentView isMobile={isMobile} />} />
                <Route path="/v2" element={<RecentView isMobile={isMobile} />} />
                <Route path="/v2/feeds/:feedId" element={<FeedView isMobile={isMobile} />} />
                <Route path="/v2/entries/:entryId" element={<EntryView />} />
                <Route path="/v2/tags/:tag" element={<TagView isMobile={isMobile} />} />
                <Route path="/v2/bookmarks" element={<BookmarksView isMobile={isMobile} />} />
                <Route path="/v2/subscriptions" element={<SubscriptionsView />} />
                <Route path="/v2/filters" element={<FiltersView />} />
              </Routes>
            </div>

            <ReadEntryView isMobile={isMobile}></ReadEntryView>
          </div>
        </div>

        <Toast></Toast>
      </BrowserRouter>
    </Provider>
  );
}

export default RSSReader;
