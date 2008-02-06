package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectMessage;

import popcraft.battle.CreatureUnit;

public interface AITask
{
    function get name () :String;

    function get parentTask () :AITaskTree;
    function set parentTask (parent :AITaskTree) :void;
    
    function update (dt :Number, creature :CreatureUnit) :Boolean;
    function receiveMessage (msg :ObjectMessage) :Boolean;
}

}
