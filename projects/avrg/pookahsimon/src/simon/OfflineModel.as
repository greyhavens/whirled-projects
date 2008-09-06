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

    override public function sendPlayerTimeoutMessage () :void
    {
        this.playerTimeout();
    }

    override public function trySetNewState (newState :State) :void
    {
        // in offline mode, we can convert state change requests
        // directly into state changes

        this.setState(newState);
    }

    override public function trySetNewScores (newScores :ScoreTable) :void
    {
        this.setScores(newScores);
    }
}

}
