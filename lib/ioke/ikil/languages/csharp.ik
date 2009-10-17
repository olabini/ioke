
IKIL Language CSharp = IKIL Language mimic

IKIL Language CSharp createFile = method(name, dir, content,
  fullDir = "#{dir}/Ioke.Lang"
  FileSystem ensureDirectory(fullDir)
  FileSystem withOpenFile("#{fullDir}/#{name}.cs", fn(f, f print(content)))
)

IKIL Language CSharp defineSimpleIokeObject = method(name, parent,
  "
namespace Ioke.Lang {
    public class #{name} {
        public static void Init(IokeObject obj) {
          Runtime runtime = obj.runtime;
          obj.Kind = \"#{name}\";
          obj.MimicsWithoutCheck((IokeObject)runtime.IokeGround.GetCell(null, null, \"#{parent}\"));
          runtime.IokeGround.RegisterCell(\"#{name}\", obj);
       }
    }
}
"
)
