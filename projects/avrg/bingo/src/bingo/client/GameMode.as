package bingo.client {

import bingo.*;

import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.Sprite;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        ClientContext.gameMode = this;

        // setup visuals
        _gameUILayer = new Sprite();
        _helpLayer = new Sprite();

        this.modeSprite.addChild(_gameUILayer);
        this.modeSprite.addChild(_helpLayer);

        this.addObject(new HUDView(), _gameUILayer);
        this.addObject(new InGameHelpView(), _helpLayer);

        this.hideHelpScreen();

        // wire up event handlers with priority 1 to get state updates before UI controllers
        registerEventListener(ClientContext.model, SharedStateChangedEvent.GAME_STATE_CHANGED,
            handleGameStateChange, false, 1);
        registerEventListener(ClientContext.model, SharedStateChangedEvent.NEW_BALL,
            handleNewBall, false, 1);
        registerEventListener(ClientContext.model, SharedStateChangedEvent.NEW_SCORES,
            handleNewScores, false, 1);

        // get current game state
        var curState :SharedState = ClientContext.model.curState;

        handleGameStateChange();
    }

    protected function handleGameStateChange (...ignored) :void
    {
        switch (ClientContext.model.curState.gameState) {
        case SharedState.STATE_PLAYING:
            this.handleNewRound();
            break;

        case SharedState.STATE_WEHAVEAWINNER:
            this.handleRoundOver();
            break;
        }
    }

    protected function handleNewRound () :void
    {
        // destroy the winner animation if it exists
        this.destroyObjectNamed(WinnerAnimationView.NAME);

        // create a new card
        ClientContext.model.createNewCard();
        this.addObject(new BingoCardView(ClientContext.model.card), _gameUILayer);

        this.startNewBallTimer();

        _roundInPlay = true;
    }

    protected function handleNewBall (...ignored) :void
    {
        this.startNewBallTimer();
    }

    protected function handleRoundOver () :void
    {
        var numFilledSquares :int = ClientContext.model.card.numFilledSquares;
        var wonRound :Boolean =
                (ClientContext.model.curState.roundWinnerId == ClientContext.ourPlayerId);

        if (_roundInPlay && ClientContext.model.numPlayers > 1 && numFilledSquares > 0) {

            // if _roundInPlay is true, we didn't enter the game during the "we have a winner"
            // state, so count the round towards our total
            var trophies :HashSet = new HashSet();

            _roundsPlayed++;
            Trophies.getAccumulationTrophies(
                Trophies.ROUNDS_PLAYED_VALUES,
                Trophies.ROUNDS_PLAYED_PREFIX,
                _roundsPlayed,
                trophies);

            if (wonRound) {
                _roundsWon++;
                _roundsWonConsec++;

                Trophies.getAccumulationTrophies(
                    Trophies.ROUNDS_WON_VALUES,
                    Trophies.ROUNDS_WON_PREFIX,
                    _roundsWon,
                    trophies);

                Trophies.getAccumulationTrophies(
                    Trophies.ROUNDS_WON_CONSEC_VALUES,
                    Trophies.ROUNDS_WON_CONSEC_PREFIX,
                    _roundsWonConsec,
                    trophies);

                for each (var config :Array in ClientContext.model.card.winningConfigurations) {
                    Trophies.getBoardTrophies(config, trophies);
                }

            } else {
                // if we didn't win the round, tell the server how many squares we filled in
                // this round, so that we can get some consolation coins

                if (numFilledSquares > 0) {
                    ClientContext.gameCtrl.agent.sendMessage(Constants.MSG_CONSOLATIONPRIZE,
                        numFilledSquares);
                }
            }

            if (numFilledSquares > 0 && trophies.size() > 0) {
                ClientContext.gameCtrl.agent.sendMessage(Constants.MSG_WONTROPHIES,
                    trophies.toArray());
            }
        }

        if (!wonRound) {
            _roundsWonConsec = 0;
        }

        _roundInPlay = false;

        this.showWinnerAnimation();
    }

    protected function showWinnerAnimation () :void
    {
        this.stopNewBallTimer();

        // destroy the bingo card view if it exists
        this.destroyObjectNamed(BingoCardView.NAME);

        var winnerId :int = ClientContext.model.curState.roundWinnerId;
        var winnerName :String = ClientContext.getPlayerName(winnerId);

        // the WinnerAnimationController will destroy itself when the animation is complete.
        // We check for the presence of the controller in update(), and when it's gone, we
        // start the next round.
        this.addObject(new WinnerAnimationView(winnerName), _gameUILayer);
    }

    protected function handleNewScores (...ignored) :void
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

    protected var _roundInPlay :Boolean;
    protected var _roundsPlayed :int;
    protected var _roundsWon :int;
    protected var _roundsWonConsec :int;

    protected static var log :Log = Log.getLog(GameMode);

    protected static const NEW_BALL_TIMER_NAME :String = "NewBallTimer";

}

}
