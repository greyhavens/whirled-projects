package vampire.quest.client.npctalk {

public class CallRoutineStatement
    implements Statement
{
    public function CallRoutineStatement (routineName :String)
    {
        _routineName = routineName;
    }

    public function update (dt :Number) :Number
    {
        ProgramCtx.program.callRoutine(_routineName);
        return 0; // completes immediately
    }

    public function get isDone () :Boolean
    {
        return true;
    }

    protected var _routineName :String;
}

}
