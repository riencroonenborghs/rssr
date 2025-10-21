import { configureStore } from "@reduxjs/toolkit";
import { entriesSlice } from "./entries_slice";
import { headerSlice } from "./header_slice";
import { menuSlice } from "./menu_slice";
import { toastSlice } from "./toast_slice";

export default configureStore({
  reducer: {
    entries: entriesSlice.reducer,
    header: headerSlice.reducer,
    menu: menuSlice.reducer,
    toast: toastSlice.reducer,
  },
  // Howl instance is in the store and poops out lots of non-serializeable errors
  middleware: getDefaultMiddleware =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});