defmodule RuleParser.Gen do
  @moduledoc """
  Documentation for Parser.
  """
  import NimbleParsec
  import RuleParser.Helper

  # tag := ascii_tag_with_space([?a..?z])
  # single_value := string_with_quote | integer | atom_with_space
  # list_value := [ single_value | single_value , single_value ]
  # value := single_value | list_value

  # op0 := + | - | *
  # op1 := == | != | in | not in
  # op2 := < | <= | > | >=
  # op3 := and | or

  # cond1 := ( tag op1 value )
  # cond2 := ( tag op2 integer )
  # cond3 := ( tag op0 tag op2 integer)

  # sub_expr := ( cond1 | cond2 | cond3)
  # expr := sub_expr op3 expr | sub_expr

  defmacro create(
             prefix,
             op0 \\ ["+", "-", "*"],
             op1 \\ ["==", "!=", "in", "not in"],
             op2 \\ ["<=", "<", ">=", ">"],
             op3 \\ ["and", "or"]
           ) do
    quote do
      tag =
        ignore_prefix(unquote(prefix))
        |> concat(parse_tag())
        |> reduce({:parser_result_to_atom, []})

      single_value = choice([parse_string(), parse_integer(), parse_atom()])

      defcombinatorp(
        :list_entries,
        choice([
          single_value
          |> concat(ignore_space())
          |> concat(ignore_sep(","))
          |> concat(ignore_space())
          |> concat(parsec(:list_entries)),
          single_value,
          empty()
        ])
      )

      list_value =
        ignore(string("["))
        |> concat(ignore_space())
        |> parsec(:list_entries)
        |> concat(ignore_space())
        |> ignore(string("]"))
        |> reduce({Enum, :uniq, []})

      value = choice([single_value, list_value]) |> unwrap_and_tag(:v)
      op0 = parse_ops(unquote(op0)) |> reduce({:parser_result_to_atom, []})
      op1 = parse_ops(unquote(op1)) |> reduce({:parser_result_to_atom, []})
      op2 = parse_ops(unquote(op2)) |> reduce({:parser_result_to_atom, []})
      op3 = parse_ops(unquote(op3)) |> reduce({:parser_result_to_atom, []})

      cond1 =
        tag |> concat(ignore_space()) |> concat(op1) |> concat(ignore_space()) |> concat(value)

      cond2 =
        tag
        |> concat(ignore_space())
        |> concat(op2)
        |> concat(ignore_space())
        |> concat(parse_integer())

      cond3 =
        tag
        |> concat(ignore_space())
        |> concat(op0)
        |> concat(ignore_space())
        |> concat(tag)
        |> concat(ignore_space())
        |> concat(op2)
        |> concat(ignore_space())
        |> concat(parse_integer())

      sub_expr = ignore_bracket(?\(, choice([cond1, cond2, cond3]), ?\))

      defcombinatorp(
        :expr,
        choice([
          sub_expr
          |> concat(ignore_space())
          |> concat(op3)
          |> concat(ignore_space())
          |> concat(ignore_bracket(?\(, parsec(:expr), ?\)))
          |> tag(:expr),
          sub_expr
        ])
      )

      defparsec(:parse_atom, parse_atom())
      defparsec(:parse_quoted_string, parse_string())
      defparsec(:parse_value, value)
      defparsec(:parse_expr, sub_expr)

      # the parser that actually used
      defparsec(:parse, parsec(:expr))
    end
  end
end
