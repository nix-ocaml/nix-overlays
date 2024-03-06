let test_add () = Alcotest.(check int) "adds numbers" 5 (Package.add 2 3)

let () =
  let open Alcotest in
  run "Package" [ ("numbers", [ test_case "add" `Quick test_add ]) ]
