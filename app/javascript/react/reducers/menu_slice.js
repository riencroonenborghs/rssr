import { createSlice } from "@reduxjs/toolkit";

export const menuSlice = createSlice({
  name: "menu",
  initialState: {
    visible: false,
  },
  reducers: {
    showMenu: (state) => {
      state.visible = true;
    },
    hideMenu: (state) => {
      state.visible = false;
    },
  },
})

export const { showMenu, hideMenu } = menuSlice.actions;
export default menuSlice;
