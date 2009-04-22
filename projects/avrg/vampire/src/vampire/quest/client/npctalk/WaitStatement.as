package vampire.quest.client.npctalk {

public class WaitStatement
    implements Statement
{
    public function WaitStatement (seconds :Number)
    {
        _seconds = seconds;
    }

    public function createState () :Object
    {
        return new WaitState();
    }

    public function update (dt :Number, state :Object) :Number
    {
        var waitState :WaitState = WaitState(state);
        waitState.elapsedTime += dt;

        if (waitState.elapsedTime >= _seconds) {
            return Status.CompletedAfter(Math.max(waitState.elapsedTime - _seconds, 0));
        } else {
            return Status.Incomplete;
        }
    }

    protected var _seconds :Number;
}

}

class WaitState
{
    public var elapsedTime :Number = 0;
}
