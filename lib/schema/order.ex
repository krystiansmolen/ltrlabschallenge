defmodule Schema.Order do
  @type t :: %__MODULE__{
          net_total: Decimal.t() | nil,
          tax: Decimal.t() | nil,
          total: Decimal.t() | nil,
          items: [OrderItem.t()] | nil
        }

  defstruct [:net_total, :tax, :total, :items]
end
