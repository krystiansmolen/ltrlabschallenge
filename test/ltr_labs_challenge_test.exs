defmodule LtrLabsChallengeTest do
  use ExUnit.Case

  doctest LtrLabsChallenge

  alias Schema.{Order, OrderItem}

  test "simple order with two items" do
    items = [
      %OrderItem{net_price: Decimal.new("10.00"), quantity: 2},
      %OrderItem{net_price: Decimal.new("5.50"), quantity: 1}
    ]

    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 10)

    assert Decimal.equal?(result.net_total, Decimal.new("25.50"))
    assert Decimal.equal?(result.tax, Decimal.new("2.55"))
    assert Decimal.equal?(result.total, Decimal.new("28.05"))
  end

  test "empty order" do
    order = %Order{items: []}
    result = LtrLabsChallenge.calculate_order(order, 20)

    assert Decimal.equal?(result.net_total, Decimal.new("0"))
    assert Decimal.equal?(result.tax, Decimal.new("0"))
    assert Decimal.equal?(result.total, Decimal.new("0"))
  end

  test "order with item having quantity zero" do
    items = [%OrderItem{net_price: Decimal.new("100.00"), quantity: 0}]
    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 15)

    assert Decimal.equal?(result.net_total, Decimal.new("0"))
    assert Decimal.equal?(result.tax, Decimal.new("0"))
    assert Decimal.equal?(result.total, Decimal.new("0"))
  end

  test "item with fractional price" do
    items = [%OrderItem{net_price: Decimal.new("0.99"), quantity: 3}]
    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 8)

    assert Decimal.equal?(result.net_total, Decimal.new("2.97"))
    assert Decimal.equal?(result.tax, Decimal.new("0.2376"))
    assert Decimal.equal?(result.total, Decimal.add(result.net_total, result.tax))
  end

  test "order with high quantity and tax" do
    items = [
      %OrderItem{net_price: Decimal.new("1.25"), quantity: 10000}
    ]

    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 25)

    assert Decimal.equal?(result.net_total, Decimal.new("12500.00"))
    assert Decimal.equal?(result.tax, Decimal.new("3125.00"))
    assert Decimal.equal?(result.total, Decimal.new("15625.00"))
  end

  test "tax rate of 0%" do
    items = [
      %OrderItem{net_price: Decimal.new("20.00"), quantity: 3}
    ]

    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 0)

    assert Decimal.equal?(result.net_total, Decimal.new("60.00"))
    assert Decimal.equal?(result.tax, Decimal.new("0"))
    assert Decimal.equal?(result.total, Decimal.new("60.00"))
  end

  test "tax rate with decimal" do
    items = [
      %OrderItem{net_price: Decimal.new("10.00"), quantity: 2}
    ]

    order = %Order{items: items}
    result = LtrLabsChallenge.calculate_order(order, 7.5)

    assert Decimal.equal?(result.net_total, Decimal.new("20.00"))
    assert Decimal.equal?(result.tax, Decimal.new("1.50"))
    assert Decimal.equal?(result.total, Decimal.new("21.50"))
  end
end
