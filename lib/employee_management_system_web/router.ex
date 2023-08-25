defmodule EmployeeManagementSystemWeb.Router do
  use EmployeeManagementSystemWeb, :router

  import EmployeeManagementSystemWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {EmployeeManagementSystemWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", EmployeeManagementSystemWeb do
    pipe_through(:browser)

    live("/", PageLive.Index, :index)
  end

  scope "/", EmployeeManagementSystemWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/chats", ChatLive.Index, :index)

    live("chat_show/:id", ChatShowLive.Index, :index)

    live("/groups/newgroup", ChatLive.Index, :newgroup)

    live("/groups", GroupLive.Index, :index)
    live("/groups/new", GroupLive.Index, :new)
    live("/groups/:id/edit", GroupLive.Index, :edit)

    live("/groups/:id", GroupLive.Show, :show)
    live("groups/:id/addgroupmember", GroupLive.Show, :addgroupmember)
    live("/groups/:id/show/edit", GroupLive.Show, :edit)

    live("/tasks", TaskLive.Index, :index)
    live("/tasks/:id/newtask", TaskLive.Show, :newtask)
    live("/tasks/:id/:task_id/edit", TaskLive.Show, :edit)
    live("/tasks/:id", TaskLive.Show, :show)
    live("mytasks/:id", TaskLive.Mytasks, :show)
    live("tasks/:id/:task_id/add_submission", TaskLive.Mytasks, :add_submission)
    live("tasks/:id/:task_id/:submission_id/edit_submission", TaskLive.Mytasks, :edit_submission)
    live("/tasks/:id/:task_id/newreview", TaskLive.Show, :newreview)
    live("/tasks/:id/:task_id/:review_id/edit", TaskLive.Show, :editreview)

    live("/events", EventLive.Index, :index)
    live("/events/new", EventLive.Index, :new)
    live("/events/:id/edit", EventLive.Index, :edit)

    live("/submissions", SubmissionLive.Index, :index)
    live("/submissions/new", SubmissionLive.Index, :new)
    live("/submissions/:id/edit", SubmissionLive.Index, :edit)
  end

  scope "/", EmployeeManagementSystemWeb do
    pipe_through([:browser, :require_authenticated_admin])

    live("/adminpanel", AdminPanelLive.Index, :index)
    live("/adminpanel/:id", AdminPanelLive.Show, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmployeeManagementSystemWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: EmployeeManagementSystemWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", EmployeeManagementSystemWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", EmployeeManagementSystemWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings", UserSettingsController, :update)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", EmployeeManagementSystemWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)
  end
end
