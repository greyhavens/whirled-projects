package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import lawsanddisorder.*;

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
     * Add an opponent to the array of opponents
     */
    public function addOpponent (opponent :Opponent) :void
    {
        opponents.push(opponent);
        addChild(opponent);
        updateDisplay();
    }

    /**
     * Replace a human opponent with an ai opponent
     */
    public function replaceOpponent (opponent :Opponent, aiPlayer :AIPlayer) :void
    {
        var index :int = opponents.indexOf(opponent);
        opponents[index] = aiPlayer;
        //opponents.splice(index, 1);
        addChildAt(aiPlayer, getChildIndex(opponent));
        removeChild(opponent);
        updateDisplay();
    }
    
    /* public function removeOpponent (opponent :Opponent) :void
    {
        var index :int = opponents.indexOf(opponent);
        opponents.splice(index, 1);
        removeChild(opponent);
        updateDisplay();
    } */
    
    /**
     * Rearrange opponents when one is added or removed.
     */
    override protected function updateDisplay () :void
    {
        // position the opponents horizontally and display each
        for (var i :int = 0; i < opponents.length; i++) {
            var opponent :Opponent = opponents[i];
            opponent.x = 0;
            opponent.y = i*72;
        }
    }

    /**
     * Choose and return an opponent at random (from zero to length-1)
     */
    public function getRandomOpponent () :Opponent
    {
        var randomIndex :int = Math.round(Math.random() * (opponents.length-1));
        var opponent :Opponent = opponents[randomIndex];
        return opponent;
    }

    /** Array of opponent objects */
    protected var opponents :Array = new Array();
}
}