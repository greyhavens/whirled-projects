package bingo {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // state change events
        BingoMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);
        BingoMain.model.addEventListener(SharedStateChangedEvent.BINGO_CALLED, handleBingoCalled);

        // visuals
        _hudView = new HUDController();
        this.addObject(_hudView, this.modeSprite);

        _winnerView = new WinnerAnimationController();
        this.addObject(_winnerView, this.modeSprite);
        _winnerView.visible = false;

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

        if (null != _cardView) {
            _cardView.destroySelf();
        }

        _hudView.destroySelf();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
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

        case SharedState.STATE_INVALID:
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
        // destroy the old card
        if (null != _cardView) {
            _cardView.destroySelf();
            _cardView = null;
        }

        // create a new card
        BingoMain.model.createNewCard();
        _cardView = new BingoCardController(BingoMain.model.card);
        this.addObject(_cardView, this.modeSprite);

        // reset tags
        BingoItemManager.instance.resetRemainingTags();

        // start the new ball timer
        BingoItemManager.instance.removeFromRemainingTags(BingoMain.model.curState.ballInPlay);
        this.startNewBallTimer();

        // @TODO - remove this
        _winnerView.visible = false;

        this.stopNewRoundTimer();
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
        this.startNewRoundTimer(); // a new round should start shortly

        // remove the bingo card
        if (null != _cardView) {
            _cardView.destroySelf();
            _cardView = null;
        }

        var playerName :String = BingoMain.getPlayerName(BingoMain.model.curState.roundWinnerId);

        _winnerView.playerName = playerName;
        _winnerView.visible = true;

        // update scores
        if (null == _expectedScores) {
            _expectedScores = BingoMain.model.curScores.clone();
        }

        _expectedScores.incrementScore(playerName, new Date());

        // grant some flow to the winner
        if (BingoMain.model.curState.roundWinnerId == BingoMain.ourPlayerId && BingoMain.control.isConnected()) {
            BingoMain.control.quests.completeQuest("dummyString", null, 1);
        }
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

    protected function startNewRoundTimer () :void
    {
        this.stopNewRoundTimer();
        this.addObject(new SimpleTimer(Constants.NEW_BALL_DELAY_S, handleNewRoundTimerExpired, false, NEW_ROUND_TIMER_NAME));
    }

    protected function stopNewRoundTimer () :void
    {
        this.destroyObjectNamed(NEW_ROUND_TIMER_NAME);
    }

    protected function handleNewRoundTimerExpired () :void
    {
        this.setupNewRound();
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

    protected var _expectedState :SharedState;
    protected var _expectedScores :Scoreboard;

    protected var _cardView :BingoCardController;
    protected var _hudView :HUDController;
    protected var _winnerView :WinnerAnimationController;

    protected var _calledBingoThisRound :Boolean;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const NEW_BALL_TIMER_NAME :String = "NewBallTimer";
    protected static const NEW_ROUND_TIMER_NAME :String = "NewRoundTimer";

}

}
