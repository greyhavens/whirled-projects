package vampire.combat.client
{
    import com.threerings.util.Util;
    import com.whirled.contrib.DisplayUtil;
    import com.threerings.flashbang.tasks.LocationTask;

    import flash.geom.Point;


/**
 * Units can be ranged or close.  If an enemy is ranged, you have to kill enemies that are
 * close before moving in.
 *
 */
public class LocationHandler
{
    public function LocationHandler(game :GameInstance)
    {
        _game = game;
    }

    public function moveUnits () :void
    {
        //Dist friendly units
        var rangedFriendly :Array = filterByRange(_game.friendlyUnits, RANGED);
        var closeFriendly :Array = filterByRange(_game.friendlyUnits, CLOSE);
        var rangedEnemy :Array = filterByRange(_game.enemyUnits, RANGED);
        var closeEnemy :Array = filterByRange(_game.enemyUnits, CLOSE);

        var lines :Array = [rangedFriendly, closeFriendly, closeEnemy, rangedEnemy];

        var arena :Arena = _game.panel.arena;

        var ii :int;
        var icon :UnitArenaIcon;
        var target :Point;
        var xStart :int;

        for (var lineIndex :int = 0; lineIndex < lines.length; ++lineIndex) {
            xStart = DisplayUtil.distributionPoint(lineIndex, lines.length, 0, 0, arena.width, 0).x;
            var unitLine :Array = lines[lineIndex] as Array;
            for (ii = 0; ii < unitLine.length; ++ii) {
                target = DisplayUtil.distributionPoint(ii, unitLine.length, xStart, 10, xStart, arena.height - 10);
                UnitRecord(unitLine[ii]).arenaIcon.addTask(
                    LocationTask.CreateEaseIn(target.x, target.y, 0.5));
            }

        }
    }

    public function existsUnitInRange (unit :UnitRecord) :Boolean
    {
        //Check for ranged weapons
        if (unit.isRangedWeapon) {
            return true;
        }
        var enemy :UnitRecord;
        var opponents :Array = _game.playerId == unit.controllingPlayer ? _game.enemyUnits : _game.friendlyUnits;
        if (unit.range == LocationHandler.CLOSE) {
            for each (enemy in opponents) {
                if (enemy.range == LocationHandler.CLOSE) {
                    return true;
                }
            }
        }
        return false;
    }

    public function isTargetInRange (unit :UnitRecord, target :UnitRecord) :Boolean
    {
        if (unit.range == target.range && unit.range == CLOSE) {
            return true;
        }
        return unit.isRangedWeapon;
    }



    public function getClosestEnemy (unit :UnitRecord) :UnitRecord
    {
        var opponents :Array = _game.playerId == unit.controllingPlayer ? _game.enemyUnits : _game.friendlyUnits;

        if (unit.range == LocationHandler.CLOSE) {
            opponents = filterByRange(opponents, LocationHandler.CLOSE);
        }
        if (opponents.length > 0) {
            return opponents[0];
        }
        return null;
    }

    protected function filterByRange (units :Array, range :int) :Array
    {
        return units.filter(Util.adapt(function (unit :UnitRecord) :Boolean {
            if (unit.health > 0 && unit.range == range) {
                return true;
            }
            return false;
        }));
    }
//
//    public function addUnit (unit :UnitRecord, distance :int = CLOSE) :void
//    {
//        if (unit.controllingPlayer == _game.playerId) {
//            if (distance == CLOSE) {
//                friendlyClose.push(unit);
//            }
//            else {
//                friendlyRanged.push(unit);
//            }
//        }
//        else {
//            if (distance == CLOSE) {
//                enemyClose.push(unit);
//            }
//            else {
//                enemyRanged.push(unit);
//            }
//        }
//    }

//    public function getRange (unit :UnitRecord) :int
//    {
//        if (unit.controllingPlayer == _game.playerId) {
//
//            if (distance == CLOSE) {
//                friendlyClose.push(unit);
//            }
//            else {
//                friendlyRanged.push(unit);
//            }
//        }
//    }

    protected var _game :GameInstance;

//    public var friendlyClose :Array = [];
//    public var friendlyRanged :Array = [];
//    public var enemyClose :Array = [];
//    public var enemyRanged :Array = [];

    public static const CLOSE :int = 0;
    public static const RANGED :int = 1;
}
}
