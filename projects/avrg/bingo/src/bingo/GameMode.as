package bingo {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.Sprite;

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
        BingoMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange, false, 1);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall, false, 1);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores, false, 1);
        BingoMain.model.addEventListener(SharedStateChangedEvent.BINGO_CALLED, handleBingoCalled, false, 1);

        // get current game state
        var curState :SharedState = BingoMain.model.curState;
        var stateIsValid :Boolean = curState.isValid;

        log.info("Initial state: " + curState.toString() + " (valid: " + String(stateIsValid) + ")");

        if (stateIsValid) {
            this.handleGameStateChange();
        } else {
            _expectedState = new SharedState();
            this.sendStateChanges();
        }
    }

    override protected function destroy () :void
    {
        BingoMain.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.BINGO_CALLED, handleBingoCalled);

        // @TODO - SimObjects should have "destructor" methods that always get
        // called when modes shutdown

        this.destroyObjectNamed(BingoCardController.NAME);
        this.destroyObjectNamed(WinnerAnimationController.NAME);
        this.destroyObjectNamed(HUDController.NAME);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        switch (BingoMain.model.curState.gameState) {

        // if we're in the winner animation state, and the
        // animation has completed, move to the next state
        case SharedState.STATE_WEHAVEAWINNER:
            if (null == this.getObjectNamed(WinnerAnimationController.NAME)) {
                this.setupNewRound();
            }
        }

        this.sendStateChanges();
    }

    protected function sendStateChanges () :void
    {
        if (null != _expectedState) {

            // trySetNewState is idempotent in the sense that
            // we can keep calling it until the state changes.
            // The state change we see will not necessarily
            // be what was requested (this client may not be in control)

            BingoMain.model.trySetNewState(_expectedState);
        }

        if (null != _expectedScores) {

            // see above

            BingoMain.model.trySetNewScores(_expectedScores);
        }
    }

    protected function handleGameStateChange (...ignored) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        switch (BingoMain.model.curState.gameState) {

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
        _expectedState = BingoMain.model.curState.clone();
        _expectedState.roundId += 1;
        _expectedState.roundWinnerId = 0;
        _expectedState.ballInPlay = this.getNextBall();
        _expectedState.gameState = SharedState.STATE_PLAYING;

        this.sendStateChanges();
    }

    protected function handleNewRound () :void
    {
        // destroy the winner animation if it exists
        this.destroyObjectNamed(WinnerAnimationController.NAME);

        // create a new card
        BingoMain.model.createNewCard();
        this.addObject(new BingoCardController(BingoMain.model.card), _gameUILayer);

        // reset tags
        BingoItemManager.instance.resetRemainingTags();

        // start the new ball timer
        BingoItemManager.instance.removeFromRemainingTags(BingoMain.model.curState.ballInPlay);
        this.startNewBallTimer();
    }

    protected function handleNewBall (...ignored) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        BingoItemManager.instance.removeFromRemainingTags(BingoMain.model.curState.ballInPlay);
        this.startNewBallTimer();
    }

    protected function showWinnerAnimation () :void
    {
        this.stopNewBallTimer();

        // destroy the bingo card view if it exists
        this.destroyObjectNamed(BingoCardController.NAME);

        var winnerId :int = BingoMain.model.curState.roundWinnerId;
        var winnerName :String = BingoMain.getPlayerName(winnerId);

        // the WinnerAnimationController will destroy itself when the animation is complete.
        // We check for the presence of the controller in update(), and when it's gone, we
        // start the next round.
        this.addObject(new WinnerAnimationController(winnerName), _gameUILayer);

        // grant some flow to ourselves if we're the winner
        if (BingoMain.model.curState.roundWinnerId == BingoMain.ourPlayerId && BingoMain.control.isConnected()) {
            BingoMain.control.quests.completeQuest("dummyString", null, 1);
        }

        // update scores
        if (null == _expectedScores) {
            _expectedScores = BingoMain.model.curScores.clone();
        }

        _expectedScores.incrementScore(winnerId, new Date());
        this.sendStateChanges();
    }

    protected function handleNewScores (...ignored) :void
    {
        // reset expected scores when they're updated on the server
        _expectedScores = null;
    }

    protected function handleBingoCalled (e :SharedStateChangedEvent) :void
    {
        // when Bingo is called, update the state
        var playerId :int = e.data as int;

        _expectedState = BingoMain.model.curState.clone();

        _expectedState.roundWinnerId = playerId;
        _expectedState.gameState = SharedState.STATE_WEHAVEAWINNER;

        this.sendStateChanges();
    }

    protected function startNewBallTimer () :void
    {
        this.stopNewBallTimer();
        this.addObject(new SimpleTimer(Constants.NEW_BALL_DELAY_S, handleNewBallTimerExpired, false, NEW_BALL_TIMER_NAME));
    }

    protected function stopNewBallTimer () :void
    {
        this.destroyObjectNamed(NEW_BALL_TIMER_NAME);
    }

    protected function handleNewBallTimerExpired () :void
    {
        _expectedState = BingoMain.model.curState.clone();

        // push a new ball update out
        _expectedState.ballInPlay = this.getNextBall();
        this.sendStateChanges();
    }

    protected function getNextBall () :String
    {
        var nextBall :String;
        do {
            nextBall = BingoItemManager.instance.getRandomTag();
        }
        while (nextBall == BingoMain.model.curState.ballInPlay);

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

    protected var _expectedState :SharedState;
    protected var _expectedScores :ScoreTable;

    protected var _calledBingoThisRound :Boolean;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const NEW_BALL_TIMER_NAME :String = "NewBallTimer";

}

}
