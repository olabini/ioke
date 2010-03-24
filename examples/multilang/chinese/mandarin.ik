
MandarinDefaultBehavior = Reflector other:mimic(DefaultBehavior)

MandarinDefaultBehavior 细胞  = cell(:cell)
MandarinDefaultBehavior 摹拟 = cell(:mimic)
MandarinDefaultBehavior 除非  = cell(:if)
MandarinDefaultBehavior 法   = cell(:method)
MandarinDefaultBehavior 函数  = cell(:fn)
MandarinDefaultBehavior 本    = Origin
MandarinDefaultBehavior 做    = cell(:do)
MandarinDefaultBehavior 带有  = cell(:with)
MandarinDefaultBehavior 自我  = method(self)
MandarinDefaultBehavior 打印  = Origin cell(:print)
MandarinDefaultBehavior 打印行 = Origin cell(:println)

DefaultBehavior mimic!(MandarinDefaultBehavior)
