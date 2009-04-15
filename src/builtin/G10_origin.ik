
Origin around(:mimic) << method(+rest, +:krest, 
  newMimic = aspectCall
  if(newMimic cell?(:initialize),
    newMimic initialize(*rest, *krest))
  newMimic)

Origin eval = method("Takes some Text and evaluates it as Ioke source in the context of the receiver",
  source, 
  Message fromText(source) evaluateOn(self))
