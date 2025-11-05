import React from "react";

import Entries from "../components/entries";

function RecentView(props) {
  const subTitleCallback = (data) => {
    return { subtitle: { name: null } };
  }
  return (<Entries  url={"/recent_entries.json"}
                    subTitleCallback={subTitleCallback}
                    useEffectDependencies={[]}
                    isMobile={props.isMobile}>
          </Entries>);
}

export default RecentView;
