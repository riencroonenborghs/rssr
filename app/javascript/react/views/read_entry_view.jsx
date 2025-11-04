import React, { useState, useEffect, Fragment } from "react";
import { useSelector, useDispatch } from "react-redux";

import { addToViewed } from "../reducers/entries_slice";
import FullEntry from "../components/full_entry";

function ReadEntryView(props) {
  if (props.isMobile) { return ""; }

  const entryId = useSelector((state) => state.entries.entryId);
  const [entry, setEntry] = useState(null);
  const [loading, setLoading] = useState(true);
  const dispatch = useDispatch();

  const style = {
    height: "calc(100vh - 60px)",
    maxWidth: "calc(100vw - 620px)"
  };

  useEffect(() => {
    if (entryId !== null) { getEntry(); }
  }, [entryId]);

  const getEntry = () => {
    setLoading(true);
    fetch(`/v2/entries/${entryId}.json`)
      .then((data) => data.json())
      .then((data) => {
        setEntry(data.entry)
        console.log(data)
        
        dispatch(addToViewed({ viewedId: entryId }));
        setLoading(false);
      })
  }

  return (<Fragment>
    {entry && <div className="overflow-auto border-l border-emerald-200" style={style}>
      <FullEntry entry={entry}></FullEntry>
    </div>}
  </Fragment>)
}

export default ReadEntryView;
