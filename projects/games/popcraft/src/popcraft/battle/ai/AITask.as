package popcraft.battle.ai {

import popcraft.battle.CreatureUnit;

/**
 * The interface implemented by each node in the AI behavior tree.
 */
public interface AITask
{
    /** Returns the name of this AITask. */
    function get name () :String;
    
    /** 
     * Advances the logic of the AITask. 
     * Returns the status of the AITask (see AITaskStatus). 
     */
    function update (dt :Number, creature :CreatureUnit) :uint;
}

}
