
Origin around(:mimic) << method(+rest, +:krest, 
  newMimic = aspectCall
  if(newMimic cell?(:initialize),
    newMimic initialize(*rest, *krest))
  newMimic)
