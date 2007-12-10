//
// $Id$

package ghostbusters.seek {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.Controller;
import com.whirled.AVRGameControl;

public class SeekController extends Controller
{
    public static const CLICK_GHOST :String = "clickGhost";

    public static function newController (control :AVRGameControl) :SeekController
    {
        var model :SeekModel = new SeekModel(control);
        var panel :SeekPanel = new SeekPanel(model);
        return new SeekController(control, panel, model);
    }

    public function SeekController (control :AVRGameControl, panel :SeekPanel, model :SeekModel)
    {
        _control = control;
        _model = model;
        setControlledPanel(panel);
    }

    public function shutdown () :void
    {
    }

    protected function ghostClick (evt :MouseEvent) :void
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
