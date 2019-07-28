defmodule RuleParser.Common do
  @moduledoc """
  parse common expression
  """
  require RuleParser.Gen
  import NimbleParsec
  import RuleParser.Helper

  RuleParser.Gen.create([])
end
