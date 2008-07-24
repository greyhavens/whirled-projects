package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import com.whirled.AVRGameControl;
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

        _tabPanel.addTab("test", new Button("Test"), new TestPanel());
    }

    protected function logEvent (event :Event) :void
    {
    }

    protected function handleClose (event :ButtonEvent) :void
    {
        _ctrl.deactivateGame();
    }

    protected var _ctrl :AVRGameControl;
    protected var _tabPanel :TabPanel;
}

}

