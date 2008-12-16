
DokGen do(
  KindsToAvoid = [DokGen]

  collect = method(
    current, collected, 
    visited set,
    idGenerator fn(current, fn(current++)) call(0),

    cell(:current) cells each(c,
      unless((KindsToAvoid include?(c value)),
        if(kindName?(c key),
          if(!(visited include?(c value kind)),
            visited << c value kind
            collected collectedKinds[c value kind] = c value
            collect(c value, collected, visited, idGenerator)),

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

  collectSpecs = method(specsPattern, collectedSpecs,
    use("ispec")

    ISpec shouldRun? = false
    ISpec shouldExit? = false

    FileSystem[specsPattern] each(f, use(f))

    ISpec specifications each(spec,
      collectSpec(spec, collectedSpecs)
    )
  )

  collectSpec = method(spec, collectedSpecs,
    theList = (collectedSpecs[spec fullName] ||= [])

    spec specs each(sp,
      if(sp[0] == :description,
        collectSpec(sp[1], collectedSpecs),
        theList << sp[1])))
)
