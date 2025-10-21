import React from "react";
import Icon from "./icon";

function CloseIcon(props) {
  return (
    <Icon size={props.size} color={props.color}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18 18 6M6 6l12 12" />
    </Icon>
  );
}

export default CloseIcon;
