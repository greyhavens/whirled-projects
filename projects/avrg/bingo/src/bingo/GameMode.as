package bingo {

import com.whirled.contrib.simplegame.*;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        // state change events
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.model.addEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);
        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);

        // visuals
        _hudController = new HUDController();

        _winnerText = new TextField();
        _winnerText.autoSize = TextFieldAutoSize.LEFT;
        _winnerText.textColor = 0x0000FF;
        _winnerText.scaleX = 3;
        _winnerText.scaleY = 3;
        _winnerText.x = Constants.WINNER_TEXT_LOC.x;
        _winnerText.y = Constants.WINNER_TEXT_LOC.y;

        this.modeSprite.addChild(_winnerText);

        // each client maintains the concept of an expected state,
        // so that it is prepared to take over as the
        // authoritative client at any time.
        _expectedState = null;

        this.handleNewRound(null);
    }

    override protected function destroy () :void
    {
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_ROUND, handleNewRound);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, handleNewBall);
        BingoMain.model.removeEventListener(SharedStateChangedEvent.PLAYER_WON_ROUND, handlePlayerWonRound);

        _hudController.destroy();
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

    protected function createNewCard () :void
    {
        if (null != _cardView) {
            this.modeSprite.removeChild(_cardView);
        }

        BingoMain.model.createNewCard();

        _cardView = new BingoCardView(BingoMain.model.card);
        this.modeSprite.addChild(_cardView);
    }

    protected function handleNewRound (e :SharedStateChangedEvent) :void
    {
        this.createNewCard();

        BingoItemManager.instance.resetRemainingTags();

        // reset the expected state when the state changes
        _expectedState = null;

        // does a ball exist?
        if (null != BingoMain.model.curState.ballInPlay) {
            this.startNewBallTimer();
        } else {
            // create a ball immediately
            this.createNewBall();
        }

        _winnerText.text = "";

        this.stopNewRoundTimer();
    }

    protected function handleNewBall (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        BingoItemManager.instance.removeFromRemainingTags(BingoMain.model.curState.ballInPlay);

        this.startNewBallTimer();
    }

    protected function handlePlayerWonRound (e :SharedStateChangedEvent) :void
    {
        // reset the expected state when the state changes
        _expectedState = null;

        this.stopNewBallTimer();
        this.startNewRoundTimer(); // a new round should start shortly

        var playerName :String = BingoMain.getPlayerName(BingoMain.model.curState.roundWinnerId);

        _winnerText.text = playerName + " wins the round!";

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

    protected function handleNewScores (e :SharedStateChangedEvent) :void
    {
        _expectedScores = null;
    }

    protected function startNewBallTimer () :void
    {
        this.stopNewBallTimer();
        this.createTimer(Constants.NEW_BALL_DELAY_S, handleNewBallTimerExpired, false, NEW_BALL_TIMER_NAME);
    }

    protected function stopNewBallTimer () :void
    {
        this.destroyObjectNamed(NEW_BALL_TIMER_NAME);
    }

    protected function handleNewBallTimerExpired () :void
    {
        this.createNewBall();
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

    protected function createNewBall () :void
    {
        if (null == _expectedState) {
            _expectedState = BingoMain.model.curState.clone();
        }

        // push a new ball update out
        _expectedState.ballInPlay = this.getNextBall();
        this.sendStateChanges();
    }

    protected function startNewRoundTimer () :void
    {
        this.stopNewRoundTimer();
        this.createTimer(Constants.NEW_ROUND_DELAY_S, handleNewRoundTimerExpired, false, NEW_ROUND_TIMER_NAME);
    }

    protected function stopNewRoundTimer () :void
    {
        this.destroyObjectNamed(NEW_ROUND_TIMER_NAME);
    }

    protected function handleNewRoundTimerExpired () :void
    {
        if (null == _expectedState) {
            _expectedState = BingoMain.model.curState.clone();
        }

        // push a new round update out
        _expectedState.roundId += 1;
        _expectedState.roundWinnerId = 0;
        _expectedState.ballInPlay = this.getNextBall();
        this.sendStateChanges();
    }

    protected var _expectedState :SharedState;
    protected var _expectedScores :Scoreboard;

    protected var _cardView :BingoCardView;
    protected var _hudController :HUDController;
    protected var _winnerText :TextField;

    protected var _calledBingoThisRound :Boolean;

    protected static const NEW_BALL_TIMER_NAME :String = "NewBallTimer";
    protected static const NEW_ROUND_TIMER_NAME :String = "NewRoundTimer";

}

}
