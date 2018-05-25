open Regex_notation

module Funct(A : sig module B = RegexTLM.RelitInternalDefn_regex end) = struct
  module RelitInternalDefn_regex = A.B
end
module X = Funct(struct module B = RegexTLM.RelitInternalDefn_regex end)
open X
let regex =
  raise (RelitInternalDefn_regex.Call ("Forgot ppx...", "a|b|c") [@relit])
let () = print_endline (Regex.show regex)

