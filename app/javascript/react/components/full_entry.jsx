import React, { Fragment } from "react";
import { Link } from "react-router";

import Tags from "./tags";

function FullEntry(props) {
  const entry = props.entry;
  var markup = {__html: entry.description}
  return (
    <Fragment>
      <div className="flex flex-col p-2 pt-3 pb-3">
        <div className="font-thin text-xs">
          <span className="me-2">{entry.publishedAt}</span>
          <span className="me-2">/</span>
          <Link to={`/feeds/${entry.feed.id}`} className="text-emerald-700">
            {entry.feed.name}
          </Link>
        </div>
        <a href={entry.link} target={"blank"} className="text-emerald-800">
          {entry.title}
        </a>
        <Tags entry={entry}></Tags>
        {entry.image && <img src={entry.image} className="pt-2" />}
        <div className="pt-4" dangerouslySetInnerHTML={markup}></div>
      </div>
    </Fragment>
  );
}

export default FullEntry;
