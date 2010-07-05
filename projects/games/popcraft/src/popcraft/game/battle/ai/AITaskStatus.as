//
// $Id$

package popcraft.game.battle.ai {

import com.threerings.util.Enum;

/**
 * AITaskStatus enum.
 */
public final class AITaskStatus extends Enum
{
    // DEFINE MEMBERS HERE
    public static const INCOMPLETE :AITaskStatus = new AITaskStatus("INCOMPLETE");
    public static const COMPLETE :AITaskStatus = new AITaskStatus("COMPLETE");
    finishedEnumerating(AITaskStatus);

    /**
     * Get the values of the AITaskStatus enum
     */
    public static function values () :Array
    {
        return Enum.values(AITaskStatus);
    }

    /**
     * Get the value of the AITaskStatus enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :AITaskStatus
    {
        return Enum.valueOf(AITaskStatus, name) as AITaskStatus;
    }

    /** @private */
    public function AITaskStatus (name :String)
    {
        super(name);
    }
}

}
