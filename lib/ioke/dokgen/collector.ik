
DokGen do(
  KindsToAvoid = [DokGen, JavaGround]

  collect = method(
    current, collected, 
    visited set,
    idGenerator fn(current, fn(current++)) call(0),

    cell(:current) cells each(c,
      unless((KindsToAvoid include?(c value)),
        if(kindName?(c key),
          if(!(visited include?(c value kind)),
            visited << c value kind
            collected collectedKinds[c value kind] = [c value, {}]
            collect(c value, collected, visited, idGenerator)),

          id = idGenerator call
          if(code?(c value), 
            fname = c value message filename
            (collected collectedFiles[fname] ||= []) << [cell(:current), c key, c value, id])
          (collected collectedCells[c key asText] ||= []) << [cell(:current), c key, c value, id, {}]))))
        
  kindName? = method(name,
    if((#/^[A-Z]/ =~ name) || ([:nil, :true, :false] include?(name)),
      true,
      false))

  code? = method(val,
    ((cell(:val) kind?("DefaultMethod")) || 
      (cell(:val) kind?("LexicalBlock")) ||
      (cell(:val) kind?("DefaultMacro")) ||
      (cell(:val) kind?("LexicalMacro")) ||
      (cell(:val) kind?("DefaultSyntax"))))

  collectSpecs = method(specsPattern, collectedSpecs, collected,
    use("ispec")

    ISpec Options shouldRun? = false
    ISpec shouldExit? = false

    FileSystem[specsPattern] each(f, use(f))

    ISpec specifications each(spec,
      collectSpec(spec, collectedSpecs)
    )

    collectedSpecs each(cspec,
      unless(cspec value cell?(:dokgenSpecAlreadyCollected),
        ;; also check cells in the sub thingy

        fixed = false
        segments = cspec key split(" ")
        kindName = "%[%s %]" format(segments[0..-2])[0..-2]

        cellForSegment = collected collectedCells[segments[-1]]
        if(cellForSegment,
          place = cellForSegment find(x, (x[0] kind == kindName) || ((x[0] kind == "Ground") && kindName == "") || ((x[0] kind == "IokeGround") && kindName == ""))

          if(place,
            place[4][cspec key] = cspec value
            cspec value dokgenSpecAlreadyCollected = true
            fixed = true
          )
        )

        segments = segments[0..-2]

        cellForKind = collected collectedKinds[cspec key]
        if(cellForKind,
          cellForKind[1][cspec key] = cspec value
          cspec value dokgenSpecAlreadyCollected = true
          fixed = true
        )

        while(!fixed && (segments length > 0),
          kindName = "%[%s %]" format(segments)[0..-2]
          kindNameX = "%[%s %]" format(segments[0..-2])[0..-2]

          cellForSegment = collected collectedCells[segments[-1]]
          if(cellForSegment,
            place = cellForSegment find(x, (x[0] kind == kindNameX) || ((x[0] kind == "Ground") && kindNameX == ""))

            if(place,
              place[4][cspec key] = cspec value
              cspec value dokgenSpecAlreadyCollected = true
              fixed = true
            )
          )

          unless(fixed,
            cellForKind = collected collectedKinds[kindName]

            if(cellForKind,
              cellForKind[1][cspec key] = cspec value
              cspec value dokgenSpecAlreadyCollected = true
              fixed = true
            )
          )

          segments = segments[0..-2]
        )
      )
    )
  )

  collectSpec = method(spec, collectedSpecs,
    theList = (collectedSpecs[spec fullName] ||= [])

    spec specs each(sp,
      if(sp[0] == :description,
        collectSpec(sp[1], collectedSpecs),
        if(sp[0] == :test,
          theList << [sp[1], sp[2]],
          theList << [sp[1]]))))
)
