import React, { Suspense } from "react";
import { BrowserRouter } from "react-router-dom";
import { Spin } from "antd";
import { LoadingOutlined } from "@ant-design/icons";
import { RootRouter } from "../../routes";

const antIcon = <LoadingOutlined style={{ fontSize: 100 }} spin />;

export const withRouter = function withRouter(
  component: () => React.ReactNode
) {
  function WithRouter() {
    return (
      <BrowserRouter>
        <Suspense
          fallback={
            <div className="center">
              <div style={{ display: "block" }}>
                <Spin indicator={antIcon} />
                <h2>Секундочку...</h2>
              </div>
            </div>
          }
        >
          <RootRouter />
        </Suspense>
      </BrowserRouter>
    );
  }

  WithRouter.displayName = `WithRouter(${component.name || "Component"})`;

  return WithRouter;
};
