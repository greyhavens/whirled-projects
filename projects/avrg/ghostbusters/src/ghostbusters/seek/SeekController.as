//
// $Id$

package ghostbusters.seek {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.Controller;
import com.whirled.AVRGameControl;

public class SeekController extends Controller
{
    public static const CLICK_GHOST :String = "ClickGhost";

    public function SeekController (control :AVRGameControl)
    {
        _control = control;

        _model = new SeekModel(control);
        var panel :SeekPanel = new SeekPanel(_model);
        _model.init(panel);

        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    public function getSeekPanel () :SeekPanel
    {
        return SeekPanel(_controlledPanel);
    }

    public function handleClickGhost () :void
    {
        // TODO: test state and whatnot
        if (_model.getGhostSpeed() < 10) {
            
            _model.transmitGhostSpawn();

        } else {
            _model.transmitGhostClick();
        }
    }

    protected var _control :AVRGameControl;
    protected var _model :SeekModel;
}
}
