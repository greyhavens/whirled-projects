package popcraft.battle.ai {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;

public class AISerialTask extends SerialTask
    implements AITask
{
    public function AISerialTask ()
    {
    }

    public function addSubtask (task :AITask) :void
    {
        var topTask :AITask = this.topTask;
        if (null != topTask) {
            topTask.addSubtask(task);
        }
    }

    public function clearSubtasks () :void
    {
        var topTask :AITask = this.topTask;
        if (null != topTask) {
            topTask.clearSubtasks();
        }
    }

    public function setSubtask (task :AITask) :void
    {
        var topTask :AITask = this.topTask;
        if (null != topTask) {
            topTask.setSubtask(task);
        }
    }

    public function hasSubtaskNamed (name :String) :Boolean
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.hasSubtaskNamed(name) : false);
    }

    public function hasSubtasksNamed (names :Array) :Boolean
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.hasSubtasksNamed(names) : false);
    }

    public function getStateString () :String
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.getStateString() : "[empty sequence]");
    }

    public function get name () :String
    {
        var topTask :AITask = this.topTask;
        return (null != topTask ? topTask.name : "[empty sequence]");
    }

    protected function get topTask () :AITask
    {
        for each (var task :AITask in _tasks) {
            if (null != task) {
                return task;
            }
        }

        return null;
    }

}

}
