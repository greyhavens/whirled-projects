package def {

import flash.events.Event;

import mx.utils.ObjectUtil;
    
import com.threerings.util.Assert;
import com.threerings.util.HashObjectMap;

import com.whirled.DataPack;

/**
 * Helper class for pulling definition instances out of data packs.
 */
public class Definitions
    implements UnloadListener
{
    /** Array of BoardDefinition instances. */
    public var boards :Array = new Array();

    /**
     * Takes the total number of content packs, and a callback to be run after all those packs have
     * been processed. Callback should have signature: function () :void { }.
     */
    public function Definitions (totalPacks :int, callback :Function)
    {
        _remainingPacks = totalPacks;
        _callback = callback;
    }
    
    // from interface UnloadListener
    public function handleUnload (event :Event) :void
    {
        // todo - event listener removal here
    }
        
    /** Reads definitions from a single data pack, and stores them internally. */
    public function processPack (pack :DataPack) :void
    {
        if (! pack.isComplete()) {
            Assert.fail("Trying to load incomplete data pack: " + pack);
            return;
        }

        var settings :XML = pack.getFileAsXML("settings");
        Assert.isNotNull(settings, "Failed to retrieve settings from " + pack);

        // load the swfs marked as 'boards' and 'units' in the data pack definition
        pack.getSwfLoaders(
            [ "boards", "units" ],
            function (results :Object) :void { packedSwfsLoaded(results, settings); },
            true);
       
    }

    /**
     * Called when embedded SWFs for the given data pack have been loaded,
     * finishes up processing.
     */
    protected function packedSwfsLoaded (swfs :Object, settings :XML) :void
    {
        trace("Got swfs: " + swfs);
        trace("Boards: " + swfs.boards);
        trace("Units: " + swfs.units);

        for each (var board :XML in settings.boards.board) {
                var bd :BoardDefinition = new BoardDefinition(++_nextid, swfs.boards, board);
                trace("Pushing definition: " + bd);
                boards.push(bd);
            }
   
        if (--_remainingPacks <= 0) {
            _callback();
        }
    }        

    /** Total number of packs that remain to be processed. */
    protected var _remainingPacks :int;

    /** Callback that will be run once we run out of packs to process. */
    protected var _callback :Function;

    /** Id counter across all definitions. */
    protected static var _nextid :int = 0;
    
    /**
     * Collection of all display objects from all packs. It maps from DataPack to an object,
     * whose keys are SWF names "board" and "units", and whose values are actual SWF loaders.
     */
    protected var _allSwfs :HashObjectMap = new HashObjectMap();
}
}
