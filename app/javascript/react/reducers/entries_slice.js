import { createSlice } from "@reduxjs/toolkit";
import { act } from "react";

export const entriesSlice = createSlice({
  name: "header",
  initialState: {
    viewedIds: [],
    entryId: null,
  },
  reducers: {
    addManyToViewed: (state, action) => {
      state.viewedIds = state.viewedIds.concat(action.payload.viewedIds);
    },
    addToViewed: (state, action) => {
      state.viewedIds.push(action.payload.viewedId);
    },
    readEntry: (state, action) => {
      state.entryId = action.payload.entryId;
    }
  },
})

export const { addManyToViewed, addToViewed, readEntry } = entriesSlice.actions;
export default entriesSlice;
