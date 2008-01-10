package popcraft.battle.ai {

import com.whirled.contrib.core.ObjectTask;

public interface AITask extends ObjectTask
{
    function addSubtask (task :AITask) :void;
    function clearSubtasks () :void;
    function hasSubtaskNamed (name :String) :Boolean;
    function hasSubtasksNamed (names :Array, index :uint = 0) :Boolean;

    function getStateString (depth :uint = 0) :String;

    function get name () :String;

    function get parentTask () :AITask;
    function set parentTask (parent :AITask) :void;
}

}
