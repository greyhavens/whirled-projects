package simon {

public class OfflineModel extends Model
{
    override public function trySetNewState (newState :SharedData) :void
    {
        // in offline mode, we can convert state change requests
        // directly into state changes

        this.setState(newState);
    }

    override public function trySetNewScores (newScores :Scoreboard) :void
    {
        this.setScores(newScores);
    }
}

}