
use jar = method(jarFile,
  use(if(#/\.jar$/ =~ jarFile,
      jarFile,
      "#{jarFile}.jar")))
