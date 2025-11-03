import React from "react";
import { Link } from "react-router";

import CalendarIcon from "../icons/calendar_icon";
import FilterIcon from "../icons/filter_icon";
import RssIcon from "../icons/rss_icon";
import LockOpenIcon from "../icons/lock_open_icon"
import LockClosedIcon from "../icons/lock_closed_icon"
import StarIcon from "../icons/star_icon"
import BoltIcon from "../icons/bolt_icon"

function SideMenu(props) {
  if (props.isMobile) { return ""; }

  const style = {
    height: "calc(100vh - 58px)"
  };
  const signedIn = document.getElementsByTagName("body")[0].classList.value.includes("signed-in");

  return (
    <div className="flex flex-col bg-emerald-700 text-emerald-100 p-2" style={style}>
      <Link to={"/v2"}>
        <div className="flex flex-row items-center">
          <CalendarIcon size={3}></CalendarIcon>
          <span className="ms-2">Posts</span>
        </div>
      </Link>

      <Link to={"/v2/bookmarks"} className="mt-2">
        <div className="flex flex-row items-center">
          <StarIcon size={3}></StarIcon>
          <span className="ms-2">Bookmarks</span>
        </div>
      </Link>

      <Link to={"/v2/subscriptions"} className="mt-2">
        <div className="flex flex-row items-center">
          <RssIcon size={3}></RssIcon>
          <span className="ms-2">Feeds</span>
        </div>
      </Link>

      <Link to={"/v2/filters"} className="mt-2">
        <div className="flex flex-row items-center">
          <FilterIcon size={3}></FilterIcon>
          <span className="ms-2">Filters</span>
        </div>
      </Link>

      {!signedIn && <Link to={"/users/sign_in"} target="blank" className="mt-12">
        <div className="flex flex-row items-center">
          <LockOpenIcon size={3}></LockOpenIcon>
          <span className="ms-2">Sign In</span>
        </div>
      </Link>}

      {signedIn && <Link to={"/sidekiq"} target="blank" className="mt-12">
        <div className="flex flex-row items-center">
          <BoltIcon size={3}></BoltIcon>
          <span className="ms-2">Sidekiq</span>
        </div>
      </Link>}

      {signedIn && <Link to={"/users/sign_out"} target="blank" className="mt-2">
        <div className="flex flex-row items-center">
          <LockClosedIcon size={3}></LockClosedIcon>
          <span className="ms-2">Sign Out</span>
        </div>
      </Link>}

    </div>
  );
}

export default SideMenu;
