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
        if (_isRunning) {
            throw new Error("Already running");
        }

        ProgramCtx.init();
        ProgramCtx.program = this;
        ProgramCtx.view = talkView;

        _routineStack = [];
        _routineState = [];
        _scheduledRoutineName = null;
        _isRunning = true;

        callRoutine("main");
    }

    public function update (dt :Number) :void
    {
        if (!_isRunning) {
            throw new Error("Program is not running");
        }

        while (_isRunning && this.curRoutine != null && dt > 0) {
            var status :Number = this.curRoutine.update(dt, this.curState);
            if (Status.isComplete(status)) {
                popRoutine();
                dt -= status;
            }

            if (_scheduledRoutineName != null) {
                callRoutine(_scheduledRoutineName);
                _scheduledRoutineName = null;
            }

            if (Status.isIncomplete(status)) {
                break;
            }
        }

        if (this.curRoutine == null) {
            exit();
        }
    }

    public function get isRunning () :Boolean
    {
        return _isRunning;
    }

    public function scheduleRoutine (name :String) :void
    {
        if (name == null) {
            throw new ArgumentError("name cannot be null");
        }

        if (_scheduledRoutineName != null) {
            throw new Error("Only one routine can be scheduled at a time; how did this happen?");
        }

        _scheduledRoutineName = name;
    }

    public function exit () :void
    {
        _isRunning = false;
    }

    protected function callRoutine (name :String) :void
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
    protected var _scheduledRoutineName :String;
    protected var _isRunning :Boolean;
}

}
