import React, { Fragment, useState } from "react";

import csrf from "../utils/csrf";
import StarIcon from "../icons/star_icon";

function Bookmark(props) {
  const [bookmarked, setBookmarked] = useState(props.entry.bookmarked)
  const signedIn = document.getElementsByTagName("body")[0].classList.value.includes("signed-in");

  const toggleBookmark = () => {
    let headers = { "x-csrf-token": csrf.csrfToken() };
    fetch(`/v2/entries/${props.entry.id}/bookmarks`, { method: "POST", headers: headers  })
      .then((data) => data.json())
      .then((data) => { 
        if (data.success) {
          setBookmarked(data.bookmark === "created");
        }
      });
  }

  return (
    <Fragment>
      {signedIn && <div className="me-2 cursor-pointer" onClick={toggleBookmark}><StarIcon solid={bookmarked} size={2}></StarIcon></div>}
    </Fragment>
  );
}

export default Bookmark;
