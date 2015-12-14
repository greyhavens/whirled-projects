package {

import flash.display.Sprite;

import com.whirled.avrg.*;
import com.whirled.net.*;

public class Game extends Sprite
{
    public function Game ()
    {
        _ctrl = new AVRGameControl(this);

        // Cash out their dungeon keeper cred
        var newCredits :int = int(_ctrl.player.props.get(Codes.CREDITS));
        var allCredits :int = int(_ctrl.player.props.get(Codes.CREDITS_LIFETIME)) + newCredits;

        // Persist those credits for trophies
        if (newCredits > 0) {
            _ctrl.local.feedback("Business is booming! Your dungeons collected " +
                newCredits + " levels worth of kills while you were gone!");
            _ctrl.player.props.set(Codes.CREDITS_LIFETIME, allCredits);
            _ctrl.player.props.set(Codes.CREDITS, 0);
        }
        if (allCredits > 0) {
            _ctrl.local.feedback("In all time, your dungeons have produced " +
                allCredits + " levels worth of kills.");
        }

        _ctrl.local.feedback("Welcome to Whirleds and Wyverns! Join the community at http://www.whirled.com/#groups-d_3464");

        for (var c :int = newCredits; c > 0; c -= Codes.CREDIT_STEP) {
            _ctrl.player.completeTask("keeper", Math.min(c/Codes.CREDIT_STEP, 1));
        }
    }

    protected var _ctrl :AVRGameControl;
}

}
