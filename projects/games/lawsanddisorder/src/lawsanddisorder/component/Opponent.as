package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import lawsanddisorder.Context;
import com.threerings.ezgame.StateChangedEvent;

/**
 * Area containing details on a single player
 */
public class Opponent extends Player
{
    /**
     * Constructor
     * @param id Identifier for this player according to their position on the board
     * @param serverId Identifier for this player according to the game server
     */
    public function Opponent (ctx :Context, id :int, serverId :int, name :String)
    {
        addEventListener(MouseEvent.CLICK, ctx.state.opponentClick);
        super(ctx, id, serverId, name);
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
    }

    /**
     * Opponent jobs are not displayed; override and instead of making job a child, make
     * a new symbol child.
     */
    override public function set job (job :Job) :void
    {
        _job = job;

        if (symbol != null && contains(symbol)) {
            removeChild(symbol);
        }
        symbol = job.getSymbol();
        symbol.width = symbol.width / 3;
        symbol.height = symbol.height / 3;
        symbol.x = 90;
        symbol.y = 30;
        var colorTransform :ColorTransform = new ColorTransform();
        colorTransform.color = 0x000066;
        symbol.transform.colorTransform = colorTransform;
        symbol.alpha = 0.3;
        addChild(symbol);
        
        updateDisplay();
    }
    
    /**
     * Initialize the static display
     */
    override protected function initDisplay () :void
    {
    	// position hand but do not display it
        _hand.x = -550;
        _hand.y = 0;
        
        // draw the bg
        graphics.clear();
        graphics.beginFill(0x8888FF);
        graphics.drawRect(0, 0, 120, 60);
        graphics.endFill();
        
        title.height = 80;
    }

    /**
     * Update the changing display
     */
    override protected function updateDisplay () :void
    {
        title.text = playerName + "\nJob: " + job + "\nMonies: " + monies + "\nCards: " + hand.numCards;
    }
    
    /** Is this opponent selected? 
     * TODO rename to selected, find out where this is called that state can't be polled     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /** Indicate that the opponent is selected 
     * TODO does state need to be stored?     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
                
        // draw a border, highlighted or not
        if (value) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x8888FF);
        }
        graphics.drawRect(5, 5, 110, 50);
    }
    
    /**
     * The turn just changed.  Display whether it is this opponent's turn.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        var turnHolder :Player = _ctx.board.getTurnHolder();
        if (turnHolder == this) {
        	graphics.lineStyle(5, 0xFFFF00);
        }
        else {
        	graphics.lineStyle(5, 0x8888FF);
        }
        graphics.drawRect(0, 0, 120, 60);
    }
    
    /** Is the opponent highlighted? */
    protected var _highlighted :Boolean = false;
    
    /** Symbol for the current job */
    protected var symbol :Sprite;
}
}