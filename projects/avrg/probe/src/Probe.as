package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import com.whirled.avrg.AVRGameControl;
import com.whirled.net.MessageReceivedEvent;
import com.threerings.util.StringUtil;

public class Probe extends Sprite
{
    public function Probe ()
    {
        _ctrl = new AVRGameControl(this);
        _tabPanel = new TabPanel();
        addChild(_tabPanel);

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

        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, 350, 250);
        graphics.endFill();

        x = (_ctrl.local.getStageSize().width - width) / 2;
        y = 10;

        var defs :Definitions = new Definitions(_ctrl);

        _tabPanel.addTab("test", new Button("Test"), new TestPanel());

        var client :TabPanel = new TabPanel();
        _tabPanel.addTab("client", new Button("Client"), client);

        var key :String;
        for each (key in defs.getFuncKeys(false)) {
            client.addTab(key, new Button(key.substr(0, 1).toUpperCase() + key.substr(1)), 
                new FunctionPanel(_ctrl, defs.getFuncs(key), false));
        }

        var server :TabPanel = new TabPanel();
        _tabPanel.addTab("server", new Button("Server"), server);

        for each (key in defs.getFuncKeys(true)) {
            server.addTab(key, new Button(key.substr(6)), 
                new FunctionPanel(_ctrl, defs.getFuncs(key), true));
        }

        defs.addListenerToAll(logEvent);

        _ctrl.player.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, 
            handleGameMessage);
    }

    protected function handleGameMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == Server.BACKEND_CALL_RESULT) {
            _ctrl.local.feedback(
                "Result received from server agent: " + StringUtil.toString(evt.value));

        } else if (evt.name == Server.CALLBACK_INVOKED) {
            _ctrl.local.feedback(
                "Callback invoked on server agent: " + StringUtil.toString(evt.value));
        }
    }

    protected function logEvent (event :Event) :void
    {
        _ctrl.local.feedback(String(event));
    }

    protected function handleClose (event :ButtonEvent) :void
    {
        _ctrl.player.deactivateGame();
    }

    protected function handleShift (event :ButtonEvent) :void
    {
        var stageWidth :Number = _ctrl.local.getStageSize().width;
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

    protected var _ctrl :AVRGameControl;
    protected var _tabPanel :TabPanel;
}

}
