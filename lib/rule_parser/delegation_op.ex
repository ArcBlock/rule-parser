defmodule RuleParser.DelegationOp do
  require RuleParser.Gen
  import NimbleParsec
  import RuleParser.Helper

  RuleParser.Gen.create(["itx", "state"])
end
