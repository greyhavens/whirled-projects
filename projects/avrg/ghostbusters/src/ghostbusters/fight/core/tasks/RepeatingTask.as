package ghostbusters.fight.core.tasks {

import ghostbusters.fight.core.ObjectTask;

public class RepeatingTask extends TaskContainer
{
    public function RepeatingTask (task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        super(TaskContainer.TYPE_REPEATING, task1, task2);
    }
}

}
