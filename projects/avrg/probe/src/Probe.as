package {

import flash.events.Event;

import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.probe.Button;
import com.whirled.contrib.avrg.probe.ButtonEvent;
import com.whirled.contrib.avrg.probe.ClientPanel;
import com.whirled.contrib.avrg.probe.ServerStub;

public class Probe extends ClientPanel
{
    public function Probe ()
    {
        super(new AVRGameControl(this));

        var close :Button = new Button("X");
        close.x = 330;
        close.y = 2;
        close.addEventListener(ButtonEvent.CLICK, handleClose);
        addChild(close);

        var shift :Button;
        shift = new Button("<", "l");
        shift.x = 310;
        shift.y = 2;
        shift.addEventListener(ButtonEvent.CLICK, handleShift);
        addChild(shift);

        shift = new Button(">", "r");
        shift.x = 317;
        shift.y = 2;
        shift.addEventListener(ButtonEvent.CLICK, handleShift);
        addChild(shift);

        var activate :Button = new Button("On/Off");
        activate.x = 260;
        activate.y = 2;
        activate.addEventListener(ButtonEvent.CLICK, function (...args) :void {
            _ctrl.agent.sendMessage(_active ? ServerStub.DEACTIVATE : ServerStub.ACTIVATE);
            _active = !_active;
        });
        addChild(activate);

        x = (_ctrl.local.getPaintableArea().width - width) / 2;
        y = 10;

        addEventListener(Event.REMOVED_FROM_STAGE, function (...args) :void {
            trace("Removed from stage: " + (new Error()).getStackTrace());
        });
    }

    protected function handleClose (event :ButtonEvent) :void
    {
        _ctrl.player.deactivateGame();
    }

    protected function handleShift (event :ButtonEvent) :void
    {
        var stageWidth :Number = _ctrl.local.getPaintableArea().width;
        var positions :Array = [0, 0.25, 0.5, 0.75, 1.0];

        function xpos (pos :Number) :Number {
            return 10 + pos * (stageWidth - width - 20);
        }

        var idx :int = -1;
        var fit :Number;
        for (var ii :int = 0; ii < positions.length; ++ii) {
            if (idx == -1 || Math.abs(x - xpos(positions[ii])) < fit) {
                fit = Math.abs(x - xpos(positions[ii]));
                idx = ii;
            }
        }

        var dir :int = event.action == "l" ? -1 : 1;
        idx = (idx + dir + positions.length) % positions.length;
        x = xpos(positions[idx]);
    }

    protected var _active :Boolean;
}

}
