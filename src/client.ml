open Bv;;
open Yojson.Safe;;
open Int64;;
open Contest_api;;

module OrderedInt =
  struct
    type t = int
    let compare = Pervasives.compare
  end;;

module BySize = Map.Make(OrderedInt);;

let read_problems () = 
  let problems = from_file "problems.json" in
  let arr = match problems with
    `List x -> x
  | _ -> [] in
  let size problem = 
    let size_json = match problem with
      `Assoc (xs) -> List.find (function (key, x) -> key = "size") xs
    | _ -> ("size", `Null) in
    match size_json with
      (_, `Int i) -> i
    | _ -> 0 in
  let increment map problem =
    let problem_size = size problem in
    if BySize.mem problem_size map
    then BySize.add problem_size ((BySize.find problem_size map) + 1) map
    else BySize.add problem_size 1 map in
  List.fold_left increment (BySize.empty) arr 
;;


(* create 256 random arguments *)
let gen_arguments () =
  Array.map (fun a -> Random.int64 max_int) (Array.init 255 (fun i -> i))
;;

let answers_equal answers1 answers2 =
  let equal = ref true in
  Array.iteri (fun i e -> if e != answers2.(i) then equal := false) answers1;
  !equal
;;


let pregen_arguments = gen_arguments () ;;

let args_hex = Array.map (fun a -> Printf.sprintf "0x%LX" a) pregen_arguments;;

let generic_solver answers arguments programs =
  let output = Array.map (fun p -> Array.map (eval p) arguments) programs in
(*
  let hey = Array.iter (fun x -> print_endline (Int64.to_string x)) output.(12) in
  let hey1 = print_endline "======================"; print_newline (); print_newline () in
  let hey2 = Array.iter (fun x -> print_endline (Int64.to_string x)) answers in
*)
  let solution = ref [] in 
  Array.iteri (fun i p -> if answers_equal answers output.(i) then solution := (p::(!solution))) programs;
  !solution
;;

let solver answers programs =
  generic_solver answers pregen_arguments programs
;;

let resolver size answers arguments programs =
  generic_solver answers arguments (Array.of_list programs)
;;
(*
let solve_loop =
  let get_answers 
  solver
*)

let print_problem_stats () =
  let problems_by_size = read_problems () in
  BySize.iter (fun size count -> print_int size; print_string ":"; print_int count; print_newline ()) problems_by_size
;;

let print_sample_search_results () =
  print_int (List.length (gen_pseudo 11 true false false));
  print_newline ();
  print_int (List.length (gen_pseudo 11 false true false));
  print_newline ();
  print_int (List.length (gen_pseudo 11 true true false));
  print_newline ();
  print_int (List.length (gen_pseudo 11 true false true));
  print_newline ();
  print_int (List.length (gen_pseudo 11 false false true));
  print_newline ();
;;

let test_equal () =
  if (answers_equal [|1;2;3|] [|1;2;3|]) then print_endline "True" else print_endline "False"
;;
  

let main () =
  let problem = get_training_problem 7 in
  let ops = problem.operators in
  let programs = gen_programs_all problem.size ops.op1 ops.op2 ops.if0 ops.fold ops.tfold in
  let answers = evaluate problem.id args_hex in
  let solution = solver answers programs in
  print_int (List.length solution);
  print_newline ();
  print_int (Array.length programs);
  print_newline ();
  List.iter (fun p -> print_string (program_to_string p); print_newline ()) solution;
;;

main ();;

