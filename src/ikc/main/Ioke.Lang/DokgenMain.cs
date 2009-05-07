
public class DokgenMain {
    public static void Main(string[] args) {
        string[] newArgs = new string[args.Length+1];
        System.Array.Copy(args, 0, newArgs, 1, args.Length);
        string current = System.Reflection.Assembly.GetExecutingAssembly().Location;
        newArgs[0] = System.IO.Path.Combine(new System.IO.FileInfo(current).Directory.FullName, "dokgen");
        Ioke.Lang.IokeMain.Main(newArgs);
    }
}
