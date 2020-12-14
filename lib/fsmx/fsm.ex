defmodule Fsmx.Fsm do
  @moduledoc """
  Holds transition and callback logic for finite state machines

  By default, when using `use Fsmx.Struct`, this is automatically included as well.
  Specifying `use Fsmx.Struct, fsm: MyApp.Fsm` allows you to decouple this, though

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:state]
  end

  defmodule MyApp.Fsm do
    use Fsmx.Fsm, transitions: %{}

    def before_transition(struct, _from, _to) do
      # ...
    end
  end
  """

  @callback before_transition(struct, Fsmx.state_t, Fsmx.state_t) :: {:ok, struct} | {:error, any}

  if Code.ensure_loaded?(Ecto) do
    @callback transition_changeset(struct, Fsmx.state_t, Fsmx.state_t) :: Ecto.Changeset.t()
    @callback after_transition_multi(struct, Fsmx.state_t, Fsmx.state_t) ::
                {:ok, struct} | {:error, any}
  end

  defmacro __using__(opts \\ []) do
    quote do
      @before_compile unquote(__MODULE__)

      @fsm Keyword.get(unquote(opts), :fsm, __MODULE__)

      def __fsmx__(:state_field), do: Keyword.get(unquote(opts), :state_field, :state)
      def __fsmx__(:transitions), do: Keyword.fetch!(unquote(opts), :transitions)
      def __fsmx__(:fsm), do: @fsm
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: false do
      def before_transition(struct, _from, _to), do: {:ok, struct}

      if Code.ensure_loaded?(Ecto) do
        def transition_changeset(changeset, _from, _to, _params), do: changeset
        def after_transition_multi(struct, _from, _to), do: {:ok, struct}
      end
    end
  end
end
