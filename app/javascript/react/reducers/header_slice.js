import { createSlice } from "@reduxjs/toolkit";

export const headerSlice = createSlice({
  name: "toast",
  initialState: {
    subtitle: null,
  },
  reducers: {
    setSubtitle: (state, action) => {
      state.subtitle = action.payload.subtitle
    },
  },
})

export const { setSubtitle } = headerSlice.actions;
export default headerSlice;
