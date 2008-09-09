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
}

}
