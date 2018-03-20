
(* This file first defines a transformations on typed trees,
 * then an ppx ast_mapper that calls this transformation by
 * doing some typechecking trickery. *)

let ppx_name = "relit"

open Migrate_parsetree
open OCaml_404.Ast
open Ast_mapper
open Parsetree

open Typedtree
open Asttypes

module To_current = Convert(OCaml_404)(OCaml_current)

module TypedMap = TypedtreeMap.MakeMap(struct
    include TypedtreeMap.DefaultMapArgument
    let enter_module_expr module_expr =
      let mod_desc = match module_expr.mod_desc with
        | Tmod_ident (path, _loc)
          when
            (Path.last path
            |> String.split_on_char '_'
            |> List.hd) = "RelitInternalDefn"
          ->
          prerr_endline (Path.name path);
          module_expr.mod_desc
        | e -> e
      in
      { module_expr with mod_desc }
  end)

let ppx_mapper _config _cookies =
  let structure_mapper _x structure =

    (* enable this to run against any ast version if it can *)
    let current_structure = To_current.copy_structure structure in

    (* useful definitions for the remaining part *)
    let loc = (List.hd structure).pstr_loc in
    let fname = loc.Location.loc_start.Lexing.pos_fname in
    let without_extension = Filename.remove_extension fname in

    (* initialize the typechecking environment *)
    Compmisc.init_path false;
    let module_name = Compenv.module_of_filename
      Format.err_formatter fname without_extension in
    Env.set_unit_name module_name;
    let initial_env = Compmisc.initial_env () in

    (* typecheck the structure *)
    let typed = Typemod.type_implementation
        fname without_extension module_name initial_env current_structure in

    (* run our mapper against the typed tree *)
    let mapped_typed = TypedMap.map_structure (fst typed) in
    (* Printtyped.implementation Format.err_formatter mapped_typed; *)

    structure
  in
  { default_mapper with structure = structure_mapper }

let () =
  Driver.register ~name:ppx_name (module OCaml_404) ppx_mapper
