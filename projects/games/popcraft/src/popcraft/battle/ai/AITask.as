package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;

import popcraft.battle.CreatureUnit;

/**
 * The interface implemented by each node in the AI behavior tree.
 */
public interface AITask
{
    /** The name of this AITask, used for debugging purposes. */
    function get name () :String;

    /** Returns the parent of this AITask. */
    function get parentTask () :AITaskTree;
    
    /** Sets the parent of this AITask. */
    function set parentTask (parent :AITaskTree) :void;
    
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
