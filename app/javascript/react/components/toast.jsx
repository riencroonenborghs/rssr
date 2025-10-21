import React, { Fragment, useEffect } from "react";
import { useSelector, useDispatch } from "react-redux";

import { hideToast } from "../reducers/toast_slice";
import CloseIcon from "../icons/close_icon";

function Toast(props) {
  const message = useSelector((state) => state.toast.message);
  const visible = useSelector((state) => state.toast.visible);
  const type = useSelector((state) => state.toast.type);
  const dispatch = useDispatch();

  const colorClass = {
    alert: "bg-amber-300 text-amber-800",
    notice: "bg-lime-300 text-lime-800"
  }

  useEffect(() => {
    let interval = null;
    if (visible) {
      if (interval !== null) {
        clearInterval(interval);
      }
      
      interval = setInterval(() => {
        dispatch(hideToast())
      }, 3000);
    }
    
    return () => {
      if (interval !== null) {
        clearInterval(interval);
      }
    }
  }, [visible, message]);

  const hideClicked = () => {
    dispatch(hideToast());
  }

  return (
    <Fragment>
      {visible &&
        <div className="absolute bottom-2 right-px">
          <div className={"shadow-md alert p-2 flex justify-between items-center m-1 " + (colorClass[type]) }>
            <div className="flex items-center">
              <div className="me-2">
                {message}
              </div>
            </div>
            <div className="cursor-pointer" onClick={hideClicked}>
              <CloseIcon size={2} ></CloseIcon>
            </div>
          </div>
        </div>
      }
    </Fragment>
  );
}

export default Toast;
