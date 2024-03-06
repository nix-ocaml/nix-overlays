let main () =
  print_string "First number: ";
  let first = read_line () |> int_of_string_opt in
  print_string "Second number: ";
  let second = read_line () |> int_of_string_opt in
  let output =
    match (first, second) with
    | None, Some _ -> "First input is not a number"
    | Some _, None -> "Second input is not a number"
    | None, None -> "Neither of the inputs is a number"
    | Some f, Some s ->
        let number = Package.add f s in
        Printf.sprintf "%i + %i = %i" f s number
  in
  print_endline output
;;

main ()