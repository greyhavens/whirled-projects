package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectTask;

public interface AIState extends ObjectTask
{
    function get name () :String;

    function get parentState () :AIStateTree;
    function set parentState (parent :AIStateTree) :void;
    
    function transitionTo (newState :AIState) :void;
}

}
