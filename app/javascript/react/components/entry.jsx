import React, { Fragment } from "react";
import { Link } from "react-router";
import { useSelector, useDispatch } from "react-redux";

import Tags from "./tags";
import { addToViewed } from "../reducers/entries_slice";
import StarIcon from "../icons/star_icon";

function Entry(props) {
  const entry = props.entry;
  const viewedIds = useSelector((state) => state.entries.viewedIds);
  const viewed = entry.viewed || viewedIds.includes(entry.id)
  const hasDescription = props.entry.description !== null;
  const link = hasDescription ? `/v2/entries/${entry.id}` : entry.link;
  const dispatch = useDispatch();

  const markViewed = () => {
    dispatch(
      addToViewed({
        viewedId: entry.id
      })
    )
  }

  return (
    <Fragment>
      <div className="flex flex-row border-b border-gray-100">
        {viewed && <div className="border-s-12 border-emerald-100"></div>}
        {entry.image && <img src={entry.image} width={128} className="p-2" />}
        <div className="flex flex-col p-2 pt-3 pb-3">
          <div className="font-thin text-xs">
            <span className="me-2">{entry.publishedAt}</span>
            <span className="me-2">/</span>
            <Link to={`/v2/feeds/${entry.feed.id}`} className="text-emerald-700">
              {entry.feed.name}
            </Link>
          </div>
          <a href={link} target={hasDescription ? "blank": ""} className="text-emerald-800" onClick={markViewed}>
            {entry.title}
          </a>
          <Tags entry={entry}></Tags>
        </div>
      </div>
    </Fragment>
  );
}

export default Entry;
