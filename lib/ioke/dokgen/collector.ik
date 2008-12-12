
DokGen do(
  collect = method(
    current, collectedFiles, collectedKinds, collectedCells, 
    visited set withIdentitySemantics!, 
    idGenerator fn(current, fn(current++)) call(0),

    visited << cell(:current)
    cell(:current) cells each(c,
      unless((Base == c value) || visited include?(c value),
        if(kindName?(c key),
          collectedKinds[c value kind] = c value,

          id = idGenerator call
          if(code?(c value), 
            fname = c value message filename
            (collectedFiles[fname] ||= []) << [cell(:current), c key, c value, id])
          (collectedCells[c key asText] ||= []) << [cell(:current), c key, c value, id]
        )
        
        collect(c value, collectedFiles, collectedKinds, collectedCells, visited, idGenerator))))
        
  kindName? = method(name,
    if(#/^[A-Z]/ =~ name,
      true,
      false))

  code? = method(val,
    ((cell(:val) kind?("DefaultMethod")) || 
      (cell(:val) kind?("LexicalBlock")) ||
      (cell(:val) kind?("DefaultMacro"))))
)
