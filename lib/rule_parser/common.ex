defmodule RuleParser.Common do
  require RuleParser.Gen
  import NimbleParsec
  import RuleParser.Helper

  RuleParser.Gen.create([])
end
