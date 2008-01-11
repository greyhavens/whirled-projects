//
// $Id$

package ghostbusters.seek {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.whirled.AVRGameControlEvent;

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GameController;

public class SeekController extends Controller
{
    public static const ZAP_GHOST :String = "ZapGhost";

    public var panel :SeekPanel;
    public var model :SeekModel;

    public function SeekController ()
    {
        Game.control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);

        model = new SeekModel();
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
        if (model.getGhostZest() < 0.05) {
            panel.appearGhost();

        } else {
            Game.control.state.sendMessage(Codes.MSG_GHOST_ZAP, Game.ourPlayerId);
        }
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_ZAP) {
            panel.ghostZapped();
            model.ghostZapped();
        }
    }
}
}
