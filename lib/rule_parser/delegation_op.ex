defmodule RuleParser.DelegationOp do
  @moduledoc """
  parse delegation expression
  """
  require RuleParser.Gen
  import NimbleParsec
  import RuleParser.Helper

  RuleParser.Gen.create(["itx", "state"])
end
