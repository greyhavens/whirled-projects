package spades {

import com.whirled.game.GameControl;

import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.Hand;
import com.whirled.contrib.card.trick.Trick;
import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.TurnTimer;


/** Aggregates the various model objects used in a game of spades */
public class Model
{
    public function Model (
        gameCtrl :GameControl,
        table :Table,
        hand :Hand,
        trick :Trick,
        scores :Scores,
        timer :TurnTimer)
    {
        _gameCtrl = gameCtrl;
        _table = table;
        _hand = hand;
        _trick = trick;
        _scores = scores;
        _timer = timer;
    }

    /** Access the game control. */
    public function get gameCtrl () :GameControl
    {
        return _gameCtrl;
    }

    /** Access the table. */
    public function get table () :Table
    {
        return _table;
    }

    /** Access the hand. */
    public function get hand () :Hand
    {
        return _hand;
    }

    /** Access the trick. */
    public function get trick () :Trick
    {
        return _trick;
    }

    /** Access the scores. */
    public function get scores () :Scores
    {
        return _scores;
    }

    /** Access the timer. */
    public function get timer () :TurnTimer
    {
        return _timer;
    }

    protected var _gameCtrl :GameControl;
    protected var _table :Table;
    protected var _hand :Hand;
    protected var _trick :Trick;
    protected var _scores :Scores;
    protected var _timer :TurnTimer;
}

}
