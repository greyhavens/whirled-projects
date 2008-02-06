package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;

import popcraft.battle.CreatureUnit;

public interface AIState
{
    function get name () :String;

    function get parentState () :AIStateTree;
    function set parentState (parent :AIStateTree) :void;
    
    function update (dt :Number, creature :CreatureUnit) :AIState;
    function receiveMessage (msg :ObjectMessage) :AIState;
}

}
