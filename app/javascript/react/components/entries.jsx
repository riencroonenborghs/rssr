import React, { Fragment, useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import { BeatLoader } from "react-spinners";

import Entry from "../components/entry";
import { setSubtitle } from "../reducers/header_slice";
import { addManyToViewed } from "../reducers/entries_slice";

import Pages from "../components/pages";

function Entries(props) {
  const url = props.url;
  const subTitleCallback = props.subTitleCallback;

  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const dispatch = useDispatch();

  const style = {
    height: "calc(100vh - 58px)"
  };

  useEffect(() => {
    getEntries(currentPage);
  }, props.useEffectDependencies);

  const getEntries = (page) => {
    setLoading(true);
    fetch(`${url}?page=${page}`)
      .then((data) => data.json())
      .then((data) => {
        setCurrentPage(parseInt(data.page))
        setTotalPages(parseInt(data.totalPages))
        setEntries(data.entries)
        
        const viewedIds = data.entries.filter((e) => e.viewed).map((e) => e.id);
        dispatch(setSubtitle(subTitleCallback(data)));
        dispatch(addManyToViewed({ viewedIds: viewedIds }));
        setLoading(false);
      })
  }

  return (
    <Fragment>
      {loading && <div className="w-full flex flex-row justify-center" style={style}>
        <div className="flex flex-col justify-center">
          <BeatLoader color={"var(--color-emerald-700)"}></BeatLoader>
        </div>
      </div>}

      {!loading && <div className="flex flex-col overflow-auto" style={style}>
        {entries.map((entry) => <Entry entry={entry} key={entry.id}></Entry>)}

        <Pages currentPage={currentPage} totalPages={totalPages} callback={getEntries}></Pages>
      </div>}
    </Fragment>
  );
}

export default Entries;
