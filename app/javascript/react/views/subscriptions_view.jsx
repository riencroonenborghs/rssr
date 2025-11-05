import React, { Fragment, useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import { Link } from "react-router";
import { BeatLoader } from "react-spinners";

import { setSubtitle } from "../reducers/header_slice";
import Pages from "../components/pages";

function SubscriptionsView(props) {
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [subscriptions, setSubscriptions] = useState([]);
  const [loading, setLoading] = useState(true);
  const dispatch = useDispatch();

  const style = {
    height: "calc(100vh - 58px)"
  };

  useEffect(() => {
    dispatch(
      setSubtitle({ subtitle: { name: "Subscriptions" } } )
    );
    getSubscriptions(currentPage);
  }, []);

  const getSubscriptions = (page) => {
    setLoading(true);
    fetch(`/subscriptions.json?page=${page}`)
      .then((data) => data.json())
      .then((data) => {
        setCurrentPage(parseInt(data.page))
        setTotalPages(parseInt(data.totalPages))
        setSubscriptions(data.subscriptions)
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
        {subscriptions.map((subscription) => <div key={subscription.id} className="flex flex-col p-2 border-b border-emerald-700">
          <div className="flex flex-row items-center">
            <div className="font-bold text-md">
              <Link to={`/feeds/${subscription.feed.id}`} className="text-emerald-700">
              {subscription.feed.name}
              </Link>
            </div>
            <div className="ms-2 text-xs">- {subscription.entriesCount} entries</div>
          </div>
          <div className="font-thin text-sm">Added {subscription.createdAt}</div>
          <div className="font-thin text-sm">Last fetched {subscription.lastFetchedAt}</div>
          {subscription.error && <div className="font-thin text-xs text-red-400">{subscription.error}</div>}
        </div>)}

        <Pages currentPage={currentPage} totalPages={totalPages} callback={getSubscriptions}></Pages>
      </div>}
    </Fragment>
  );
}

export default SubscriptionsView;
