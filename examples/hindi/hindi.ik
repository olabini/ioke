
HindiDefaultBehavior = Reflector other:mimic(DefaultBehavior)

HindiDefaultBehavior सेल  = cell(:cell)
HindiDefaultBehavior नकल = cell(:mimic)
HindiDefaultBehavior यदि  = cell(:if)
HindiDefaultBehavior विधि   = cell(:method)
HindiDefaultBehavior लैम्ब्डा  = cell(:fn)
HindiDefaultBehavior मूल    = Origin
HindiDefaultBehavior करना    = cell(:do)
HindiDefaultBehavior केसाथ  = cell(:with)
HindiDefaultBehavior स्व  = method(self)
HindiDefaultBehavior प्रिंट  = Origin cell(:print)
HindiDefaultBehavior प्रिंटलाइन = Origin cell(:println)

DefaultBehavior mimic!(HindiDefaultBehavior)
