module Types = struct
  let option f v = match v with None -> Jingoo.Jg_types.Tnull | Some v -> f v

  let string s = Jingoo.Jg_types.Tstr s

  let ptime s = Jingoo.Jg_types.Tstr (Fmt.str "%a" Datetime.pp s)

  let list l = Jingoo.Jg_types.Tlist l

  let obj fields = Jingoo.Jg_types.Tobj fields
end
