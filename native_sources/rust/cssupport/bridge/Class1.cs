using System.Runtime.InteropServices;

namespace bridge;


public class Class1
{
    [UnmanagedCallersOnly(EntryPoint = "Foo")]
    public static int Foo(int a)
    {
        return a + 10;
    }

}
