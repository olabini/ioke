
JavaGround java:lang:Class = JavaGround primitiveJavaClass!("java.lang.Class")
JavaGround java:lang:String = JavaGround primitiveJavaClass!("java.lang.String")

JavaGround java:lang:String asText = method(internal:createText(self))

JavaGround java:lang:Class name = method(
  self getName asText replaceAll(".", ":")
)
