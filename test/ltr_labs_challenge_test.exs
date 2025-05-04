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

  test "order with items as nil" do
    order = %Order{items: nil}
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

  describe "tax_rate_percent validation" do
    setup do
      items = [%OrderItem{net_price: Decimal.new("15.00"), quantity: 2}]

      %{order: %Order{items: items}}
    end

    test "raises if tax_rate_percent is a non-numeric string", %{order: order} do
      assert_raise ArgumentError, "Invalid tax rate", fn ->
        LtrLabsChallenge.calculate_order(order, "foo")
      end
    end

    test "raises if tax_rate_percent is negative string", %{order: order} do
      assert_raise ArgumentError, "Tax rate cannot be negative", fn ->
        LtrLabsChallenge.calculate_order(order, "-7.5")
      end
    end

    test "raises if tax_rate_percent is negative number", %{order: order} do
      assert_raise ArgumentError, "Tax rate cannot be negative", fn ->
        LtrLabsChallenge.calculate_order(order, -10)
      end
    end

    test "works correctly with valid integer tax_rate_percent", %{order: order} do
      result = LtrLabsChallenge.calculate_order(order, 10)

      assert Decimal.equal?(result.tax, Decimal.new("3.00"))
    end

    test "works correctly with valid float tax_rate_percent", %{order: order} do
      result = LtrLabsChallenge.calculate_order(order, 7.5)

      assert Decimal.equal?(result.tax, Decimal.new("2.25"))
    end

    test "works correctly with tax_rate_percent passed as string", %{order: order} do
      result = LtrLabsChallenge.calculate_order(order, "5.0")

      assert Decimal.equal?(result.tax, Decimal.new("1.50"))
    end

    test "works correctly with tax_rate_percent passed as 0%", %{order: order} do
      result = LtrLabsChallenge.calculate_order(order, 0)

      assert Decimal.equal?(result.net_total, Decimal.new("30.00"))
      assert Decimal.equal?(result.tax, Decimal.new("0"))
      assert Decimal.equal?(result.total, Decimal.new("30.00"))
    end

    test "works correctly with tax_rate_percent passed as float", %{order: order} do
      result = LtrLabsChallenge.calculate_order(order, 7.5)

      assert Decimal.equal?(result.net_total, Decimal.new("30.00"))
      assert Decimal.equal?(result.tax, Decimal.new("2.25"))
      assert Decimal.equal?(result.total, Decimal.new("32.25"))
    end
  end
end
