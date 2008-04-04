package spades {

import com.whirled.game.GameControl;

import spades.card.Table;
import spades.card.Hand;
import spades.card.Trick;
import spades.card.Bids;
import spades.card.Scores;


/** Aggregates the various model objects used in a game of spades */
public class Model
{
    public function Model (
        table :Table,
        hand :Hand,
        trick :Trick,
        bids :Bids,
        scores :Scores)
    {
        _table = table;
        _hand = hand;
        _trick = trick;
        _bids = bids;
        _scores = scores;
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

    /** Access the bids. */
    public function get bids () :Bids
    {
        return _bids;
    }

    /** Access the scores. */
    public function get scores () :Scores
    {
        return _scores;
    }

    protected var _table :Table;
    protected var _hand :Hand;
    protected var _trick :Trick;
    protected var _bids :Bids;
    protected var _scores :Scores;
}

}
