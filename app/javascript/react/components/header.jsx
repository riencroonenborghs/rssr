import React from "react";
import { Link } from "react-router";
import { useSelector, useDispatch } from "react-redux";

import Bar3Icon from "../icons/bars3_icon";

import { showMenu } from "../reducers/menu_slice";
import mobile from "../utils/mobile";

function Header(props) {
  const subtitle = useSelector((state) => state.header.subtitle);
  const dispatch = useDispatch();

  return (
    <div className="flex flex-col">
      <div className="flex flex-row justify-between border-b border-gray-200 w-full p-3 text-emerald-700">
        <div className="flex flex-row items-center">
          <Link to={"/v2"}>
            <span className=" text-2xl font-bold">
              RSSReader
            </span>
          </Link>
          {subtitle !== null && <span className="ms-2 text-xs font-thin">{subtitle.name}</span>}
        </div>

        {mobile.mobile() && 
        <div onClick={() => dispatch(showMenu())}>
          <Bar3Icon size={4}></Bar3Icon>
        </div>}
      </div>
    </div>
  );
}

export default Header;
