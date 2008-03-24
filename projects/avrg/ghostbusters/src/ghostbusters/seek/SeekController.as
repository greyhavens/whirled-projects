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

    public function SeekController ()
    {
        panel = new SeekPanel();

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function handleZapGhost () :void
    {
        Game.control.state.sendMessage(Codes.MSG_GHOST_ZAP, Game.ourPlayerId);
    }
}
}
