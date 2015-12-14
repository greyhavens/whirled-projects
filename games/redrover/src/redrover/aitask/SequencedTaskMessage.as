package redrover.aitask {

public class SequencedTaskMessage
{
    public var task :AITask;
    public var messageName :String;
    public var data :Object;

    public function SequencedTaskMessage (task :AITask, messageName :String, data :Object)
    {
        this.task = task;
        this.messageName = messageName;
        this.data = data;
    }

}

}
