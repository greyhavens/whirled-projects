package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectTask;

public interface AITask extends ObjectTask
{
    function addSubtask (task :AITask) :void;
    function clearSubtasks () :void;
    function setSubtask (task :AITask) :void;
    function hasSubtaskNamed (name :String) :Boolean;
    function hasSubtasksNamed (names :Array, index :uint = 0) :Boolean;

    function getStateString (depth :uint = 0) :String;

    function get name () :String;
}

}
