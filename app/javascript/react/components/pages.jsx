import React from "react";

import BackwardIcon from "../icons/backward_icon";
import ForwardIcon from "../icons/forward_icon";

function Pages(props) {
  const currentPage = props.currentPage;
  const totalPages = props.totalPages;
  const callback = props.callback;

  const previousPage = () => {
    callback(currentPage - 1);
  }

  const nextPage = () => {
    callback(currentPage + 1);
  }

  if (totalPages == 1) { return ""; }

  return (
    <div className="pt-4 pb-2 flex flex-row justify-center items-center text-emerald-800">
      {currentPage - 1 > 0 && <a className="text-sm p-2 rounded" onClick={() => previousPage()}><BackwardIcon size={3}></BackwardIcon></a>}
      <span className="ms-2 me-2">{currentPage}</span>
      {currentPage + 1 < totalPages && <a className="text-sm p-2 rounded" onClick={() => nextPage()}><ForwardIcon size={3}></ForwardIcon></a>}
    </div>
  );
}

export default Pages;
