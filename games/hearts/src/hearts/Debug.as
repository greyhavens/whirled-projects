package spades {

/** Debugging utilities. */
public class Debug
{
    /** Function for printing debug information. The function accepts a string and appends a line 
     *  break. A static variable is used so that the function can be overridden once a GameControl
     *  is constructed. */
    public static var debug :Function = defaultDebugPrint;

    /** Describe the type of the object. Only a few primitive types are supported.
     *  TODO: find out about asction script class type reflection. */
    public static function showType (label :String, obj :Object) :void
    {
        if (obj is int) {
            debug(label + " is an int");
        }
        else if (obj is String) {
            debug(label + " is a String");
        }
        else if (obj is Number) {
            debug(label + " is a Number");
        }
        else if (obj is uint) {
            debug(label + " is a uint");
        }
        else if (obj is Boolean) {
            debug(label + " is a Boolean");
        }
        else if (obj is Array) {
            debug(label + " is an Array");
        }
        else {
            debug(label + " is of an unrecognized type");
        }
    }

    /** Basic flash native printing for use prior to overriding. */
    protected static function defaultDebugPrint (str :String) :void
    {
        trace(str + "\n");
    }
}

}
