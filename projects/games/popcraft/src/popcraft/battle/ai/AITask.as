package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;

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
    
    /** 
     * Processes messages sent to the creature that the AITask is attached to.
     * Returns the status of the AITask (see AITaskStatus). 
     */
    function receiveMessage (msg :ObjectMessage) :uint;
}

}
