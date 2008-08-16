package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;
import com.threerings.util.StringUtil;

public class SDKProbe extends Sprite
{
    function SDKProbe ()
    {
        _ctrl = new GameControl(this);
        //_output = new TextField();
        _tabPanel = new TabPanel();
        addChild(_tabPanel);

        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, 700, 500);
        graphics.endFill();

        var defs :Definitions = new Definitions(_ctrl);

        _tabPanel.addTab("test", new Button("Test"), new TestPanel());
        _tabPanel.addTab("game", new Button("Game"), 
            new FunctionPanel(_ctrl, defs.getGameFuncs()));
        _tabPanel.addTab("seating", new Button("Seating"), 
            new FunctionPanel(_ctrl, defs.getSeatingFuncs()));
        _tabPanel.addTab("net", new Button("Net"), 
            new FunctionPanel(_ctrl, defs.getNetFuncs()));
        _tabPanel.addTab("player", new Button("Player"), 
            new FunctionPanel(_ctrl, defs.getPlayerFuncs()));
        _tabPanel.addTab("services", new Button("Services"), 
            new FunctionPanel(_ctrl, defs.getServicesFuncs()));
        _tabPanel.addTab("bags", new Button("Bags"), 
            new FunctionPanel(_ctrl, defs.getBagsFuncs()));
        _tabPanel.addTab("messages", new Button("Messages"), 
            new FunctionPanel(_ctrl, defs.getMessageFuncs()));

        defs.addListenerToAll(logEvent);

        _ctrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, 
            handleMessage);
    }

    protected function handleMessage (evt :MessageReceivedEvent) :void
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

    protected var _ctrl :GameControl;
    protected var _tabPanel :TabPanel;
}

}

