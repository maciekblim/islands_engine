defmodule IslandsEngie.Rules do
    alias __MODULE__

    defstruct state: :initialized,
              player1: :islands_not_set,
              player2: :islands_not_set

    @type state :: :initialized | :players_set | :set_islands | :player1_turn
    @type action :: :add_player | :position_islands
    @type set_island_state :: :islands_not_set | :islands_set
    @type t :: %__MODULE__{
        state: state(),
        player1: set_island_state(),
        player2: set_island_state()
    }

    @doc """
    ## Examples

        iex> IslandsEngie.Rules.new()
        %Rules{}
    """
    @spec new() :: t()
    def new(), do: %Rules{}

    @doc """
    ## Examples

        iex> rules = IslandsEngie.Rules.new()
        ...> IslandsEngie.Rules.check(rules, :add_player)
        {:ok, %IslandsEngie.Rules{state: :players_set}}

        iex> rules = IslandsEngie.Rules.new()
        ...> IslandsEngie.Rules.check(rules, :wrong_action)
        :error

        iex> rules = IslandsEngie.Rules.new()
        ...> {:ok, rules} = IslandsEngie.Rules.check(rules, :add_player)
        ...> IslandsEngie.Rules.check(rules, {:position_islands, :player2})
        {:ok,
         %IslandsEngie.Rules{
            state: :players_set,
            player1: :islands_not_set,
            player2: :islands_not_set
        }}

        iex> rules = IslandsEngie.Rules.new()
        ...> {:ok, rules} = IslandsEngie.Rules.check(rules, :add_player)
        ...> {:ok, rules} = IslandsEngie.Rules.check(rules, {:position_islands, :player1})
        ...> {:ok, rules} = IslandsEngie.Rules.check(rules, {:position_islands, :player2})
        ...> {:ok, rules} = IslandsEngie.Rules.check(rules, {:set_islands, :player1})
        {:ok,
         %IslandsEngie.Rules{
            state: :players_set,
            player1: :islands_set,
            player2: :islands_not_set
        }}
    """
    @spec check(t(), action()) :: :error | {:ok, t()}
    def check(%Rules{state: :initialized} = rules, :add_player),
        do: {:ok, %Rules{rules | state: :players_set}}

    def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
        case Map.fetch!(rules, player) do
            :islands_set -> :error
            :islands_not_set -> {:ok, rules}
        end
    end

    def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
        rules = Map.put(rules, player, :islands_set)
        case both_players_islands_set?(rules) do
            true -> {:ok, %Rules{rules | state: :player1_turn}}
            false -> {:ok, rules}
        end
    end

    def check(_state, _action), do: :error

    defp both_players_islands_set?(%Rules{player1: :islands_set, player2: :islands_set}),
        do: true
    defp both_players_islands_set?(_rules),
        do: false
end