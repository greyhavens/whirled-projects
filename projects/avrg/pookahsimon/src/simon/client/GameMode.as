package simon.client {

import flash.display.Sprite;

import com.threerings.util.Log;

import com.whirled.contrib.simplegame.AppMode;

import simon.data.State;
import simon.data.Constants;

public class GameMode extends AppMode
{
    public var log :Log = SimonMain.log;

    override protected function setup () :void
    {
        _gameLayer = new Sprite();
        _helpLayer = new Sprite();

        this.modeSprite.addChild(_gameLayer);
        this.modeSprite.addChild(_helpLayer);

        // controllers
        this.addObject(new CloudViewController(), _gameLayer);
        this.addObject(new AvatarController());
        this.addObject(new HelpViewController(), _helpLayer);

        this.helpScreenVisible = false;

        // state change events
        SimonMain.model.addEventListener(SimonEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.addEventListener(SimonEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.addEventListener(SimonEvent.NEW_SCORES, handleNewScores);
    }

    override protected function destroy () :void
    {
        // @TODO - remove this once SimObject gets a function that's called
        // on mode shutdown
        this.destroyObjectNamed(AbstractRainbowController.NAME);
        this.destroyObjectNamed(CloudViewController.NAME);
        this.destroyObjectNamed(AvatarController.NAME);

        SimonMain.model.removeEventListener(SimonEvent.GAME_STATE_CHANGED, handleGameStateChange);
        SimonMain.model.removeEventListener(SimonEvent.NEXT_PLAYER, handleCurPlayerChanged);
        SimonMain.model.removeEventListener(SimonEvent.NEW_SCORES, handleNewScores);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        this.updateStatusText();
    }

    protected function handleQuitButtonClick (...ignored) :void
    {
        SimonMain.quit();
    }

    protected function handleGameStateChange (...ignored) :void
    {
        log.info(
            "Handling game state change [state=" + SimonMain.model.curState + "]");
        
        this.destroyObjectNamed(AbstractRainbowController.NAME);
        this.destroyObjectNamed(WinnerCloudController.NAME);

        switch (SimonMain.model.curState.gameState) {
        case State.STATE_INITIAL:
        case State.STATE_WAITINGFORPLAYERS:
            break;

        case State.STATE_PLAYING:
            // the game has started -- it's the first player's turn
            this.handleCurPlayerChanged();
            break;

        case State.STATE_WEHAVEAWINNER:
            this.handleGameOver();
            break;

        default:
            log.info("unrecognized gameState: " + SimonMain.model.curState.gameState);
            break;
        }

        this.updateStatusText();
    }

    protected function handleCurPlayerChanged (...ignored) :void
    {
        if (SimonMain.model.curState.gameState != State.STATE_PLAYING) {
            return;
        }

        log.info(
            "Handling current player change [state=" + SimonMain.model.curState + "]");

        this.destroyObjectNamed(AbstractRainbowController.NAME);

        // show the rainbow on the correct player
        this.addObject(AbstractRainbowController.create(SimonMain.model.curState.curPlayerOid), _gameLayer);
    }

    protected function handleNewScores (...ignored) :void
    {
    }

    protected function handleGameOver () :void
    {
        var roundWinnerId :int = SimonMain.model.curState.roundWinnerId;

        if (roundWinnerId != 0) {

            // show the winner screen
            this.addObject(new WinnerCloudController(roundWinnerId), _gameLayer);

            // dance if we are the winner
            if (roundWinnerId == SimonMain.localPlayerId && SimonMain.control.isConnected()) {
                AvatarController.instance.setAvatarState("Dance", Constants.AVATAR_DANCE_TIME, "Default");
            }
        }
    }

    protected function updateStatusText () :void
    {
        var newStatusText :String;

        switch (SimonMain.model.curState.gameState) {
        case State.STATE_INITIAL:
            newStatusText = "STATE_INITIAL";
            break;

        case State.STATE_WAITINGFORPLAYERS:
            newStatusText = "Waiting to start (players: " + SimonMain.model.getPlayerOids().length + "/" + Constants.MIN_MP_PLAYERS_TO_START + ")";
            break;

        case State.STATE_PLAYING:
            var curPlayerName :String = SimonMain.getPlayerName(SimonMain.model.curState.curPlayerOid);
            newStatusText = "Playing game. " + curPlayerName + "'s turn.";
            break;

        case State.STATE_WEHAVEAWINNER:
            newStatusText = SimonMain.getPlayerName(SimonMain.model.curState.roundWinnerId) + " is the winner!";
            break;

        default:
            log.info("unrecognized gameState: " + SimonMain.model.curState.gameState);
            break;
        }

        if (newStatusText != _statusText) {
            log.info("** STATUS: " + newStatusText);
            _statusText = newStatusText;
        }
    }

    public function currentPlayerTurnSuccess (notePlayed :int) :void
    {
    }

    public function currentPlayerTurnFailure () :void
    {
    }

    public function get helpScreenVisible () :Boolean
    {
        return _helpLayer.visible;
    }

    public function set helpScreenVisible (visible :Boolean) :void
    {
        _helpLayer.visible = visible;
    }

    protected var _gameLayer :Sprite;
    protected var _helpLayer :Sprite;

    protected var _statusText :String;
}

}
