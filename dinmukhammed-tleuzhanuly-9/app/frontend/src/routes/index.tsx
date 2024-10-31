import { lazy } from "react";
import { useRoutes } from "react-router-dom";

const Contancts = lazy(() => import("../pages/listContact"));
const NewContact = lazy(() => import("../pages/newContact"));

function RootRouterPath() {
  const routes = [
    {
      path: "/",
      element: <Contancts />,
    },
    {
      path: "/new_contact",
      element: <NewContact />,
    },
    { path: "contacts", element: <Contancts /> },
  ];
  return <>{useRoutes(routes)}</>;
}

export const RootRouter = () => <RootRouterPath />;
