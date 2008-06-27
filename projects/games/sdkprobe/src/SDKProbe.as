package {

import flash.display.Sprite;
import flash.text.TextField;
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

        _tabPanel.addTab("test", new Button("Test"), new TestPanel());
        _tabPanel.addTab("game", new Button("Game"), new GamePanel(_ctrl));
    }

    protected var _ctrl :GameControl;
    protected var _tabPanel :TabPanel;
}

}

