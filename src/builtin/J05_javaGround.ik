
JavaGround java:lang:Class = JavaGround primitiveJavaClass!("java.lang.Class")
JavaGround java:lang:Object = JavaGround primitiveJavaClass!("java.lang.Object")
JavaGround java:lang:String = JavaGround primitiveJavaClass!("java.lang.String")
JavaGround java:lang:Integer = JavaGround primitiveJavaClass!("java.lang.Integer")

JavaGround java:lang:String asText = JavaGround cell("primitiveMagic: String->Text")
JavaGround java:lang:Integer asRational = JavaGround cell("primitiveMagic: Integer->Rational")

JavaGround java:lang:Object inspect = method(self toString asText)
JavaGround java:lang:Object notice  = method(self toString asText)

JavaGround java:lang:Class name = method(
  self getName asText replaceAll(".", ":")
)

JavaGround pass = macro(
  bind(rescue(Condition, fn(c, call message sendTo(Ground))),
    val = primitiveJavaClass!(call message name asText replaceAll(":", "."))
    JavaGround cell(call message name) = val
    val)
)
