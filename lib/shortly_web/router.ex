defmodule ShortlyWeb.Router do
  use ShortlyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortlyWeb do
    pipe_through :api

    get "/:hash", MainController, :show
    post "/", MainController, :create
  end
end
