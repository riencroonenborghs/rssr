import React, { Fragment } from "react";
import { Link } from "react-router";
import { useSelector, useDispatch } from "react-redux";

import Tags from "./tags";
import { readEntry, addToViewed } from "../reducers/entries_slice";
import Bookmark from "./bookmark";

function Entry(props) {
  const entry = props.entry;
  const isMobile = props.isMobile;
  const viewedIds = useSelector((state) => state.entries.viewedIds);
  const viewed = entry.viewed || viewedIds.includes(entry.id)
  const hasDescription = props.entry.description !== null;
  const link = hasDescription ? `/entries/${entry.id}` : entry.link;
  const dispatch = useDispatch();

  const markViewed = () => {
    dispatch(
      addToViewed({
        viewedId: entry.id
      })
    )
  }

  const foo = () => {
    dispatch(readEntry({ entryId: entry.id }));
  }

  return (
    <Fragment>
      <div className={"flex flex-row border-b  " + (viewed ? "bg-emerald-50 border-emerald-100" : "border-gray-100")}>
        {entry.image && <img src={entry.image} width={128} className="p-2" />}
        <div className="flex flex-col p-2 pt-3 pb-3">
          <div className="font-thin text-xs flex flex-row">
            <Bookmark entry={entry}></Bookmark>
            <span className="me-2">{entry.publishedAt}</span>
            <span className="me-2">/</span>

            {<Link to={`/feeds/${entry.feed.id}`} className="text-emerald-700">
              {entry.feed.name}
            </Link>}
          </div>
          {isMobile && <a href={link} target={hasDescription ? "blank": ""} className="text-emerald-800" onClick={markViewed}>
            {entry.title}
          </a>}
          {!isMobile && <div className="text-emerald-800 cursor-pointer" onClick={foo}>
            {entry.title}
          </div>}
          <Tags entry={entry}></Tags>
        </div>
      </div>
    </Fragment>
  );
}

export default Entry;
