type author =
  { email : string option
  ; orcid : string option
  ; scholar : string option
  ; github : string option
  ; linkedin : string option
  }
[@@deriving make, show, yaml]

let models_author (author : author) =
  Jingoo_build.Types.
    [ ("email", option string author.email)
    ; ("orcid", option string author.orcid)
    ; ("scholar", option string author.scholar)
    ; ("github", option string author.github)
    ; ("linkedin", option string author.linkedin)
    ]

type t = { author : author } [@@deriving make, show, yaml]

let entity_name = "Config"

let neutral = Ok (make ~author:(make_author ()))

let models config =
  Jingoo_build.Types.[ ("author", obj (models_author config.author)) ]

let from_file file =
  let open Result.Syntax in
  let content = Eio.Path.load file in
  let* yaml = Yaml.of_string content in
  of_yaml yaml
