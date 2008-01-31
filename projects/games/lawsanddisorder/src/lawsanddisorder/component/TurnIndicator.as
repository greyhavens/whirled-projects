package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.StateChangedEvent;

/**
 * Contains a turn indicator and button for ending the turn.  This component handles turn end as 
 * well as turn start for the player.
 */
public class TurnIndicator extends Component
{
    /**
     * Constructor
     */
    public function TurnIndicator (ctx :Context)
    {
        super(ctx);
        _ctx.control.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
    }
    
    /**
     * Draw the job area
     */
    override protected function initDisplay () :void
    {
        // draw the bg
        graphics.clear();
        graphics.beginFill(0x9955EE);
        graphics.drawRect(0, 0, 100, 70);
        graphics.endFill();
        
        // end turn button
        endTurnButton = new TextField();
        endTurnButton.text = "end turn";
        endTurnButton.x = 0;
        endTurnButton.y = 30;
        endTurnButton.height = 30;
        addChild(endTurnButton);
        
        title.height = 30;
    }
    
    /**
     * Update the display of the turn indicator and end turn button.
     * TODO highlight opponent or highlight hand instead of displaying "my turn"?
     */
    override protected function updateDisplay () :void
    {
    	var turnHolder :Player = _ctx.board.getTurnHolder();
    	if (turnHolder == null) {
    		return;
    	}
        if (turnHolder == _ctx.board.player) {
           title.text = "My turn";
           endTurnButton.addEventListener(MouseEvent.CLICK, endTurnButtonClicked);
           endTurnButton.textColor = 0x000000;
        }
        else {
            title.text = turnHolder.playerName + "'s turn";
            endTurnButton.removeEventListener(MouseEvent.CLICK, endTurnButtonClicked);
            endTurnButton.textColor = 0x999999;
        }
    }
    
    /**
     * Handler for end turn button
     */
    protected function endTurnButtonClicked (event :MouseEvent) :void
    {
        if (!_ctx.control.isMyTurn()) {
            _ctx.log("WTF not my turn to end turn.");
            return;
        }
        
        // TODO includes isMyTurn so remove check above
        if (!_ctx.state.interactMode) {
            return;
        }
        
        _ctx.board.newLaw.clear();
        _ctx.board.newLaw.enabled = false;
        _ctx.board.player.jobEnabled = false;
        _ctx.board.player.powerEnabled = false;
        _ctx.board.player.hand.discardDown(discardDownComplete);
    }
    
    /**
     * Called after player has finished discarding down to the maximum hand size
     * and may now complete their turn.
     */
    protected function discardDownComplete () :void
    {
    	_ctx.control.startNextTurn();
    }
    
    /**
     * Turn changed.  Draw 2 cards then trigger any START_TURN laws for this player's job.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
    	var turnHolder :Player = _ctx.board.getTurnHolder();
    	if (turnHolder == null) {
    		return;
    	}
        if (turnHolder == _ctx.board.player) {
            _ctx.notice("It's my turn.");
            _ctx.state.performingAction = true;
            _ctx.board.newLaw.enabled = true;
            _ctx.board.player.jobEnabled = true;
            _ctx.board.player.powerEnabled = true;
            _ctx.board.player.hand.drawCard(2);
            _ctx.board.laws.triggerWhen(Card.START_TURN, _ctx.board.player.job.id);
        }
        else {
        	_ctx.notice(turnHolder.playerName + "'s turn.");
        }
        updateDisplay();
    }
    
    /** Button for ending the turn */
    protected var endTurnButton :TextField;
}
}