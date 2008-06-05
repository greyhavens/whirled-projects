package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.data.SpellData;

public class SpellIntroMode extends AppMode
{
    override protected function setup () :void
    {
        var spellData :SpellData = GameContext.gameData.spells[GameContext.spLevel.newSpellType];

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
        g.drawRect(0, 0, 250, 1);
        g.endFill();

        this.modeSprite.addChild(bgSprite);

        // spell name
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.x = (bgSprite.width * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        tfName.text = "Infusion: " + spellData.displayName;

        bgSprite.addChild(tfName);

        // spell icon
        var icon :MovieClip = SwfResource.instantiateMovieClip("infusions", spellData.iconName);
        icon.scaleX = 3;
        icon.scaleY = 3;
        icon.x = 200;
        icon.y = 150;
        bgSprite.addChild(icon);

        // spell intro text
        var tfDesc :TextField = new TextField();
        tfDesc.selectable = false;
        tfDesc.multiline = true;
        tfDesc.wordWrap = true;
        tfDesc.autoSize = TextFieldAutoSize.LEFT;
        tfDesc.width = 150;
        tfDesc.x = 12;
        tfDesc.y = tfName.y + tfName.height + 3;

        tfDesc.text = spellData.introText;

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
        g.drawRect(0, 0, 250, bgSprite.height + 20);
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
