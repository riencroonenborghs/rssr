import React from "react";
import Icon from "./icon";

function Bar3Icon(props) {
  return (
    <Icon size={props.size} color={props.color}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
    </Icon>
  );
}

export default Bar3Icon;
