
if(System feature?(:java),

JavaGround notice  = "JavaGround"
JavaGround inspect = "JavaGround"

JavaGround java:lang:Class = JavaGround primitiveJavaClass!("java.lang.Class")
JavaGround java:lang:Object = JavaGround primitiveJavaClass!("java.lang.Object")
JavaGround java:lang:String = JavaGround primitiveJavaClass!("java.lang.String")
JavaGround java:lang:Integer = JavaGround primitiveJavaClass!("java.lang.Integer")
JavaGround java:lang:Short = JavaGround primitiveJavaClass!("java.lang.Short")
JavaGround java:lang:Byte = JavaGround primitiveJavaClass!("java.lang.Byte")
JavaGround java:lang:Boolean = JavaGround primitiveJavaClass!("java.lang.Boolean")
JavaGround java:lang:Character = JavaGround primitiveJavaClass!("java.lang.Character")
JavaGround java:lang:Long = JavaGround primitiveJavaClass!("java.lang.Long")
JavaGround java:lang:Float = JavaGround primitiveJavaClass!("java.lang.Float")
JavaGround java:lang:Double = JavaGround primitiveJavaClass!("java.lang.Double")
JavaGround java:lang:reflect:Array = JavaGround primitiveJavaClass!("java.lang.reflect.Array")

JavaGround java:byte  =      java:lang:Byte field:TYPE
JavaGround java:short =     java:lang:Short field:TYPE
JavaGround java:char  = java:lang:Character field:TYPE
JavaGround java:int   =   java:lang:Integer field:TYPE
JavaGround java:long  =      java:lang:Long field:TYPE
JavaGround java:boolean = java:lang:Boolean field:TYPE
JavaGround java:float  =    java:lang:Float field:TYPE
JavaGround java:double =   java:lang:Double field:TYPE

JavaGround java:lang:String asText = JavaGround cell("primitiveMagic: String->Text")
JavaGround java:lang:Integer asRational = JavaGround cell("primitiveMagic: Integer->Rational")
JavaGround java:lang:Byte asRational = JavaGround cell("primitiveMagic: Byte->Rational")
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

JavaGround JavaArrayProxyCreator = Origin mimic do(
  initialize = method(componentType, dimensions,
    @componentType = componentType
    @dimensions    = dimensions
  )

  new = method(createPrimitiveJavaArray!(componentType, *dimensions))

  [] = method(dimension,
    JavaArrayProxyCreator mimic(componentType, dimensions + nil[dimension])
  )
)

JavaGround java:lang:Class [] = method(dimension nil,
  ; if dimension is nil, we want the class, otherwise we want a proxy creator
  if(dimension,
    JavaArrayProxyCreator mimic(self, nil[dimension]),
    dimension = 0
    clz = self
    while(clz class:array?,
      dimension++
      clz = clz:componentType)

    baseType = if(clz class:array?,
      clz class:componentType,
      clz)
    
    dimension++
    dims = list()
    dimension times(dims << 0)
    createPrimitiveJavaArray!(baseType, *dims) class
  )
)

JavaGround JavaArray each = dmacro(
  [code]
  (0...self length) each(n, code evaluateOn(call ground, self[n]))
  self,

  [argName, code]
  lexical = call LexicalBlock createFrom(call list(argName, code), call ground)
  (0...self length) each(n, lexical call(self[n]))
  self,

  [indexName, argName, code]
  lexical = call LexicalBlock createFrom(call list(indexName, argName, code), call ground)
  (0...self length) each(n, lexical call(n, self[n]))
  self)

JavaGround pass = macro(
  ; JavaGround really doesn't have access to much, so we scope every call to anything inside "call"
  ; this means scoping even calls to internal:createText
  ; hopefully these things shouldn't be necessary in many places.
  call bind(call rescue(call Condition, call fn(c, call message sendTo(call IokeGround))),
    val = primitiveJavaClass!(call message name asText replaceAll(call ":", call "."))
    self cell(call message name) = val
    val)
)

JavaGround cell(:pass) applicable? = method(msg,
  bind(rescue(Condition, fn(c, false)),
    primitiveJavaClass!(msg name asText replaceAll(":","."))
    true))

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


cell(:LexicalBlock) java:coerceCode = method(javaType, abstractNames,
  proxy = integrate(javaType) mimic
  outerSelf = self
  abstractNames each(name,
    proxy cell(name) = fnx(+rest, +:krest, cell(:outerSelf) call(*rest, *krest))
  )
  proxy new
)

)
