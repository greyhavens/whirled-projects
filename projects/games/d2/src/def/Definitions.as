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
    /** Array of PackDefinition instances. */
    public var packs :Array = new Array(); // of PackDefinition

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
    public function handleUnload () :void
    {
        // todo - event listener removal here
    }

    /**
     * Finds an instance of BoardDefinition by guid, across all packs.
     * Returns null in case of failure.
     */
    public function findBoard (guid :String) :BoardDefinition
    {
        var result :BoardDefinition = null; 
        packs.forEach(function (pack :PackDefinition, ... etc) :void {
                if (result == null) {
                    result = pack.findBoard(guid);
                }
            });
        return result;
    }
    
    /**
     * Finds an instance of EnemyDefinition by typeName, across all packs.
     * Returns null in case of failure.
     */
    public function findEnemy (typeName :String) :EnemyDefinition
    {
        var result :EnemyDefinition = null; 
        packs.forEach(function (pack :PackDefinition, ... etc) :void {
                if (result == null) {
                    result = pack.findEnemy(typeName);
                }
            });
        return result;
    }

    /**
     * Finds an instance of EnemyDefinition by typeName, across all packs.
     * Returns null in case of failure.
     */
    public function findTower (typeName :String) :TowerDefinition
    {
        var result :TowerDefinition = null; 
        packs.forEach(function (pack :PackDefinition, ... etc) :void {
                if (result == null) {
                    result = pack.findTower(typeName);
                }
            });
        return result;
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
            function (results :Object) :void { packedSwfsLoaded(pack, results, settings); },
            true);
       
    }
    
    /**
     * Called when embedded SWFs for the given data pack have been loaded,
     * finishes up processing.
     */
    protected function packedSwfsLoaded (pack :DataPack, swfs :Object, settings :XML) :void
    {
        // create a new pack
        var pd :PackDefinition = new PackDefinition(swfs.boards, settings);
        packs.push(pd);

        // load up towers
        for each (var towerxml :XML in settings.towers.tower) {
                var tower :TowerDefinition = new TowerDefinition(swfs.units, pd, towerxml);
                pd.towers.push(tower);
            }
        
        // load up enemies
        for each (var enemyxml :XML in settings.enemies.enemy) {
                var enemy :EnemyDefinition = new EnemyDefinition(swfs.units, pd, enemyxml);
                pd.enemies.push(enemy);
            }

        // create the boards
        for each (var boardxml :XML in settings.boards.board) {
                var board :BoardDefinition = new BoardDefinition(swfs.boards, pd, boardxml);
                trace("Pushing definition: " + board);
                pd.boards.push(board);
            }

        trace("GOT PACK: " + pd);
        
        if (--_remainingPacks <= 0) {
            _callback();
        }
    }        

    /** Total number of packs that remain to be processed. */
    protected var _remainingPacks :int;

    /** Callback that will be run once we run out of packs to process. */
    protected var _callback :Function;
    
    /**
     * Collection of all display objects from all packs. It maps from DataPack to an object,
     * whose keys are SWF names "board" and "units", and whose values are actual SWF loaders.
     */
    protected var _allSwfs :HashObjectMap = new HashObjectMap();
}
}
