import { DetailColumn, ListColumn, Message } from "./Columns"

// Placeholder for pages that are not built yet.
export default function Page({ title }) {
  return (
    <>
      <ListColumn>
        {/* <h1 className="p-4 text-xl font-semibold md:p-6">{title}</h1> */}
      </ListColumn>
      <DetailColumn><Message>Nothing selected</Message></DetailColumn>
    </>
  )
}
