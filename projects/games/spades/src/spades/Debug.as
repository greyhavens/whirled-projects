package spades {

/** Debugging utilities. */
public class Debug
{
    /** Function for printing debug information. The function accepts a string and appends a line 
     *  break. A static variable is used so that the function can be overridden once a GameControl
     *  is constructed. */
    public static var debug :Function = defaultDebugPrint;
    
    /** Basic flash native printing for use prior to overriding. */
    protected static function defaultDebugPrint (str :String) :void
    {
        trace(str + "\n");
    }
}

}
