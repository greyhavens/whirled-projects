//
// $Id$

package locksmith.model {

import com.whirled.game.GameControl;

import com.whirled.contrib.EventHandlerManager;

import com.threerings.util.ValueEvent;

[Event(name="playerScored", type="com.threerings.util.ValueEvent")]

public class ScoreManager extends ModelManager
{
    public static const PLAYER_SCORE :String = "ScoreManagerPlayerScore";
    
    // event dispatched by this manager
    public static const PLAYER_SCORED :String = "playerScored";

    public static const WIN_SCORE :int = 6;

    public function ScoreManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        super(gameCtrl, eventMgr);
        manageProperties(PLAYER_SCORE);
    }

    public function getScore (player :Player) :int
    {
        return getIn(PLAYER_SCORE, player.ordinal()) as int;
    }

    public function playerScoredPoint (player :Player) :void
    {
        requireServer();
        setIn(PLAYER_SCORE, player.ordinal(), getScore(player) + 1);
    }

    override protected function managedPropertyUpdated (prop :String, oldValue :Object,
        newValue :Object, key :int = -1) :void
    {
        dispatchEvent(new ValueEvent(PLAYER_SCORED, Player.values[key]));
    }
}
}
