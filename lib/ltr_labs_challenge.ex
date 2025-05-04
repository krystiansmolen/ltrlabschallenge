defmodule LtrLabsChallenge do
  @moduledoc """
  Module responsible for calculating the net total, tax, and gross total for an order
  based on its items and a given tax rate.
  """

  alias Schema.{Order, OrderItem}

  @doc """
  Calculates the net total, tax, and total for a given order and its items.

  Each item's `net_total` is calculated as `net_price * quantity`.
  Tax is applied as a percentage of the `net_total` (per item and for the whole order).
  The item's and the order's `total` is computed by adding the respective tax.

  If the order has no items or `nil`, it returns an order with all zero values.

  ## Parameters:
    - `order`: An `%Schema.Order{}` struct containing a list of `%Schema.OrderItem{}` structs (or `nil`)
    - `tax_rate_percent`: The tax rate expressed as a percentage. Can be a float, integer, string, or `Decimal`.

  ## Returns:
    - The updated `%Schema.Order{}` with computed `net_total`, `tax`, `total`,
      and updated items with computed values.

  ## Example:
      iex> LtrLabsChallenge.calculate_order(%Schema.Order{items: [%Schema.OrderItem{net_price: Decimal.new("10.00"), quantity: 2}]}, "20")
      %Schema.Order{
        net_total: Decimal.new("20.00"),
        tax: Decimal.new("4.000"),
        total: Decimal.new("24.000"),
        items: [%Schema.OrderItem{net_price: Decimal.new("10.00"), net_total: Decimal.new("20.00"), quantity: 2, total: Decimal.new("24.000")}]
      }

  """
  @spec calculate_order(Order.t(), Decimal.t() | number() | String.t()) :: Order.t()
  def calculate_order(%Order{items: nil}, _), do: calculate_order(%Order{items: []}, nil)

  def calculate_order(%Order{items: []}, _) do
    %Order{
      net_total: Decimal.new("0"),
      tax: Decimal.new("0"),
      total: Decimal.new("0"),
      items: []
    }
  end

  def calculate_order(%Order{items: items}, tax_rate_percent) do
    tax_rate_decimal = cast_tax_rate(tax_rate_percent)
    updated_items = update_items(items, tax_rate_decimal)

    net_total =
      Enum.reduce(updated_items, Decimal.new(0), fn i, acc -> Decimal.add(acc, i.net_total) end)

    tax = Decimal.mult(net_total, Decimal.div(tax_rate_decimal, 100))
    total = Decimal.add(net_total, tax)

    %Order{
      net_total: net_total,
      tax: tax,
      total: total,
      items: updated_items
    }
  end

  def calculate_order(%Order{}, _), do: calculate_order(%Order{items: []}, nil)

  defp cast_tax_rate(tax_rate_percent) do
    case Decimal.cast(tax_rate_percent) do
      {:ok, tax_rate} ->
        if Decimal.compare(tax_rate, Decimal.new(0)) == :lt do
          raise ArgumentError, "Tax rate cannot be negative"
        else
          tax_rate
        end

      :error ->
        raise ArgumentError, "Invalid tax rate"
    end
  end

  defp update_items(items, tax_rate) do
    Enum.map(items, fn %OrderItem{net_price: net_price, quantity: quantity} = item ->
      net_total = Decimal.mult(net_price, Decimal.new(quantity))
      tax = Decimal.mult(net_total, Decimal.div(tax_rate, 100))
      total = Decimal.add(net_total, tax)

      %OrderItem{item | net_total: net_total, total: total}
    end)
  end
end
