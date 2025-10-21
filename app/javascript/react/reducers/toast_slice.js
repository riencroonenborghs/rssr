import { createSlice } from "@reduxjs/toolkit";

export const toastSlice = createSlice({
  name: "toast",
  initialState: {
    message: "",
    type: "alert",
    visible: false,
  },
  reducers: {
    showAlert: (state, action) => {
      state.message = action.payload;
      state.type = "alert";
      state.visible = true;
    },
    showNotice: (state, action) => {
      state.message = action.payload;
      state.type = "notice";
      state.visible = true;
    },
    hideToast: (state) => {
      state.visible = false;
    },
  },
})

export const { showAlert, showNotice, hideToast } = toastSlice.actions;
export default toastSlice;
