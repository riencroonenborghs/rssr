import React from "react";
import { useParams } from "react-router";

import Entries from "../components/entries";

function FeedView(props) {
  let { feedId } = useParams();

  const subTitleCallback = (data) => {
    return { subtitle: { name: data.feed.name } };
  }
  return (<Entries  url={`/v2/feeds/${feedId}.json`}
                    subTitleCallback={subTitleCallback}
                    useEffectDependencies={[feedId]}
                    isMobile={props.isMobile}>
          </Entries>);

}

export default FeedView;
