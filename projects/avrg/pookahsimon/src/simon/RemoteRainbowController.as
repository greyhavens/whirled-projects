package simon {

import flash.geom.Point;

public class RemoteRainbowController extends AbstractRainbowController
{
    public function RemoteRainbowController (playerId :int)
    {
        super(playerId);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        SimonMain.model.addEventListener(SimonEvent.PLAYER_TIMEOUT, handlePlayerTimedOut);
        SimonMain.model.addEventListener(SimonEvent.NEXT_RAINBOW_SELECTION, handleNextRainbowSelection);
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();

        SimonMain.model.removeEventListener(SimonEvent.PLAYER_TIMEOUT, handlePlayerTimedOut);
        SimonMain.model.removeEventListener(SimonEvent.NEXT_RAINBOW_SELECTION, handleNextRainbowSelection);
    }

    protected function handleNextRainbowSelection (e :SimonEvent) :void
    {
        var noteIndex :int = e.data as int;
        var clickLoc :Point = DEFAULT_SPARKLE_LOCS[noteIndex];
        this.nextNoteSelected(noteIndex, clickLoc);
    }

    protected function handlePlayerTimedOut (...ignored) :void
    {
        // called when the player has taken too long to click a note
        this.gameMode.currentPlayerTurnFailure();
    }

}

}
