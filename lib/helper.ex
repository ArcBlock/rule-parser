defmodule RuleParser.Helper do
  @moduledoc """
  Helper functions for making parser work easy
  """
  import NimbleParsec

  @max_nested 3

  @doc """
  Ignore white space and tab, and make it optional
  """
  @spec ignore_space() :: NimbleParsec.t()
  def ignore_space do
    parse_ws()
    |> ignore()
  end

  @doc """
  Ignore separator
  """
  @spec ignore_sep(binary()) :: NimbleParsec.t()
  def ignore_sep(sep), do: ignore(string(sep))

  @doc """
  Ignore bracket and the inner space
  """
  @spec ignore_bracket(char(), NimbleParsec.t(), char()) :: NimbleParsec.t()
  def ignore_bracket(left, combinator, right) do
    with_bracket =
      ignore(ascii_char([left]))
      |> concat(ignore_space())
      |> concat(combinator)
      |> concat(ignore_space())
      |> ignore(ascii_char([right]))

    choice([with_bracket, combinator])
  end

  @doc """
   Ignore both lowercase name and uppercase name for keyword
  """
  @spec ignore_keyword(binary()) :: NimbleParsec.t()
  def ignore_keyword(name) do
    upper = String.upcase(name)
    lower = String.downcase(name)

    ignore(choice([string(upper), string(lower)]))
  end

  @doc """
   Ignore predefined prefixes
  """
  @spec ignore_prefix(list(binary())) :: NimbleParsec.t()
  def ignore_prefix([]), do: empty()

  def ignore_prefix(names),
    do: ignore(choice(Enum.map(names, &string(&1)))) |> concat(ignore_sep("."))

  @doc """
  parse white space or tab
  """
  @spec parse_ws() :: NimbleParsec.t()
  def parse_ws, do: ascii_string([?\s, ?\t], min: 1) |> repeat()

  @doc """
  We fixed the 1st char must be a-z, so for opts if min/max is given, please consider to shift with 1.
  """
  @spec parse_tag(list()) :: NimbleParsec.t()
  def parse_tag(range \\ [?a..?z, ?_]) do
    p =
      ascii_string([?a..?z], max: 1)
      |> optional(ascii_string(range, min: 1))

    result =
      Enum.reduce(1..@max_nested, p, fn _, acc ->
        acc
        |> optional(ascii_string([?.], max: 1))
        |> ascii_string([?a..?z], max: 1)
        |> optional(ascii_string(range, min: 1))
      end)

    result |> reduce({:parser_result_to_string, []})
  end

  @doc """
  Match integer
  """
  @spec parse_integer() :: NimbleParsec.t()
  def parse_integer do
    integer(min: 1)
  end

  @doc """
  Match string with quote, and inner quote, e.g. ~S("this is \"hello world\"")
  """
  @spec parse_string(char()) :: NimbleParsec.t()
  def parse_string(quote_char \\ ?") do
    ignore(ascii_char([quote_char]))
    |> repeat_while(
      choice([
        "\\#{<<quote_char>>}" |> string() |> replace(quote_char),
        utf8_char([])
      ]),
      {:parser_result_not_quote, [quote_char]}
    )
    |> ignore(ascii_char([?"]))
    |> reduce({List, :to_string, []})
  end

  @doc """
  Match an atom with space
  """
  @spec parse_atom() :: NimbleParsec.t()
  def parse_atom() do
    ignore(ascii_char([?:]))
    |> concat(parse_tag())
    |> reduce({:parser_result_to_atom, []})
  end

  @doc """
  Match a list of predefined ops
  """
  @spec parse_ops([String.t()]) :: NimbleParsec.t()
  def parse_ops(ops) do
    choice(Enum.map(ops, fn op -> op_replace(op) end))
  end

  def parser_result_not_quote(<<quote_char::size(8), _::binary>>, context, _, _, char)
      when quote_char == char,
      do: {:halt, context}

  def parser_result_not_quote(_, context, _, _, _), do: {:cont, context}

  def parser_result_to_string([start]), do: start
  def parser_result_to_string(v) when is_list(v), do: Enum.join(v)
  def parser_result_to_atom([v]), do: String.to_atom(v)

  # private function
  defp op_replace("=" = op), do: string(op) |> replace("==")
  defp op_replace(op), do: string(op)
end
