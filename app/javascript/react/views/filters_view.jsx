import React, { Fragment, useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import { Link } from "react-router";
import { BeatLoader } from "react-spinners";

import { setSubtitle } from "../reducers/header_slice";
import Pages from "../components/pages";

function FiltersView(props) {
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filters, setFilters] = useState([]);
  const [loading, setLoading] = useState(true);
  const dispatch = useDispatch();

  const style = {
    height: "calc(100vh - 58px)"
  };

  useEffect(() => {
    dispatch(
      setSubtitle({ subtitle: { name: "Filters" } } )
    );
    getFilters(currentPage);
  }, []);

  const getFilters = (page) => {
    setLoading(true);
    fetch(`/v2/filters.json?page=${page}`)
      .then((data) => data.json())
      .then((data) => {
        setCurrentPage(parseInt(data.page))
        setTotalPages(parseInt(data.totalPages))
        setFilters(data.filters)
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
        <div className="grid grid-cols-2 gap-4 overflow-auto">
          {filters.map((filter) => <div key={filter.id} className="flex flex-col p-2 border-b border-emerald-700">
          <div>{filter.comparison} <span className="font-bold">{filter.value}</span></div>
          </div>)}
        </div>

        <Pages currentPage={currentPage} totalPages={totalPages} callback={getFilters}></Pages>
      </div>}
    </Fragment>
  );
}

export default FiltersView;
