package util {

/**
 * This class is similar in functionality to Assert, except:
 *  - checks are performed in both Debug and Release versions of the Flash Player
 *  - failures throw an Error and, if unhandled, perhaps stop the program
 *
 * These kinds of asserts are particularly useful for content validation -
 * e.g. for throwing errors when expected assets are missing, or when they
 * don't contain all of the expected data. This makes it easy for content creators,
 * who don't usually run in debug environments, to see problems with their assets.
 *
 * Since this class will break the program on every error, use it judiciously. :)
 *
 * Usage example:
 * <pre>
 *   boardAsset = myAssetLoader.getBoard(boardName);
 *   ContentAssert.isNotNull(boardAsset, "Cannot find the board: " + boardName);
 *   ContentAssert.isTrue(boardAsset is MovieClip,
 *                        "Incorrect board asset type, expected a MovieClip");
 * </pre>
 */
public class ContentAssert {

    /** Asserts that the value is equal to null. */
    public static function isNull (value :Object, message :String) :void
    {
        if (value != null) {
            fail(message);
        }
    }

    /** Asserts that the value is not equal to null. */
    public static function isNotNull (value :Object, message :String) :void
    {
        if (value == null) {
            fail(message);
        }
    }

    /** Asserts that the value is false. */
    public static function isFalse (value :Boolean, message :String) :void
    {
        if (value) {
            fail(message);
        }
    }
    
    /** Asserts that the value is true. */
    public static function isTrue (value :Boolean, message :String) :void
    {
        if (! value) {
            fail(message);
        }
    }

    /** Displays an error message, with an optional stack trace. */
    public static function fail (message :String) :void
    {
        throw new Error("Content Error: " + message);
    }        
    
}

}
