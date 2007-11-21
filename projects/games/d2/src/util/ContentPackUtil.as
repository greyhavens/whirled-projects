package util {

import com.threerings.util.Assert;
import com.whirled.util.ContentPack;

/**
 * Various helpful utilities for dealing with ContentPack objects.
 */
public class ContentPackUtil
{
    /**
     * Reads class and variable definitions from content packs into a single definition table.
     *
     * Given a /packs/ array filled with ContentPack items, it extracts ActionScript classes
     * with the given /className/. For each class definition, it creates a new instance, looks up
     * variables with names specified in /variableNames/, and if those exist, accumulates their
     * contents. 
     *
     * For example, if your level packs each contain a Settings class, e.g.
     *    Level1.swf:
     *    public class Settings {
     *        public var board :String = "foo";
     *        public var units :Array = [ "1", "2" ];
     *    }
     *
     *    Level2.swf:
     *    public class Settings {
     *        public var board :String = "bar";
     *        public var units :Array = [ "3" ];
     *    }
     *
     * Then the following call: 
     *    def = ContentDefinitions(packs, "Settings", ["board", "units"], myCallback);
     *
     * will load the SWFs, and call myCallback with the following Object:
     *    { board: [ "foo", "bar" ], units: [ [ "1", "2" ], [ "3" ] ] }
     *
     * For any content packs that don't contain the appropriate classes and variables, errors
     * will be logged to the Assert output, and loading will skip those elements, but not fail. 
     *
     *  @param packs         An array of ContentPack objects
     *  @param className     Name of the class to be looked up inside each content pack SWF
     *  @param variableNames Array of names of static variables, to be looked up on each class
     *  @param callback      Function that will be called after all variables have been accumulated
     *                       across all content packs. It should have the signature:
     *                         function (results :Object) :void
     */
    public static function collectClassVariableDefinitions (
        packs :Array, className :String, variableNames :Array) :Object
    {
        // initialize storage
        var results :Object = new Object();
        for each (var key :String in variableNames) {
                results[key] = [];
            }

        // now go through each content pack
        for each (var pack :ContentPack in packs) {
            if (pack != null) {

                // is the class even loading?
                var cl :Class = pack.getClass(className);
                if (cl == null) {
                    Assert.fail("Failed to load class " + className);
                    continue;
                }

                // pull out the variable and store it
                var o :Object = new cl();
                for each (key in variableNames) {
                    try {
                        results[key].push(o[key]);
                    } catch (er :Error) {
                        Assert.fail("Failed to read " + className + "." + key);
                    }
                }
            }
        }

        return results;
    }
}
}
