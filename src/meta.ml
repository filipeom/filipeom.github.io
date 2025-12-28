let parse lines =
  let in_metadata = ref false in
  let rec loop (meta, content) = function
    | [] -> (meta, content)
    | line :: remaining ->
      if String.starts_with ~prefix:"---" line then begin
        in_metadata := not !in_metadata;
        loop (meta, content) remaining
      end
      else begin
        let acc =
          if !in_metadata then (line :: meta, content)
          else (meta, line :: content)
        in
        loop acc remaining
      end
  in
  let meta, content = loop ([], []) lines in
  let meta =
    String.concat "\n" (List.rev meta) |> Yaml.of_string |> Result.get_ok
  in
  let content = String.concat "\n" @@ List.rev content in
  (meta, content)
