package popcraft.battle.ai {
    
import popcraft.battle.ai.AITask;
    
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
            var enemyId :uint = (task as DetectEnemyTask).detectedCreatureId;
            
            this.clearSubtasks();
            this.addSubtask(new AttackUnitTask(enemyId, false, -1));
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