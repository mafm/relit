open Regex_example;

open Test_example.Test_notation;
let x = "hi there";
module Std = {
  /* should not matter */
  let unique = () => 0;
};
let out = $extlib_nodep `(module)`;
let () = print_endline(out);
