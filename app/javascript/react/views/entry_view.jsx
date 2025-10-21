import React, { Fragment, useEffect, useState } from "react";
import { useParams } from "react-router";
import { useDispatch } from "react-redux";

import BigEntry from "../components/big_entry";
import { setSubtitle } from "../reducers/header_slice";
import { addToViewed } from "../reducers/entries_slice";

function EntryView(props) {
  let { entryId } = useParams();
  const [entry, setEntry] = useState({});
  const dispatch = useDispatch();

  useEffect(() => {
    getEntry();
  }, [entryId]);

  const getEntry = () => {
    fetch(`/v2/entries/${entryId}.json`)
      .then((data) => data.json())
      .then((data) => {
        setEntry(data.entry);
        dispatch(
          setSubtitle(
            {
              subtitle: { name: data.entry.feed.name }
            }
          )
        );
        dispatch(
          addToViewed(
            {
              viewedId: data.entry.id
            }
          )
        );
      })
  }

  return (
    <div className="flex flex-col overflow-auto">
      {entry?.id != null && <Fragment>
        <BigEntry entry={entry}></BigEntry>
      </Fragment>}
    </div>
  );
}

export default EntryView;
