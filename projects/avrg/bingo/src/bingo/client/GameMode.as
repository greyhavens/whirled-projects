package bingo.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;

import bingo.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // setup visuals
        _gameUILayer = new Sprite();
        _helpLayer = new Sprite();

        this.modeSprite.addChild(_gameUILayer);
        this.modeSprite.addChild(_helpLayer);

        this.addObject(new HUDController(), _gameUILayer);
        this.addObject(new InGameHelpController(), _helpLayer);

        this.hideHelpScreen();

        // wire up event handlers with priority 1 to get state updates before UI controllers
        ClientContext.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED,
            handleGameStateChange, false, 1);
        ClientContext.model.addEventListener(SharedStateChangedEvent.NEW_BALL,
            handleNewBall, false, 1);
        ClientContext.model.addEventListener(SharedStateChangedEvent.NEW_SCORES,
            handleNewScores, false, 1);
        ClientContext.model.addEventListener(SharedStateChangedEvent.BINGO_CALLED,
            handleBingoCalled, false, 1);

        // get current game state
        var curState :SharedState = ClientContext.model.curState;

        this.handleGameStateChange();
    }

    override protected function destroy () :void
    {
        ClientContext.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED,
            handleGameStateChange);
        ClientContext.model.removeEventListener(SharedStateChangedEvent.NEW_BALL,
            handleNewBall);
        ClientContext.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES,
            handleNewScores);
        ClientContext.model.removeEventListener(SharedStateChangedEvent.BINGO_CALLED,
            handleBingoCalled);

        // @TODO - SimObjects should have "destructor" methods that always get
        // called when modes shutdown

        this.destroyObjectNamed(BingoCardController.NAME);
        this.destroyObjectNamed(WinnerAnimationController.NAME);
        this.destroyObjectNamed(HUDController.NAME);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        switch (ClientContext.model.curState.gameState) {

        // if we're in the winner animation state, and the
        // animation has completed, move to the next state
        case SharedState.STATE_WEHAVEAWINNER:
            if (null == this.getObjectNamed(WinnerAnimationController.NAME)) {
                this.setupNewRound();
            }
        }
    }

    protected function handleGameStateChange (...ignored) :void
    {
        switch (ClientContext.model.curState.gameState) {

        case SharedState.STATE_INITIAL:
            this.setupNewRound();
            break;

        case SharedState.STATE_PLAYING:
            this.handleNewRound();
            break;

        case SharedState.STATE_WEHAVEAWINNER:
            this.showWinnerAnimation();
            break;
        }
    }

    protected function setupNewRound () :void
    {

    }

    protected function handleNewRound () :void
    {
        // destroy the winner animation if it exists
        this.destroyObjectNamed(WinnerAnimationController.NAME);

        // create a new card
        ClientContext.model.createNewCard();
        this.addObject(new BingoCardController(ClientContext.model.card), _gameUILayer);

        this.startNewBallTimer();
    }

    protected function handleNewBall (...ignored) :void
    {
        this.startNewBallTimer();
    }

    protected function showWinnerAnimation () :void
    {
        this.stopNewBallTimer();

        // destroy the bingo card view if it exists
        this.destroyObjectNamed(BingoCardController.NAME);

        var winnerId :int = ClientContext.model.curState.roundWinnerId;
        var winnerName :String = ClientContext.getPlayerName(winnerId);

        // the WinnerAnimationController will destroy itself when the animation is complete.
        // We check for the presence of the controller in update(), and when it's gone, we
        // start the next round.
        this.addObject(new WinnerAnimationController(winnerName), _gameUILayer);
    }

    protected function handleNewScores (...ignored) :void
    {
    }

    protected function handleBingoCalled (e :SharedStateChangedEvent) :void
    {

    }

    protected function startNewBallTimer () :void
    {
        this.stopNewBallTimer();
        this.addObject(new SimpleTimer(Constants.NEW_BALL_DELAY_S, null, false,
            NEW_BALL_TIMER_NAME));
    }

    protected function stopNewBallTimer () :void
    {
        this.destroyObjectNamed(NEW_BALL_TIMER_NAME);
    }

    protected function getNextBall () :String
    {
        var nextBall :String;
        do {
            nextBall = ClientContext.items.getRandomTag();
        }
        while (nextBall == ClientContext.model.curState.ballInPlay);

        return nextBall;
    }

    public function get percentTimeTillNextBall () :Number
    {
        var percentTime :Number = 1;

        var timer :SimpleTimer = this.getObjectNamed(NEW_BALL_TIMER_NAME) as SimpleTimer;
        if (null != timer) {
            percentTime = timer.timeLeft / Constants.NEW_BALL_DELAY_S;
            percentTime = Math.max(percentTime, 0);
            percentTime = Math.min(percentTime, 1);
        }

        return percentTime;
    }

    public function showHelpScreen () :void
    {
        _helpLayer.visible = true;
        _gameUILayer.visible = false;
    }

    public function hideHelpScreen () :void
    {
        _helpLayer.visible = false;
        _gameUILayer.visible = true;
    }

    protected var _gameUILayer :Sprite;
    protected var _helpLayer :Sprite;

    protected var _calledBingoThisRound :Boolean;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const NEW_BALL_TIMER_NAME :String = "NewBallTimer";

}

}
