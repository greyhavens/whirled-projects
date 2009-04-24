package vampire.feeding {

import com.threerings.util.HashMap;

public interface FeedingHost
{
    /** Called when the game starts. */
    function onGameStarted () :void;

    /** Called after a successful round of feeding. */
    function onRoundComplete (results :FeedingRoundResults) :void;

    /** Called when the game is completed (after all players leave). */
    function onGameComplete () :void;

    /** Called when a player leaves the game. */
    function onPlayerLeft (playerId :int) :void;

    /** Called when a blood bond should be formed between 2 players. */
    function formBloodBond (playerId1 :int, playerId2 :int) :void;

    /** Returns the playerId that the given player is blood bonded with. */
    function getBloodBondPartner (playerId :int) :int;
}

}
