defmodule RuleParser do
  @moduledoc """
  Parser for the expressions used as rules.
  """

  @doc ~S"""
  Parse an expression that is used in delegation ops.

    iex> RuleParser.parse_delegation_op("itx.value < 100 and itx.to != \"abcd\" and itx.assets == []")
    {:ok,[expr: [:value, :<, 100, :and, {:expr, [:to, :!=, {:v, "abcd"}, :and, :assets, :==, {:v, []}]}]], "", %{}, {1, 0}, 57}

    iex> RuleParser.parse_delegation_op("state.total_txs < 100 and state.total_tokens < 1000000")
    {:ok, [expr: [:total_txs, :<, 100, :and, :total_tokens, :<, 1000000]], "", %{}, {1, 0}, 54}

    iex> r = RuleParser.parse_delegation_op("System.halt(1)")
    iex> elem(r, 0)
    :error
  """
  defdelegate parse_delegation_op(s), to: RuleParser.DelegationOp, as: :parse

  # below definitions are for testing purpose only.
  # for testing purpose only

  @doc """
  Parse to an atom. For testing purpose. Please use `parse/2` instead.

    iex> RuleParser.parse_atom(":h")
    {:ok, [:h], "", %{}, {1, 0}, 2}

    iex> RuleParser.parse_atom(":hello_world")
    {:ok, [:hello_world], "", %{}, {1, 0}, 12}

    iex> RuleParser.parse_atom(":he2llo_world1")
    {:ok, [:he], "2llo_world1", %{}, {1, 0}, 3}

  """
  defdelegate parse_atom(s), to: RuleParser.Common

  @doc ~S"""
  Parse to a string. For testing purpose. Please use `parse/2` instead.

    iex> RuleParser.parse_quoted_string(~S("hello world"))
    {:ok, ["hello world"], "", %{}, {1, 0}, 13}

    iex> RuleParser.parse_quoted_string(~S(hello world))
    {:error, "expected byte equal to ?\"", "hello world", %{}, {1, 0}, 0}

    iex> RuleParser.parse_quoted_string(~S("hello \"world\""))
    {:ok, ["hello \"world\""], "", %{}, {1, 0}, 17}
  """
  defdelegate parse_quoted_string(s), to: RuleParser.Common

  @doc """
  Parse a value. For testing purpose. Please use `parse/2` instead.

    iex> RuleParser.parse_value("10")
    {:ok, [v: 10], "", %{}, {1, 0}, 2}

    iex> RuleParser.parse_value(~S(["a", :a, 1]))
    {:ok, [v: ["a", :a, 1]], "", %{}, {1, 0}, 12}
  """
  defdelegate parse_value(s), to: RuleParser.Common

  @doc """
  Parse a sub expr. For testing purpose. Please use `parse/2` instead.

    iex> RuleParser.parse_expr("a != 1")
    {:ok, [:a, :!=, {:v, 1}], "", %{}, {1, 0}, 6}

    iex> RuleParser.parse_expr(~S(a in ["hello", :world, 2]))
    {:ok, [:a, :in, {:v, ["hello", :world, 2]}], "", %{}, {1, 0}, 25}
  """
  defdelegate parse_expr(s), to: RuleParser.Common

  @doc ~S"""
  Parse an expression.

    iex> RuleParser.parse("a==1 and b == 2")
    {:ok, [expr: [:a, :==, {:v, 1}, :and, :b, :==, {:v, 2}]], "", %{}, {1, 0}, 15}

    iex> RuleParser.parse("a==1 and b in [\"abc\", :abc, 123]")
    {:ok, [expr: [:a, :==, {:v, 1}, :and, :b, :in, {:v, ["abc", :abc, 123]}]], "", %{}, {1, 0}, 32}

    iex> RuleParser.parse("a==1 and (b in [\"abc\", :abc, 123] or c != [1,2,3])")
    {:ok, [expr: [:a, :==, {:v, 1}, :and, {:expr, [:b, :in, {:v, ["abc", :abc, 123]}, :or, :c, :!=, {:v, [1, 2, 3]}]}]], "", %{}, {1, 0}, 50}

  """
  defdelegate parse(s), to: RuleParser.Common
end
