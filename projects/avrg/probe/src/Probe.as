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
        close.y = 5;
        close.addEventListener(ButtonEvent.CLICK, handleClose);
        addChild(close);

        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, 350, 250);
        graphics.endFill();

        x = 10;
        y = 10;

        var defs :Definitions = new Definitions(_ctrl);

        _tabPanel.addTab("test", new Button("Test"), new TestPanel());
        _tabPanel.addTab("game", new Button("Game"), 
            new FunctionPanel(_ctrl, defs.getGameFuncs()));
        _tabPanel.addTab("room", new Button("Room"), 
            new FunctionPanel(_ctrl, defs.getRoomFuncs()));
        _tabPanel.addTab("player", new Button("Player"), 
            new FunctionPanel(_ctrl, defs.getPlayerFuncs()));

        defs.addListenerToAll(logEvent);

        _ctrl.game.addEventListener(
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

    protected var _ctrl :AVRGameControl;
    protected var _tabPanel :TabPanel;
}

}
