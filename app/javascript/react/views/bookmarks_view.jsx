import React from "react";

import Entries from "../components/entries";

function BookmarksView(props) {
  const subTitleCallback = (data) => {
    return { subtitle: { name: "Bookmarks" } };
  }
  return (<Entries  url={"/v2/bookmarks.json"}
                    subTitleCallback={subTitleCallback}
                    useEffectDependencies={[]}
                    isMobile={props.isMobile}>
          </Entries>);
}

export default BookmarksView;
