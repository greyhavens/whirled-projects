package com.threerings.defense {

/**
 * Experimental implementation of asserts.
 *
 * Since ActionScript doesn't have built-in asserts, or even
 * a preprocessor, we can try to fake it using anonymous functions plus a logger.
 */
public class Assert
{
    public static function True (testvalue :*, message :String) : void
    {
        var result :Boolean = false;
        
        if (testvalue is Boolean) {
            result = testvalue;
        } else if (testvalue is Function) {
            result = testvalue();
        } else {
            result = (testvalue != null);
        }

        if (! result) {
            Log.getLog("Assert").warning(message + "[test=" + testvalue + "].");
        }
    }
}
}


