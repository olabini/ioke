
JavaGround java:lang:Class = JavaGround primitiveJavaClass!("java.lang.Class")

JavaGround java:lang:Class name = method(
  "calling name: #{self getName}" println
  self getName replaceAll(".", ":")
)
