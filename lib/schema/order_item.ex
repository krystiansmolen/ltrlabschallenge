defmodule Schema.OrderItem do
  @type t :: %__MODULE__{
          net_price: Decimal.t(),
          quantity: integer(),
          net_total: Decimal.t() | nil,
          total: Decimal.t() | nil
        }

  defstruct [:net_price, :quantity, :net_total, :total]
end
