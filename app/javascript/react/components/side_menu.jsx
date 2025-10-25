import React from "react";
import { Link } from "react-router";

import CalendarIcon from "../icons/calendar_icon";
import FilterIcon from "../icons/filter_icon";
import RssIcon from "../icons/rss_icon";
import LockOpenIcon from "../icons/lock_open_icon"
import LockClosedIcon from "../icons/lock_closed_icon"
import StarIcon from "../icons/star_icon"

import mobile from "../utils/mobile";

function SideMenu(props) {
  if (mobile.mobile()) { return ""; }

  const signedIn = document.getElementsByTagName("body")[0].classList.value.includes("signed-in");

  return (
    <div className="flex flex-col bg-emerald-700 text-emerald-100 p-2">
      <Link to={"/v2"}>
        <CalendarIcon size={3}></CalendarIcon>
      </Link>

      <Link to={"/v2/subscription"} className="mt-2">
        <RssIcon size={3}></RssIcon>
      </Link>

      <Link to={"/v2/bookmarks"} className="mt-2">
        <StarIcon size={3}></StarIcon>
      </Link>

      <Link to={"/v2/filters"} className="mt-2">
        <FilterIcon size={3}></FilterIcon>
      </Link>

      {!signedIn && <Link to={"/users/sign_in"} target="blank" className="mt-12">
        <LockOpenIcon size={3}></LockOpenIcon>
      </Link>}

      {signedIn && <Link to={"/users/sign_out"} target="blank" className="mt-12">
        <LockClosedIcon size={3}></LockClosedIcon>
      </Link>}

    </div>
  );
}

export default SideMenu;
