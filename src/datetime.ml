type t = Ptime.t

let of_string s =
  let open Result.Syntax in
  let* time, _, _ =
    Ptime.of_rfc3339 s
    |> Result.map_error (fun (`RFC3339 (_, err)) ->
      `Msg (Fmt.str "invalid time: %a" Ptime.pp_rfc3339_error err) )
  in
  Ok time

let pp fmt x = (Ptime.pp_human ()) fmt x

let of_yaml yaml =
  (* Logs.debug (fun m -> m "Parsing date: %a" Yaml.pp yaml); *)
  match yaml with
  | `String time -> of_string (String.trim time)
  | _ -> Error (`Msg "could not parse ptime out of yaml")

let to_yaml time = `String (Fmt.str "%a" pp time)
