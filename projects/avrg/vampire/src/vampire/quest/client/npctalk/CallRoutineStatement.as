package vampire.quest.client.npctalk {

public class CallRoutineStatement
    implements Statement
{
    public function CallRoutineStatement (routineName :String)
    {
        _routineName = routineName;
    }

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.program.callRoutine(_routineName);
        return 0; // completes immediately
    }

    public function isDone (state :Object) :Boolean
    {
        return true;
    }

    protected var _routineName :String;
}

}
