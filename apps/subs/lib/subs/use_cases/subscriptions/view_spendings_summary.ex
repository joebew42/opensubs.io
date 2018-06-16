defmodule Subs.UseCases.Subscriptions.ViewSpendingsSummary do

  alias Subs.SubscriptionRepo

  def perform(user) do
    subscriptions = SubscriptionRepo.get_user_subscriptions(user, %{})

    %{
      currency: user.currency,
      currency_symbol: user.currency_symbol,
      total: calculate_total(subscriptions),
      spendings: group_by_category(subscriptions)
    }
  end

  defp calculate_total(subscriptions) do
    subscriptions
    |> Enum.reduce(0, fn(subscription, total) -> total + subscription.amount end)
  end

  defp group_by_category(subscriptions) do
    subscriptions
    |> Enum.map(& {&1.category, &1.amount})
    |> sum_amount_by_category
    |> Enum.map(&to_map/1)
  end

  defp sum_amount_by_category(subscriptions) do
    subscriptions
    |> Enum.reduce(%{}, &sum_amount_by_category/2)
    |> Map.to_list
  end

  defp sum_amount_by_category({category, amount}, spendings) do
    Map.put(spendings, category, Map.get(spendings, category, 0) + amount)
  end

  defp to_map({category, amount}) do
    %{category: category, amount: amount}
  end
end
