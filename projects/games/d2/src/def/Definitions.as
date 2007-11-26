package def {

import com.threerings.util.Assert;

import com.whirled.DataPack;

/**
 * Helper class for pulling definition instances out of data packs.
 */
public class Definitions
{
    /** Array of BoardDefinition instances. */
    public var boards :Array = new Array();
    
    public function Definitions (settingsFileName :String)
    {
        _settingsFile = settingsFileName;
    }

    public function processPack (pack :DataPack) :void
    {
        if (! pack.isComplete()) {
            Assert.fail("Trying to load incomplete data pack: " + pack);
            return;
        }

        var settings :XML = pack.getFileAsXML(_settingsFile);
        Assert.isNotNull(settings, "Failed to retrieve " + _settingsFile + " from " + pack);

        trace ("PROCESSPACK SETTINGS: " + pack.getFileAsXML(_settingsFile));
        for each (var board :XML in settings.boards.board) {
                boards.push(new BoardDefinition(pack, board));
            }
    }

    protected var _settingsFile :String;
}
}
