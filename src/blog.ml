module Source = struct
  let source_root = Fpath.v "."

  let ( / ) = Fpath.( / )

  let assets ~dir = Path.(dir / "assets")

  let pages ~dir = Path.(dir / "pages")

  let templates ~dir = Path.(dir / "templates")

  let config ~dir = Path.(dir / "_config.yaml")

  let template ~dir path = Path.(templates ~dir / path)

  let as_html into file =
    let _, base = Path.split file |> Option.get in
    let base = Filename.remove_extension base ^ ".html" in
    Path.(into / base)
end

module Target = struct
  let build_dir ~dir = Path.(dir / "_build")

  let site ~dir = Path.(build_dir ~dir / "_html")
end

let create_assets ~dir () =
  Path.iter (Source.assets ~dir) @@ fun curr_dir ->
  match Path.split curr_dir with
  | Some (_, basename) ->
    let new_dir = Path.(Target.site ~dir / basename) in
    Logs.debug (fun m ->
      m "Copying assets: %a -> %a" Path.pp curr_dir Path.pp new_dir );
    Path.mkdirs ~exists_ok:true ~perm:0o755 new_dir;
    Path.copy_directory ~into:new_dir curr_dir
  | None ->
    Logs.warn (fun m ->
      m "Could not determine base directory for asset: %a" Path.pp dir )

let process_markdown file =
  let lines = Path.load file |> String.split_on_char '\n' in
  let meta, content = Meta.parse lines in
  let doc = Cmarkit.Doc.of_string content in
  let html_content = Cmarkit_html.of_doc ~safe:false doc in
  let page_data = Page.of_yaml meta |> Result.get_ok in
  (page_data, html_content)

let render_content ~dir page_data html_content =
  let open Jingoo_build.Types in
  let page_models = Page.models page_data in
  let models = ("content", string html_content) :: page_models in
  let template_file = Source.template ~dir (Page.get_template page_data) in
  Jingoo.Jg_template.from_string ~models @@ Path.load template_file

let render_document ~dir config content page_data =
  let open Jingoo_build.Types in
  let page_models = Page.models page_data in
  let models =
    (("content", string content) :: Config.models config) @ page_models
  in
  let template_file = Source.template ~dir "document.html" in
  Jingoo.Jg_template.from_string ~models @@ Path.load template_file

let create_page ~dir ?target_dir (config : Config.t) file =
  let target_dir =
    match target_dir with
    | None -> Target.site ~dir
    | Some target_dir -> target_dir
  in
  let target_file = Source.as_html target_dir file in
  Logs.debug (fun m -> m "creating page: %a" Path.pp target_file);
  let page_data, html_content = process_markdown file in
  let content = render_content ~dir page_data html_content in
  let document = render_document ~dir config content page_data in
  Path.save ~create:(`If_missing 0o644) target_file document;
  (page_data, target_file)

let create_pages ~dir config () =
  Path.iter Path.(dir / "pages") @@ fun path ->
  let _, basename = Path.split path |> Option.get in
  if Path.is_file path && Filename.check_suffix basename "md" then
    ignore (create_page ~dir config path)

let create_posts ~dir ~target_dir config =
  let posts = ref [] in
  Path.iter
    Path.(dir / "blog" / "posts")
    (fun path ->
      let _, basename = Path.split path |> Option.get in
      if Path.is_file path && Filename.check_suffix basename "md" then
        let post = create_page ~dir ~target_dir config path in
        posts := post :: !posts );
  !posts

let create_blog_index ~dir ~target_dir config posts =
  let blog_index = Path.(dir / "blog" / "index.md") in
  let target_file = Source.as_html target_dir blog_index in
  let page_data, html_content = process_markdown blog_index in
  let models =
    let open Jingoo_build.Types in
    List.map
      (fun (page_data, path) ->
        let page_models = Page.models page_data in
        let _, post_path = Path.split path |> Option.get in
        let page_models =
          ("url", string (Filename.concat "/blog" post_path)) :: page_models
        in
        obj page_models )
      posts
  in
  let models = Jingoo_build.Types.[ ("posts", list models) ] in
  let html_content = Jingoo.Jg_template.from_string ~models html_content in
  let content = render_content ~dir page_data html_content in
  let document = render_document ~dir config content page_data in
  Path.save ~create:(`If_missing 0o644) target_file document

let create_blog ~dir config () =
  let target_dir = Path.(Target.site ~dir / "blog") in
  Path.mkdirs ~exists_ok:true ~perm:0o755 target_dir;
  let posts = create_posts ~dir ~target_dir config in
  create_blog_index ~dir ~target_dir config posts

let init () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug)

let build () =
  let open Result.Syntax in
  Eio_main.run @@ fun env ->
  init ();
  let dir = Eio.Stdenv.cwd env in
  let+ config = Config.from_file (Source.config ~dir) in
  Logs.debug (fun m -> m "using config:@; %a" Config.pp config);
  Eio.Fiber.all
    [ create_assets ~dir; create_pages ~dir config; create_blog ~dir config ]
