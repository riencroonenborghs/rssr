import React, { useEffect, useState } from "react";
import { Link } from "react-router";
import { useSelector, useDispatch } from "react-redux";

import CalendarIcon from "../icons/calendar_icon";
import RSSIcon from "../icons/rss_icon";
import CloseIcon from "../icons/close_icon";
import LockOpenIcon from "../icons/lock_open_icon"
import StarIcon from "../icons/star_icon"

import { hideMenu } from "../reducers/menu_slice";

function Menu(props) {
  const visible = useSelector((state) => state.menu.visible);
  const [feeds, setFeeds] = useState([]);
  const dispatch = useDispatch();
  const signedIn = document.getElementsByTagName("body")[0].classList.value.includes("signed-in");

  const style = {
    height: "calc(100vh)"
  };

  useEffect(() => {
    fetch("/v2/feeds.json")
      .then((data) => data.json())
      .then((data) => {
        setFeeds(data.feeds)
      })
  }, []);

  const hide = () => {
    dispatch(hideMenu());
  }

  return (
    <div className={"flex flex-col fixed bg-white w-full overflow-auto p-4 " + (visible ? "" : "hidden")} style={style}>
      <div className="flex flex-row justify-between items-center text-emerald-700">
        <div className="uppercase">Menu</div>
        <div onClick={hide}><CloseIcon size={3}></CloseIcon></div>
      </div>  

      <div className="flex flex-row justify-between mt-3">
        <Link to={"/v2"} onClick={hide}>
          <div className="flex flex-row">
            <CalendarIcon size={3}></CalendarIcon>
            <span className="ms-2">Recent</span>
          </div>
        </Link>

        {!signedIn && <Link to={"/users/sign_in"} target="blank">
          <div className="flex flex-row text-xs">
            <LockOpenIcon size={2}></LockOpenIcon>
            <span className="ms-2">Sign in</span>
          </div>
        </Link>}
      </div>

      <div className="mt-3 mb-3">
        <Link to={"/v2/bookmarks"} onClick={hide}>
          <div className="flex flex-row">
            <StarIcon size={3}></StarIcon>
            <span className="ms-2">Bookmarks</span>
          </div>
        </Link>
      </div>
      
      <div className="flex flex-col">
        {feeds.map((feed) => <Link key={feed.id} to={"/v2/feeds/" + feed.id} onClick={hide}>
          <div className="flex flex-row justify-between hover:bg-emerald-700">
            <div className="flex flex-row items-start">
              <span className="mt-1"><RSSIcon size={2}></RSSIcon></span>
              <span className="ms-2">{feed.name}</span>
            </div>
            <div className="text-xs font-thin mt-1">
              {feed.numberOfEntries}
            </div>
          </div>
        </Link>)}
      </div>
    </div>
  );
}

export default Menu;
