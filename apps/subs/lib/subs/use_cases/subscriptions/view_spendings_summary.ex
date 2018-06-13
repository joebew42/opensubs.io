defmodule Subs.UseCases.Subscriptions.ViewSpendingsSummary do

  alias Subs.Helpers.Money
  alias Subs.SubscriptionRepo

  def perform(user) do
    all_subscriptions = SubscriptionRepo.get_user_subscriptions(user, %{})

    case all_subscriptions do
      [] ->
        %{
          data: %{
            currency: user.currency,
            currency_symbol: user.currency_symbol,
            total: "0.00",
            spendings: []
          }
        }
      subscriptions ->
        %{
          data: %{
            currency: user.currency,
            currency_symbol: user.currency_symbol,
            total: calculate_total(subscriptions),
            spendings: group_by_category(subscriptions)
          }
        }
    end
  end

  defp calculate_total(subscriptions) do
    Enum.reduce(subscriptions, 0, fn(subscription, total) -> total + subscription.amount end)
    |> Money.to_human
  end

  defp group_by_category(subscriptions) do
    Enum.map(subscriptions, fn(subscription) -> %{category: subscription.category, amount: subscription.amount} end)
    |> Enum.reduce([], fn(subscription, groups) ->
        case Enum.find(groups, fn(current_subscription) -> subscription.category == current_subscription.category end) do
          nil -> [subscription|groups]
          _ -> groups # CONTINUE FROM HERE
        end
      end)
    |> Enum.map(fn(subscription) -> Map.put(subscription, :amount, Money.to_human(subscription.amount)) end)
  end
end
