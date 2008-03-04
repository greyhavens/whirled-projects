package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.events.Event;

import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.StateChangedEvent;

import lawsanddisorder.*;

/**
 * Contains a turn indicator and button for ending the turn.  This component handles turn end as 
 * well as turn start for the player.
 */
public class EndTurnButton extends Button
{
    /**
     * Constructor
     */
    public function EndTurnButton (ctx :Context)
    {
        super(ctx);
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        addEventListener(MouseEvent.CLICK, endTurnButtonClicked);
        enabled = false;
        text = "end turn";
    }
	
    /**
     * Handler for end turn button
     */
    protected function endTurnButtonClicked (event :MouseEvent) :void
    {
		if (!enabled) {
			return;
		}
		
        if (!_ctx.state.interactMode) {
            _ctx.log("You can't end the turn right now.");
            return;
        }
        
        enabled = false;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.PLAYER_TURN_ENDED));
        
        _ctx.board.createLawButton.enabled = false;
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
    	_ctx.control.game.startNextTurn();
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
            _ctx.eventHandler.dispatchEvent(new Event(EventHandler.PLAYER_TURN_STARTED));
            _ctx.state.performingAction = true;
            _ctx.board.newLaw.enabled = true;
            _ctx.board.createLawButton.enabled = true;
            _ctx.board.player.jobEnabled = true;
            _ctx.board.player.powerEnabled = true;
            _ctx.board.player.hand.drawCard(2);
            _ctx.board.laws.triggerWhen(Card.START_TURN, _ctx.board.player.job.id);
            enabled = true;
        }
        else {
        	_ctx.notice(turnHolder.playerName + "'s turn.");
        }
        updateDisplay();
    }
}
}