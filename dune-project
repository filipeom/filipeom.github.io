(lang dune 3.20)

(generate_opam_files true)

(source
 (github filipeom/blogger))

(authors "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(maintainers "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(license "MIT")

(package
 (name blogger)
 (synopsis
  "A direct-style concurrency static blog generator for OCaml using Eio.")
 (depends
  dune
  cmdliner
  (ocaml
   (>= "5.4.0"))
  eio
  eio_main
  bos
  cmdliner
  cmarkit
  fpath
  logs
  jingoo
  yaml
  ppx_deriving
  ppx_deriving_yaml))
