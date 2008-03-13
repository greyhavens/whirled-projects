package simon {

public class OfflineModel extends Model
{
    override public function getPlayerOids () :Array
    {
        return [ SimonMain.localPlayerId ];
    }

    override public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        this.rainbowClicked(clickedIndex);
    }

    override public function trySetNewState (newState :SharedState) :void
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