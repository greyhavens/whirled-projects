package ghostbusters.fight.core.tasks {

import ghostbusters.fight.core.ObjectTask;

public class ParallelTask extends TaskContainer
{
    public function ParallelTask (task1 :ObjectTask = null, task2 :ObjectTask = null)
    {
        super(TaskContainer.TYPE_PARALLEL, task1, task2);
    }
}

}
