package vampire.combat.client
{
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.GameModeStack;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.FlashbangApp;

import flash.display.Sprite;

public class GameInstance
{
    public var playerId :int;
    public var units :Array = [];

    public var friendlyUnits :Array = [];
    public var enemyUnits :Array = [];

    public var mode :AppMode;
    public var game :FlashbangApp;
    public var modeStack :GameModeStack;
    public var client :CombatClient;

    public var panel :CombatPanel;
    public var controller :CombatController;

    public var targetReticle :Sprite;

    public var locationHandler :LocationHandler;

//    public var actionChooser :ActionChooser;
    public var selectedFriendlyUnit :UnitRecord;
    public var selectedEnemyUnit :UnitRecord;

    protected var _friendlyTeams :Array = [];

//    public function removeUnit (unit :UnitRecord) :void
//    {
//        ArrayUtil.removeAll(friendlyUnits, unit);
//        ArrayUtil.removeAll(enemyUnits, unit);
//        unit.destroySelf();
//    }

    public function init (ourPlayerId :int) :void
    {
        playerId = ourPlayerId;
        //Register classes for serialization
//        flash.net.registerClassAlias(aliasString, class).
    }
    public function setFriendlyTeams (team1 :int, team2 :int) :void
    {
        _friendlyTeams.push([team1, team2]);
    }
    //0 == attack everyone else
    public function isEnemyTeams (team1 :int, team2 :int) :Boolean
    {
        if (_friendlyTeams.length == 0 || team1 == 0 || team2 == 0) {
            return true;
        }
        for each (var teams :Array in _friendlyTeams) {
            if (ArrayUtil.contains(teams, team1) && ArrayUtil.contains(teams, team2)) {
                return false;
            }
        }
        return true;
    }




}
}
