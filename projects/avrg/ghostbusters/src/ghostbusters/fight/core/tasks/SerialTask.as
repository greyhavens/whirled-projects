package ghostbusters.fight.core.tasks {

import ghostbusters.fight.core.ObjectTask;

public class SerialTask extends TaskContainer
{
    public function SerialTask (task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        super(TaskContainer.TYPE_SERIAL, task1, task2);
    }
}

}
