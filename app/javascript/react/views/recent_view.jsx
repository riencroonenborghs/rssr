import React from "react";

import Entries from "../components/entries";

function RecentView(props) {
  const subTitleCallback = (data) => {
    return { subtitle: { name: null } };
  }
  return (<Entries  url={"/v2/recent_entries.json"}
                    subTitleCallback={subTitleCallback}
                    useEffectDependencies={[]}>
          </Entries>);
}

export default RecentView;
