defmodule ShortlyWeb.Router do
  use ShortlyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortlyWeb do
    pipe_through :api

    get "/:id", Controllers.MainController, :show
    post "/", Controllers.MainController, :create
  end
end
