words = method(text, #/[a-z]+/ allMatches(text lower))

train = method(features,
  features fold({} withDefault(1), model, f, model[f] += 1. model))

NWORDS = train(words(FileSystem readFully("small.txt")))

alphabet = "abcdefghijklmnopqrstuvwxyz" split("")[1..-1]

edits1 = method(word,
  s = for(i <- 0..(word length + 1), [word[0...i], word[i..-1]])
  set(*for(ab <- s, ab[0] + ab[1][1..-1]), ;deletes
      *for(ab <- s[0..-2], ab[0] + ab[1][1..1] + ab[1][0..0] + ab[1][2..-1]), ;transposes
      *for(ab <- s, c <- alphabet, ab[0] + c + ab[1][1..-1]), ;replaces
      *for(ab <- s, c <- alphabet, ab[0] + c + ab[1]))) ;inserts

knownEdits2 = method(word, for:set(e1 <- edits1(word), e2 <- edits1(e1), NWORDS key?(e2), e2))

known = method(words, for:set(w <- words, NWORDS key?(w), w))

correct = method(word,
  candidates = known([word]) ifEmpty(known(edits1(word)) ifEmpty(knownEdits2(word) ifEmpty([word])))
  candidates sortBy(x, NWORDS[x]) last)

