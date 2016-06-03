
(** Conversion of file input from Markdown to Jira
 *)

module MD = Omd
module F  = Format
module C  = Cmdliner

let printf  = Format.printf
let kb      = 1024 * 1024

let finally opn cls =
  let res = try opn () with exn -> cls (); raise exn
  in
    cls ();
    res

let read
  : in_channel -> string
  = fun io ->
  let buf  = Buffer.create (2 * kb) in
  let rec loop io =
    ( Buffer.add_string buf (input_line io)
    ; Buffer.add_char buf '\n'
    ; loop io
    )
  in
   try loop io with End_of_file -> Buffer.contents buf

let read_file
  : string -> string
  = fun name ->
  let io   = open_in name in
  finally
    (fun () -> read io)
    (fun () -> close_in io)

(* [elements] and [element] print Markdown syntax element in
 *  JIRA syntax to [stdout]. *)

let rec elements
  : MD.t -> unit
  = fun es -> List.iter element es

and element
  : MD.element -> unit
  = fun e ->
  let open MD in
  match e with
  | H1 e              -> printf "@.@[h1. "; elements e; printf "@.@]"
  | H2 e              -> printf "@.@[h2. "; elements e; printf "@.@]"
  | H3 e              -> printf "@.@[h3. "; elements e; printf "@.@]"
  | H4 e              -> printf "@.@[h4. "; elements e; printf "@.@]"
  | H5 e              -> printf "@.@[h5. "; elements e; printf "@.@]"
  | H6 e              -> printf "@.@[h6. "; elements e; printf "@.@]"
  | Paragraph e       -> printf "@["      ; elements e; printf "@.@]"
  | Text s            -> printf "%s" s
  | Emph e            -> printf "_"       ; elements e; printf "_"
  | Bold e            -> printf "*"       ; elements e; printf "*"
  | Ul es             -> List.iter (fun e ->
                          printf "@[* "   ; elements e; printf "@.@]") es
  | Ol es             -> List.iter (fun e ->
                          printf "@[# "   ; elements e; printf "@.@]") es
  | Code(_,str)       -> printf "{{%s}}" str
  | Ulp es            -> List.iter (fun e ->
                          printf "@[* "   ; elements e; printf "@.@]") es
  | Olp es            -> List.iter (fun e ->
                          printf "@[# "   ; elements e; printf "@.@]") es
  | Code_block(_,str) -> printf "@.@[{noformat}@.%s@.{noformat}@.@]" str
  | Br                -> printf "\\\\@."
  | NL                -> printf "@."
  | Hr                -> printf "@.----@."
  | Url(href,t,_)     -> printf "["       ; elements t; printf "|%s]" href
  | Raw(str)          -> printf "%s" str
  | Raw_block(str)    -> printf "%s" str
  | Blockquote(t)     -> printf "@.@[bq. "; elements t; printf "@.@]"
  | Img(alt,src,_)    -> printf "!%s|%s!" src alt
  | _                 -> ()

let md2jr
  : string option -> unit
  = fun input ->
  ( match input with
  | Some name -> read_file name
  | None      -> read stdin
  )
  |> MD.of_string
  |> fun es -> F.printf "@["; elements es; F.printf "@.@]"

let main files =
  try
    match files with
    | []    -> md2jr None; `OK()
    | files -> List.iter (fun name -> md2jr (Some name)) files; `OK()
  with
    e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e); `Error()

module CMD = struct
  let files =
    let doc = "markdown files" in
      C.Arg.(value
        & pos_all file []
        & info [] ~docv:"file.md" ~doc)

  let main =
      let doc = "conversion from Markdown to Jira" in
      let man =
        [ `S "DESCRIPTION"
        ; `P "Convert input from Markdown to Jira syntax and 
              emit to stdandard output. Input is read from named
              files or standard input when no file name is given."
        ; `S "BUGS"
        ; `P "Report bug on the github issue tracker"
        ]
      in
        ( C.Term.(const main $ files)
        , C.Term.info "md2jr" ~version:"1.0" ~doc ~man
        )
end

let () =
  match C.Term.eval CMD.main with
  | `Ok(_)      -> exit 0
  | `Error _    -> exit 1
  | _           -> exit 2

