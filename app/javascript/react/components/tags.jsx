import React from "react";
import { Link } from "react-router";

function Tags(props) {
  const entry = props.entry;
  return (    
    <div className="text-xxs">
      {entry.tags.map((tag, index) => <Link key={index}  to={`/tags/${encodeURI(tag.toLowerCase())}`}>
        <span className="me-1 bg-emerald-600 text-white rounded ps-1 pe-1">{tag.toUpperCase()}</span>
      </Link>)}
    </div>
  );
}

export default Tags;
