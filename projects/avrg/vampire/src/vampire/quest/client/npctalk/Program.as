package vampire.quest.client.npctalk {

import com.threerings.util.HashMap;

public class Program
{
    public function addRoutine (routine :Routine) :void
    {
        if (_routines.put(routine.name, routine) !== undefined) {
            throw new Error("Duplicate routine name '" + routine.name + "'");
        }
    }

    public function run (talkView :TalkView) :void
    {
        if (_routineStack != null) {
            throw new Error("Already running");
        }

        ProgramCtx.init();
        ProgramCtx.program = this;
        ProgramCtx.view = talkView;

        _routineStack = [];
        _routineState = [];
        callRoutine("main");
    }

    public function update (dt :Number) :void
    {
        while (this.curRoutine != null && dt > 0) {
            dt -= this.curRoutine.update(dt, this.curState);
            if (this.curRoutine.isDone(this.curState)) {
                popRoutine();
            }
        }
    }

    public function get isDone () :Boolean
    {
        return (_routineStack.length == 0);
    }

    public function callRoutine (name :String) :void
    {
        var routine :Routine = getRoutine(name);
        if (routine == null) {
            throw new Error("No routine named '" + name + "'");
        }

        _routineStack.push(routine);
        _routineState.push(routine.createState());
    }

    public function hasRoutine (name :String) :Boolean
    {
        return (getRoutine(name) != null);
    }

    protected function popRoutine () :void
    {
        _routineStack.pop();
        _routineState.pop();
    }

    protected function getRoutine (name :String) :Routine
    {
        return _routines.get(name) as Routine;
    }

    protected function get curRoutine () :Routine
    {
        return (_routineStack.length > 0 ? _routineStack[_routineStack.length - 1] : null);
    }

    protected function get curState () :Object
    {
        return (_routineState.length > 0 ? _routineState[_routineState.length - 1] : null);
    }

    protected var _routines :HashMap = new HashMap();
    protected var _routineStack :Array;
    protected var _routineState :Array;
}

}
