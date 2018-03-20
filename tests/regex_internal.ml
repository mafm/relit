module Regex = struct 
  type t = AnyChar | Str of string | Seq of t * t | Or of t * t | Star of t
end

(* TODO separate into menhir files *)
module RegexLexer = struct end
module RegexParser = struct end 

(* 
module RegexNotation = {
  notation $regex at Regex.t {
    lexer RegexLexer;
    parser RegexParser;
    expansions require
      module Regex as Regex;
  };
};
*)


module RegexNotation = struct
  module RelitInternalDefn_regex = struct
    type t = Regex.t
    module Lexer = RegexLexer
    module Parser = RegexParser (* assume starting non-terminal is called start *)
    module Dependencies = struct
      module Regex = Regex
    end
    exception Call of (* error message *) string * (* body *) string
  end
end

(* 
module Test1 = {
  open RegexNotation;
  module DNA = {
    let any_base = $regex `(A|T|G|C)`
  };
};
*)

module Test1 = struct
  open RegexNotation
  module DNA = struct
    module RelitInternalDefn = RelitInternalDefn_regex
    let any_base =
      raise (RelitInternalDefn.Call
        ("Forgot ppx...",
        "A|T|G|C"))
  end
end
