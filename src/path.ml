include Eio.Path

let rec iter ?(recurse = false) dir f =
  with_open_dir dir @@ fun dir ->
  let files = read_dir dir in
  Eio.Fiber.List.iter
    (fun file ->
      let path = dir / file in
      f path;
      if recurse && Eio.Path.is_directory path then iter path f )
    files

(** Byte copy of a file *)
let copy_file src dst =
  with_open_in src @@ fun ic ->
  with_open_out ~create:(`If_missing 0o644) dst @@ fun oc -> Eio.Flow.copy ic oc

(** Moves the contents of a directory into another *)
let copy_directory ~into source =
  iter source @@ fun file ->
  let _, basename = split file |> Option.get in
  let new_file = into / basename in
  Logs.debug (fun m -> m "mv %a %a" pp file pp new_file);
  copy_file file new_file
