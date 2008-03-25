package popcraft.battle.ai {
    
import com.whirled.contrib.simplegame.SimObjectRef;
    
public class AttackApproachingEnemiesTask extends AITaskTree
{
    public function AttackApproachingEnemiesTask ()
    {
        this.addSubtask(new DetectEnemyTask());
    }
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        switch (task.name) {
            
        case DetectEnemyTask.NAME:
            // unit detected. start attacking
            var enemyRef :SimObjectRef = (task as DetectEnemyTask).detectedCreatureRef;
            
            this.clearSubtasks();
            this.addSubtask(new AttackUnitTask(enemyRef, false, -1));
            break;
            
        case AttackUnitTask.NAME:
            // unit killed. get back to detecting.
            this.clearSubtasks();
            this.addSubtask(new DetectEnemyTask());
            break;
            
        }
    }
    
}

}