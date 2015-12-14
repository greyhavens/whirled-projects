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
        ProgramCtx.program.scheduleRoutine(_routineName);
        return Status.CompletedInstantly;
    }

    protected var _routineName :String;
}

}
