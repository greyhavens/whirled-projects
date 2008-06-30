package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import com.whirled.game.GameControl;

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
            new FunctionPanel(_ctrl.game, defs.getGameFuncs()));
        _tabPanel.addTab("seating", new Button("Seating"), 
            new FunctionPanel(_ctrl.game.seating, defs.getSeatingFuncs()));
        _tabPanel.addTab("net", new Button("Net"), 
            new FunctionPanel(_ctrl.net, defs.getNetFuncs()));

        defs.addListenerToAll(logEvent);
    }

    protected function logEvent (event :Event) :void
    {
        _ctrl.local.feedback(String(event));
    }

    protected var _ctrl :GameControl;
    protected var _tabPanel :TabPanel;
}

}

