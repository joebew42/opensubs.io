defmodule SubsWeb.Test.Controllers.SubscriptionControllerTest do
  use SubsWeb.ConnCase
  import Subs.Test.Support.Factory
  alias SubsWeb.Test.Support.ApiHelpers

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "Authentication" do
    test "returns 401 for missing Authorization header", %{conn: conn} do
      conn = post(conn, api_subscription_path(conn, :create))

      assert data = json_response(conn, 401)
      assert data["message"] == "Unauthorized"
    end

    test "returns 401 for invalid Authorization token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Bearer auth_token")
      conn = post(conn, api_subscription_path(conn, :create), subscription: %{})

      assert data = json_response(conn, 401)
      assert data["message"] == "Unauthorized"
    end

    test "returns 401 for invalid Authorization Bearer token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "random_token")
      conn = post(conn, api_subscription_path(conn, :create), subscription: %{})

      assert data = json_response(conn, 401)
      assert data["message"] == "Unauthorized"
    end

    test "returns 401 for valid token with unknown resource", %{conn: conn} do
      conn = ApiHelpers.put_authorization_header(conn, %{id: -1})
      conn = post(conn, api_subscription_path(conn, :create), subscription: %{})

      assert data = json_response(conn, 401)
      assert data["message"] == "Unauthorized"
    end

    test "returns 401 for valid token with unknown resource id", %{conn: conn} do
      conn = ApiHelpers.put_authorization_header(conn, %{id: "token"})
      conn = post(conn, api_subscription_path(conn, :create), subscription: %{})

      assert data = json_response(conn, 401)
      assert data["message"] == "Unauthorized"
    end
  end

  describe "GET /api/subscriptions" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = ApiHelpers.put_authorization_header(conn, user)

      [conn: conn, user: user]
    end

    test "returns 200 with no subscriptions for user", %{conn: conn} do
      insert_list(3, :complete_subscription, %{user_id: insert(:user).id})
      conn = get(conn, api_subscription_path(conn, :index))

      assert %{"data" => subscriptions} = json_response(conn, 200)
      assert subscriptions == []
    end

    test "returns 200 with user subscriptions", %{conn: conn, user: user} do
      user_subscriptions = insert_list(3, :complete_subscription, %{user_id: user.id})
      conn = get(conn, api_subscription_path(conn, :index))

      assert %{"data" => subscriptions} = json_response(conn, 200)
      assert Enum.count(subscriptions) == 3

      for subscription <- user_subscriptions do
        assert Enum.find(subscriptions, fn sub -> sub["id"] == subscription.id end) != nil
      end
    end

    test "returns 200 with subscriptions metadata", %{conn: conn, user: user} do
      insert(:complete_subscription, %{amount: 1000, cycle: "monthly", user_id: user.id})
      insert(:complete_subscription, %{amount: 1000, cycle: "yearly", user_id: user.id})

      conn = get(conn, api_subscription_path(conn, :index))
      assert %{"meta" => meta} = json_response(conn, 200)

      assert meta["avg"]["monthly"] == "£10.83"
      assert meta["avg"]["yearly"] == "£130.00"
    end

    test "returns subscriptions filter by date", %{conn: conn, user: user} do
      sub =
        insert(:complete_subscription, %{
          next_bill_date: ~N[2018-11-01T00:00:00Z],
          user_id: user.id
        })

      data_conn =
        get(
          conn,
          api_subscription_path(conn, :index, %{
            "next_bill_date_gte" => "2018-11-01",
            "next_bill_date_tte" => "2018-11-30"
          })
        )

      assert %{"data" => [subscription]} = json_response(data_conn, 200)

      assert subscription["id"] == sub.id

      empty_conn =
        get(
          conn,
          api_subscription_path(conn, :index, %{
            "next_bill_date_gte" => "2018-12-01",
            "next_bill_date_lte" => "2018-12-31"
          })
        )

      assert %{"data" => []} = json_response(empty_conn, 200)
    end
  end

  describe "GET /api/subscriptions:id" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = ApiHelpers.put_authorization_header(conn, user)

      [conn: conn, user: user]
    end

    test "returns 404 for unknown", %{conn: conn} do
      conn = get(conn, api_subscription_path(conn, :show, -1))

      assert %{"message" => message} = json_response(conn, 404)
      assert message == "Not found"
    end

    test "returns 200 with user subscription", %{conn: conn, user: user} do
      created_subscription = insert(:complete_subscription, %{user_id: user.id})
      conn = get(conn, api_subscription_path(conn, :show, created_subscription.id))

      assert %{"data" => subscription} = json_response(conn, 200)
      assert subscription["id"] == created_subscription.id
    end
  end

  describe "POST /api/subscriptions" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = ApiHelpers.put_authorization_header(conn, user)

      [conn: conn]
    end

    test "returns bad request when requesting without subscription params", %{conn: conn} do
      conn = post(conn, api_subscription_path(conn, :create))

      assert data = json_response(conn, 400)
      assert data["message"] == "Missing subscription params"
    end

    test "returns unprocessable entity when requesting with empty subscription params", %{
      conn: conn
    } do
      conn = post(conn, api_subscription_path(conn, :create), subscription: %{})

      assert data = json_response(conn, 422)

      assert data["data"]["errors"] == %{
               "name" => ["can't be blank"],
               "amount" => ["can't be blank"],
               "amount_currency" => ["can't be blank"],
               "cycle" => ["can't be blank"]
             }
    end

    test "returns unprocessable entity when given invalid params", %{conn: conn} do
      conn =
        post(
          conn,
          api_subscription_path(conn, :create),
          subscription: %{
            "amount" => -1,
            "amount_currency" => "DUNNO",
            "cycle" => "hourly",
            "color" => "invalid",
            "first_bill_date" => "invalid"
          }
        )

      assert data = json_response(conn, 422)

      assert data["data"]["errors"] == %{
               "name" => ["can't be blank"],
               "amount" => ["must be greater than 0"],
               "amount_currency" => ["unknown currency"],
               "cycle" => ["must be one of: monthly, yearly"],
               "color" => ["invalid format, must be HEX format, ex: #FF0000"],
               "first_bill_date" => ["is invalid"]
             }
    end

    # TODO: Find a better way of doing an integration test that depends on the
    # current date. Should it be in a mock? A GenServer that holds the current
    # date and "freezes" it for the test?
    # This test should fail at the end of January to remind me of this again!
    test "creates custom subscription given all params", %{conn: conn} do
      conn =
        post(
          conn,
          api_subscription_path(conn, :create),
          subscription: %{
            "name" => "Custom Service",
            "description" => "Custom Service Subscription",
            "amount" => "7.99",
            "amount_currency" => "GBP",
            "cycle" => "monthly",
            "color" => "#36dd30",
            "first_bill_date" => "2018-01-31T00:00:00Z"
          }
        )

      assert data = json_response(conn, 201)

      {id, data} = Map.pop(data["data"], "id")

      assert id != nil

      assert data == %{
               "name" => "Custom Service",
               "description" => "Custom Service Subscription",
               "amount" => "7.99",
               "amount_currency" => "GBP",
               "amount_currency_symbol" => "£",
               "cycle" => "monthly",
               "color" => "#36DD30",
               "first_bill_date" => "2018-01-31T00:00:00Z",
               "next_bill_date" => "2018-01-31T00:00:00Z",
               "service_code" => nil
             }
    end
  end

  describe "PATCH /api/subscriptions" do
    setup %{conn: conn} do
      user = insert(:user)
      conn = ApiHelpers.put_authorization_header(conn, user)

      [conn: conn, user: user]
    end

    test "returns bad request when requesting without subscription params", %{
      conn: conn,
      user: user
    } do
      subscription = insert(:complete_subscription, user_id: user.id)
      conn = patch(conn, api_subscription_path(conn, :update, subscription.id))

      assert data = json_response(conn, 400)
      assert data["message"] == "Missing subscription params"
    end

    test "returns not found for unknown user subscription", %{conn: conn} do
      another_users_subscription =
        insert(
          :complete_subscription,
          user_id: insert(:user).id
        )

      conn =
        patch(
          conn,
          api_subscription_path(conn, :update, another_users_subscription.id),
          subscription: %{}
        )

      assert data = json_response(conn, 404)
      assert data["message"] == "Subscription not found"
    end

    test "returns unprocessable entity when requesting with empty subscription params", %{
      conn: conn,
      user: user
    } do
      subscription = insert(:complete_subscription, user_id: user.id)

      conn =
        patch(
          conn,
          api_subscription_path(conn, :update, subscription.id),
          subscription: %{"name" => ""}
        )

      assert data = json_response(conn, 422)

      assert data["data"]["errors"] == %{
               "name" => ["can't be blank"]
             }
    end

    test "Updates subscription and returns ok", %{conn: conn, user: user} do
      subscription = insert(:complete_subscription, user_id: user.id)

      conn =
        patch(
          conn,
          api_subscription_path(conn, :update, subscription.id),
          subscription: %{"name" => "Updated"}
        )

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == subscription.id
      assert data["name"] == "Updated"
    end
  end
end
