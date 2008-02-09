package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;

import lawsanddisorder.Context;

/**
 * Area containing list of opposing players
 */
public class Opponents extends Component
{
    /**
     * Constructor
     */
    public function Opponents (ctx :Context)
    {
        super(ctx);
    }
    
    /**
     * Add a player to the array of players
     */
    public function addOpponent (opponent :Opponent) :void
    {
        if (opponents.indexOf(opponent) < 0) {
             opponents.push(opponent);
             addChild(opponent);
        }
        else {
            _ctx.log("WTF opponents already contains player!");
        }
        updateDisplay();
    }
    
    /**
     * Rearrange opponents when one is added
     * TODO will opponents be changing during the game?  Or just added during init?
     */
    override protected function updateDisplay () :void
    {
        // position the opponents horizontally and display each
        for (var i :int = 0; i < opponents.length; i++) {
            var opponent :Opponent = opponents[i];
            opponent.x = 0;
            opponent.y = i*65;
        }
    }
    
    /** Array of players */
    protected var opponents :Array = new Array();
}
}