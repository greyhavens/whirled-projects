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

    public function begin () :void
    {
        if (_routineStack != null) {
            throw new Error("Already running");
        }

        _routineStack = [];
        callRoutine("main");
    }

    public function update (dt :Number) :void
    {
        while (this.curRoutine != null && dt > 0) {
            dt -= this.curRoutine.update(dt);
            if (this.curRoutine.isDone) {
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
    }

    protected function popRoutine () :void
    {
        _routineStack.pop();
    }

    protected function getRoutine (name :String) :Routine
    {
        return _routines.get(name) as Routine;
    }

    protected function get curRoutine () :Routine
    {
        return (_routineStack.length > 0 ? _routineStack[_routineStack.length - 1] : null);
    }

    protected var _routines :HashMap = new HashMap();
    protected var _routineStack :Array;
}

}
