package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.events.Event;

import lawsanddisorder.*;

/**
 * Contains a turn indicator and button for ending the turn.  This component handles turn end as
 * well as turn start for the player.
 */
public class CreateLawButton extends Button
{
    /**
     * Constructor
     */
    public function CreateLawButton (ctx :Context)
    {
        super(ctx);
        text = "create law";
        addEventListener(MouseEvent.CLICK, createLawButtonClicked);
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_ENDED, turnEnded);
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_STARTED, turnStarted);
        enabled = false;
    }

    /**
     * When button is clicked, verify that player can begin law creation,
     * then display the new law area and update the button.
     */
    protected function createLawButtonClicked (event :MouseEvent) :void
    {
        if (!enabled) {
            return;
        }
        // Display the new law area
        if (text == "create law") {
            // TODO should already be enabled if this is true
            if (!_ctx.state.hasFocus()) {
                _ctx.notice("You can't create a law right now.");
                return;
            }
            _ctx.board.newLaw.show();
            text = "cancel";
        }
        // Cancel law creation - hide law area
        else {
            _ctx.board.newLaw.hide();
            text = "create law";
        }
    }

    /**
     * The player just created a new law; disabled this.
     */
    public function newLawCreated () :void
    {
        _ctx.board.newLaw.hide();
        text = "create law";
        enabled = false;
    }

    /**
     * Handler for end turn event
     */
    protected function turnStarted (event :Event) :void
    {
        enabled = true;
    }

    /**
     * Handler for end turn event
     */
    protected function turnEnded (event :Event) :void
    {
        _ctx.board.newLaw.hide();
        text = "create law";
        enabled = false;
    }
}
}