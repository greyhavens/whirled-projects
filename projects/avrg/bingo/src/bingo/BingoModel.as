package bingo {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="newRound", type="bingo.BingoStateChangedEvent")]
[Event(name="newBall", type="bingo.BingoStateChangedEvent")]
[Event(name="playerWonRound", type="bingo.BingoStateChangedEvent")]
    
public class BingoModel extends EventDispatcher
{
    public function BingoModel ()
    {
    }
    
    public function setup () :void
    {
        _card = new BingoCard();
        this.trySetBingoBallInPlay(BingoItemManager.instance.getRandomTag());
    }
    
    public function destroy () :void
    {
    }
    
    public function callBingo () :void
    {
        this.playerWonRound(BingoMain.ourPlayerId);
    }
    
    protected function playerWonRound (playerId :int) :void
    {
        this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.PLAYER_WON_ROUND, playerId));
    }
    
    public function get roundId () :int
    {
        return _roundId;
    }
    
    public function trySetRoundId (newRoundId :int) :void
    {
        this.setRoundId(newRoundId);
    }
    
    protected function setRoundId (newRoundId :int) :void
    {
        if (newRoundId != _roundId + 1) {
            g_log.warning("got unexpected roundId (expected " + _roundId + 1 + ", got " + newRoundId + ")");
        }
        
        _roundId = newRoundId;
        
        // generate a new bingo card
        _card = new BingoCard();
        
        this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.NEW_ROUND));
    }
    
    public function get bingoBallInPlay () :String
    {
        return _bingoBallInPlay;
    }
    
    public function trySetBingoBallInPlay (newBall :String) :void
    {
        this.setBingoBallInPlay(newBall);
    }
    
    protected function setBingoBallInPlay (newBall :String) :void
    {
        _bingoBallInPlay = newBall;
        
        this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.NEW_BALL));
    }
    
    public function get card () :BingoCard
    {
        return _card;
    }
    
    // shared data
    protected var _roundId :int;
    protected var _bingoBallInPlay :String;
    protected var _timeTillNextBall :Number;
    
    // local data
    protected var _card :BingoCard;
    
    protected static var g_log :Log = Log.getLog(BingoModel);

}

}