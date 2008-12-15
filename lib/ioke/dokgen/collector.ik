
DokGen do(
  KindsToAvoid = [Base, DokGen]

  collect = method(
    current, collected, 
    visited set withIdentitySemantics!, 
    idGenerator fn(current, fn(current++)) call(0),

    visited << cell(:current)
    cell(:current) cells each(c,
      unless((KindsToAvoid include?(c value)) || visited include?(c value),
        if(kindName?(c key),
          collected collectedKinds[c value kind] = c value
          collect(c value, collected, visited, idGenerator),

          id = idGenerator call
          if(code?(c value), 
            fname = c value message filename
            (collected collectedFiles[fname] ||= []) << [cell(:current), c key, c value, id])
          (collected collectedCells[c key asText] ||= []) << [cell(:current), c key, c value, id]))))
        
  kindName? = method(name,
    if((#/^[A-Z]/ =~ name) || ([:nil, :true, :false] include?(name)),
      true,
      false))

  code? = method(val,
    ((cell(:val) kind?("DefaultMethod")) || 
      (cell(:val) kind?("LexicalBlock")) ||
      (cell(:val) kind?("DefaultMacro"))))
)
