
IKIL Language Java = IKIL Language mimic

IKIL Language Java createFile = method(name, dir, content,
  fullDir = "#{dir}/ioke/lang"
  FileSystem ensureDirectory(fullDir)
  FileSystem withOpenFile("#{fullDir}/#{name}.java", fn(f, f print(content)))
)

IKIL Language Java defineSimpleIokeObject = method(name, parent,
  "
package ioke.lang;

import ioke.lang.exceptions.ControlFlow;

public class #{name} {
    public static void init(IokeObject obj) throws ControlFlow {
        Runtime runtime = obj.runtime;
        obj.setKind(\"#{name}\");
        obj.mimicsWithoutCheck((IokeObject)runtime.iokeGround.getCell(null, null, \"#{parent}\"));
        runtime.iokeGround.registerCell(\"#{name}\", obj);
    }
}
"
)
