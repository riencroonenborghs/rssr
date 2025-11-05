import React from "react";
import { useParams } from "react-router";

import Entries from "../components/entries";

function TagView(props) {
  let { tag } = useParams();

  const subTitleCallback = (data) => {
    return { subtitle: { name: data.tag } };
  }
  return (<Entries  url={`/tags/${tag}.json`}
                    subTitleCallback={subTitleCallback}
                    useEffectDependencies={[tag]}
                    isMobile={props.isMobile}>
          </Entries>);
}

export default TagView;
