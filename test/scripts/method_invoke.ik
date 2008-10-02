test1 = method(
  asString println
  "from test1" println)

test1
test1
Ground test1
Origin test1
nil test1
"foo" test1

one = Origin mimic
two = Origin mimic

one something = "one something"
two somethingElse = "two somethingElse"

one meth = method(something println)
two meth = method(
  somethingElse println
  test1)

one meth
two meth
