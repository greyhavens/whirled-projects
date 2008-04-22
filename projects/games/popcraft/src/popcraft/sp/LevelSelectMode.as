package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.*;

import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelSelectMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xB7B6B4);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = "PopCraft single player level select";
        tf.scaleX = 2;
        tf.scaleY = 2;
        tf.x = (this.modeSprite.width * 0.5) - (tf.width * 0.5);
        tf.y = 100;

        this.modeSprite.addChild(tf);

        var button :SimpleTextButton = new SimpleTextButton("Level 1");
        button.addEventListener(MouseEvent.CLICK, levelSelected);
        button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
        button.y = 200;

        this.modeSprite.addChild(button);

        button = new SimpleTextButton("Unit Anim Test");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.pushMode(new UnitAnimTestMode());
            });
        button.x = (this.modeSprite.width * 0.5) - (button.width * 0.5);
        button.y = 240;

        this.modeSprite.addChild(button);
    }

    protected function levelSelected (...ignored) :void
    {
        // @TEMP - construct a test level
        var xmlData :XML =
            <root>
                <Level name="Level 1" introText="This is level 1">
                    <AvailableUnits>
                        <Unit type="grunt"/>
                        <Unit type="heavy"/>
                    </AvailableUnits>
                    <Computer>
                        <InitialWaves>
                            <Wave delayBefore="30"><Unit type="grunt" count="1"/></Wave>
                        </InitialWaves>
                        <RepeatingWaves>
                            <Wave delayBefore="30"><Unit type="grunt" count="2"/></Wave>
                        </RepeatingWaves>
                    </Computer>
                </Level>
            </root>;


        // start the game
        GameContext.gameType = GameContext.GAME_TYPE_SINGLEPLAYER;
        GameContext.spLevel = LevelData.fromXml(xmlData);
        MainLoop.instance.changeMode(new GameMode());
    }

}

}
