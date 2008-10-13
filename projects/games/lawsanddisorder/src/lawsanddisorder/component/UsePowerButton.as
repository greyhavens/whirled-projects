package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.events.Event;

import lawsanddisorder.*;

/**
 * Clicked to use a job's power.
 */
public class UsePowerButton extends Button
{
    /**
     * Constructor
     */
    public function UsePowerButton (ctx :Context)
    {
        super(ctx);
        text = DEFAULT_TEXT;
        addEventListener(MouseEvent.CLICK, usePowerButtonClicked);
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_ENDED, turnEnded);
        _ctx.eventHandler.addEventListener(EventHandler.MY_TURN_STARTED, turnStarted);
        _ctx.eventHandler.addEventListener(Job.MY_POWER_USED, doneUsingPower);
        enabled = false;
    }

    /**
     * When button is clicked, verify that player can use their power,
     * then start doing that.
     */
    protected function usePowerButtonClicked (event :MouseEvent) :void
    {
        if (!enabled) {
            return;
        }
        // Start using power; switch to cancel
        if (text == DEFAULT_TEXT) {
            // TODO should already be enabled if this is true
            if (!_ctx.state.hasFocus()) {
                _ctx.notice("You can't use your power right now.");
                return;
            }
            text = CANCEL_TEXT;
            _ctx.player.job.usePower();
        }
        // Cancel using power
        else {
            text = DEFAULT_TEXT;
            _ctx.player.job.cancelUsePower();
        }
    }

    /**
     * Player has finished using their ability, or has passed the point of no return.
     * Set the text back to use power and disable it for the rest of the turn.
     */
    public function doneUsingPower (event :Event = null) :void
    {
        text = DEFAULT_TEXT;
        enabled = false;
    }

    /**
     * Player cancelled using their power; set text back to the default but leave it enabled.
     */
    public function cancelUsingPower () :void
    {
        text = DEFAULT_TEXT;
    }

    /**
     * Handler for start turn event
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
        text = DEFAULT_TEXT;
        enabled = false;
    }

    protected static const DEFAULT_TEXT :String = "use power";
    protected static const CANCEL_TEXT :String = "cancel";
}
}