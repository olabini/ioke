
JavaGround notice  = "JavaGround"
JavaGround inspect = "JavaGround"

JavaGround java:lang:Class = JavaGround primitiveJavaClass!("java.lang.Class")
JavaGround java:lang:Object = JavaGround primitiveJavaClass!("java.lang.Object")
JavaGround java:lang:String = JavaGround primitiveJavaClass!("java.lang.String")
JavaGround java:lang:Integer = JavaGround primitiveJavaClass!("java.lang.Integer")
JavaGround java:lang:Short = JavaGround primitiveJavaClass!("java.lang.Short")
JavaGround java:lang:Character = JavaGround primitiveJavaClass!("java.lang.Character")
JavaGround java:lang:Long = JavaGround primitiveJavaClass!("java.lang.Long")
JavaGround java:lang:Float = JavaGround primitiveJavaClass!("java.lang.Float")
JavaGround java:lang:Double = JavaGround primitiveJavaClass!("java.lang.Double")

JavaGround java:lang:String asText = JavaGround cell("primitiveMagic: String->Text")
JavaGround java:lang:Integer asRational = JavaGround cell("primitiveMagic: Integer->Rational")
JavaGround java:lang:Short asRational = JavaGround cell("primitiveMagic: Short->Rational")
JavaGround java:lang:Character asRational = JavaGround cell("primitiveMagic: Character->Rational")
JavaGround java:lang:Long asRational = JavaGround cell("primitiveMagic: Long->Rational")
JavaGround java:lang:Float asDecimal = JavaGround cell("primitiveMagic: Float->Decimal")
JavaGround java:lang:Double asDecimal = JavaGround cell("primitiveMagic: Double->Decimal")

JavaGround java:lang:Object inspect = method(
  if(self class?,
    self class:toString asText,
    self toString asText))

JavaGround java:lang:Object notice  = method(
  if(self class?,
    self class:toString asText,
    self toString asText))

JavaGround java:lang:Class class:name = method(
  class:getName asText replaceAll(".", ":")
)

JavaGround pass = macro(
  bind(rescue(Condition, fn(c, call message sendTo(Ground))),
    val = primitiveJavaClass!(call message name asText replaceAll(":", "."))
    JavaGround cell(call message name) = val
    val)
)

JavaGround import = method(+rest, +:krest,
  case(rest length,
    0, nil,
    1,
    name = rest[0] class:name split(":") last
    unless(self cell?(name),
      self cell(name) = rest[0]),
    else, 
    packageName = rest[0] asText
    rest[1..-1] each(cName,
      unless(self cell?(cName),
        self cell(cName) = primitiveJavaClass!("#{packageName}:#{cName}" replaceAll(":", ".")))))

  krest each(im,
    unless(self cell?(im key),
      self cell(im key) = im value)))

