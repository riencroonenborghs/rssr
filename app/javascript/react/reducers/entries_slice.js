import { createSlice } from "@reduxjs/toolkit";

export const entriesSlice = createSlice({
  name: "header",
  initialState: {
    viewedIds: [],
  },
  reducers: {
    addManyToViewed: (state, action) => {
      state.viewedIds = state.viewedIds.concat(action.payload.viewedIds);
    },
    addToViewed: (state, action) => {
      state.viewedIds.push(action.payload.viewedId);
    },
  },
})

export const { addManyToViewed, addToViewed } = entriesSlice.actions;
export default entriesSlice;
