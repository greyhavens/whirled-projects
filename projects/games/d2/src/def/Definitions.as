package def {

import mx.utils.ObjectUtil;
    
import com.threerings.util.Assert;
import com.threerings.util.HashObjectMap;

import com.whirled.DataPack;

/**
 * Helper class for pulling definition instances out of data packs.
 */
public class Definitions
{
    /** Array of BoardDefinition instances. */
    public var boards :Array = new Array();

    /** Reads definitions from a single data pack, and stores them internally. */
    public function processPack (pack :DataPack) :void
    {
        if (! pack.isComplete()) {
            Assert.fail("Trying to load incomplete data pack: " + pack);
            return;
        }

        var settings :XML = pack.getFileAsXML("settings");
        Assert.isNotNull(settings, "Failed to retrieve settings from " + pack);
        trace("SETTINGS: " + settings);
        
        pack.getDisplayObjects([ "boards", "units" ],
                               function (results :Object) :void {
                                   _allSwfs.put(pack, results);

                                   trace("SWFs so far: " + ObjectUtil.toString(results));
                               },
                               true);
        
        for each (var board :XML in settings.boards.board) {
                boards.push(new BoardDefinition(pack, board));
            }
    }

    /**
     * Collection of all display objects from all packs. It maps from DataPack to an object,
     * whose keys are SWF names "board" and "units", and whose values are actual SWF loaders.
     */
    protected var _allSwfs :HashObjectMap = new HashObjectMap();
}
}
