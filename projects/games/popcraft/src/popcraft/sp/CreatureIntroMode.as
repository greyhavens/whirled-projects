package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.battle.view.UnitAnimationFactory;
import popcraft.data.UnitData;

public class CreatureIntroMode extends AppMode
{
    override protected function setup () :void
    {
        var creatureData :UnitData = GameContext.gameData.units[GameContext.spLevel.newCreatureType];

        // draw dim background
        var dimness :Shape = new Shape();
        var g :Graphics = dimness.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        this.modeSprite.addChild(dimness);

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, 450, 1);
        g.endFill();

        this.modeSprite.addChild(bgSprite);

        // creature name
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.x = (bgSprite.width * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        tfName.text = "The " + creatureData.displayName;

        bgSprite.addChild(tfName);

        // creature animation
        var creatureAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(
            creatureData, GameContext.localPlayerInfo.playerColor, "walk_SW");
        if (null == creatureAnim) {
            creatureAnim = UnitAnimationFactory.instantiateUnitAnimation(
                creatureData, GameContext.localPlayerInfo.playerColor, "stand_SW");
        }

        if (null != creatureAnim) {
            creatureAnim.scaleX = 1.5;
            creatureAnim.scaleY = 1.5;
            creatureAnim.x = 400;
            creatureAnim.y = 150;

            bgSprite.addChild(creatureAnim);
        }

        // creature intro text
        var tfDesc :TextField = new TextField();
        tfDesc.selectable = false;
        tfDesc.multiline = true;
        tfDesc.wordWrap = true;
        tfDesc.autoSize = TextFieldAutoSize.LEFT;
        tfDesc.width = 300;
        tfDesc.scaleX = 1.2;
        tfDesc.scaleY = 1.2;
        tfDesc.x = 12;
        tfDesc.y = tfName.y + tfName.height + 3;

        tfDesc.text = creatureData.introText;

        bgSprite.addChild(tfDesc);

        // Play button
        var button :SimpleTextButton = new SimpleTextButton("OK");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = tfDesc.y + tfDesc.height + 8;

        bgSprite.addChild(button);

        // draw the background
        g = bgSprite.graphics;
        g.beginFill(0xCCCCCC);
        g.drawRect(0, 0, 450, bgSprite.height + 20);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_DIMS.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_DIMS.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.visible = false;
    }

    override protected function enter () :void
    {
        this.modeSprite.visible = true;
    }

    override protected function exit () :void
    {
        this.modeSprite.visible = false;
    }
}

}
