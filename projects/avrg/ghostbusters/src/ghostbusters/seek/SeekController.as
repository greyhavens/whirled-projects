//
// $Id$

package ghostbusters.seek {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;
import ghostbusters.GameController;

public class SeekController extends Controller
{
    public static const ZAP_GHOST :String = "ZapGhost";

    public var panel :SeekPanel;
    public var model :SeekModel;

    public function SeekController (control :AVRGameControl)
    {
        _control = control;
        _control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);

        model = new SeekModel(control);
        panel = new SeekPanel(model);
        model.init(panel);

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function handleZapGhost () :void
    {
        // TODO: test state and whatnot
        if (model.getGhostSpeed() < 10) {
            CommandEvent.dispatch(panel, GameController.SPAWN_GHOST);

        } else {
            _control.state.sendMessage(Codes.MSG_GHOST_ZAP, model.getMyId());
        }
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_ZAP) {
            panel.ghostZapped();
            model.ghostZapped();
        }
    }

    protected var _control :AVRGameControl;
}
}
