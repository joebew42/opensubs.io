defmodule SubsWeb.Test.Acceptance.SubscriptionsNewTest do
  use SubsWeb.FeatureCase, async: true

  import Wallaby.Query

  alias Subs.{User, UserRepo}

  @tag :acceptance
  test "redirects to login if trying to access subscriptions new page when user is not logged", %{session: session} do
    session
    |> visit("/subscriptions/new")
    |> assert_has(css("#login-form"))
  end

  @tag :acceptance
  test "loads new subcription page when user is logged", %{session: session} do
    session
    |> assert_signup_and_login_user()
    |> visit("/subscriptions/new")
    |> assert_has(css("#new-subscription-form"))
  end

  @tag :acceptance
  test "renders errors when submitting an empty form", %{session: session} do
    session
    |> assert_signup_and_login_user()
    |> visit("/subscriptions/new")
    |> assert_has(css("#new-subscription-form"))
    |> fill_in(css("#new-subscription-form .subscription-name"), with: "")
    |> click(css("#new-subscription-form button[type=\"submit\"]"))
    |> assert_has(css("li", text: "name: can't be blank"))
  end

  @tag :acceptance
  test "creates subscription and renders it on the page", %{session: session} do
    session
    |> assert_signup_and_login_user()
    |> visit("/subscriptions/new")
    |> assert_has(css("#new-subscription-form"))
    |> fill_in(css("#new-subscription-form .subscription-name"), with: "Dropbox")
    |> fill_in(css("#new-subscription-form .subscription-amount"), with: "1")
    |> fill_in(css("#new-subscription-form .subscription-amount-currency"), with: "GBP")
    |> fill_in(css("#new-subscription-form .subscription-cycle"), with: "yearly")
    |> click(css("#new-subscription-form button[type=\"submit\"]"))
    |> assert_has(css("h3", text: "Your subscriptions"))
    |> assert_has(css(".SubscriptionListItem--name", text: "Dropbox"))
  end

  # TODO: Move to helper
  def assert_signup_and_login_user(session, email \\ "joaquim@example.com") do
    password = "123456"

    session
    |> visit("/signup")
    |> assert_has(css("#app"))
    |> fill_in(css("#signup-form .user-email"), with: email)
    |> fill_in(css("#signup-form .user-password"), with: password)
    |> fill_in(css("#signup-form .user-password-confirmation"), with: password)
    |> click(css("#signup-btn"))
    |> assert_has(css("p", text: "A confirmation email was sent to #{email}."))

    # Set known confirmation token
    user = UserRepo.get_by_email(email)
    {:ok, user} = User.confirmation_changeset(user) |> Repo.update()

    session
    |> visit("/users/confirm_signup?t=#{user.confirmation_token}")
    |> assert_has(css("#app"))
    |> assert_has(css("p", text: "Account confirmed, ready to login"))

    session
    |> visit("/login")
    |> assert_has(css("#login-form"))
    |> fill_in(css("#login-form .user-email"), with: email)
    |> fill_in(css("#login-form .user-password"), with: password)
    |> click(css("#login-btn"))
    |> assert_has(css(".current-user", text: email))

    session
  end
end
