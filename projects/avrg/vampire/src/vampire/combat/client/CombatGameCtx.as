package vampire.combat.client
{
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.GameModeStack;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.contrib.simplegame.resource.ResourceManager;

import flash.display.Sprite;

public class CombatGameCtx
{
    public var playerId :int;
    public var units :Array = [];

    public var mode :AppMode;
    public var game :SimpleGame;
    public var rsrcs :ResourceManager;
    public var modeStack :GameModeStack;

    public var panel :CombatPanel;
    public var controller :CombatController;

    protected var _friendlyTeams :Array = [];

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