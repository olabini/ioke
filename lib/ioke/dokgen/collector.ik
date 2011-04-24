
DokGen do(
  KindsToAvoid = [DokGen]

  if(System feature?(:java),
    KindsToAvoid << JavaGround)

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

  internal:initISpec = method(
    use("ispec")
    ISpec Runner registerAtExitHook = nil
    ISpec Options shouldRun? = false
    ISpec ispec_options = ISpec Options create(System out, System err)
    ISpec shouldExit? = false
    @internal:initISpec = nil
  )

  lookup = method(segments,
    segments inject(Origin, current, name, cell(:current) cell(name))
  )

  collectSpecsOnly = method(specsPattern, collected,
    internal:initISpec
    FileSystem[specsPattern] each(f, use(f))

    ISpec DescribeContext specs each(spec,
      collectSpec(spec, collected collectedSpecs)
    )

    idGenerator = fn(current, fn(current++)) call(0)

    collected collectedSpecs each(cspec,
      unless(cspec value cell?(:dokgenSpecAlreadyCollected),
        ;; also check cells in the sub thingy

        fixed = false
        segments = cspec key split(" ")
        kindName = "%[%s %]" format(segments[0..-2])[0..-2]

        current = lookup(segments[0...-1])
        c = segments[-1] => lookup(segments)

        if(kindName?(c key),
          collected collectedKinds[c value kind] = [c value, {}],

          id = idGenerator call
          if(code?(c value),
            fname = c value message filename
            (collected collectedFiles[fname] ||= []) << [cell(:current), c key, c value, id])
          (collected collectedCells[c key asText] ||= []) << [cell(:current), c key, c value, id, {}])


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

  collectSpecs = method(specsPattern, collectedSpecs, collected,
    internal:initISpec
    FileSystem[specsPattern] each(f, use(f))

    ISpec DescribeContext specs each(spec,
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
      if(sp mimics?(ISpec DescribeContext),
        collectSpec(sp, collectedSpecs),
        if(sp pending?,
          theList << [sp name],
          if(!(sp mimics?(ISpec PropertyExample)),
            theList << [sp name, sp code])))))
)
