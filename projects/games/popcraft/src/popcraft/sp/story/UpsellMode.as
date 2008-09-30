package popcraft.sp.story {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.game.GameControl;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;

public class UpsellMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var tf :TextField = new TextField();
        UIBits.initTextField(tf, "Buy this game or we'll shoot this zombie.", 3, 0, 0xFFFFFF);

        tf.x = (Constants.SCREEN_SIZE.x - tf.width) * 0.5;
        tf.y = (Constants.SCREEN_SIZE.y - tf.height) * 0.5;
        this.modeSprite.addChild(tf);

        var buy :SimpleButton = UIBits.createButton("Unlock!", 2);
        buy.x = Constants.SCREEN_SIZE.x - buy.width - 20;
        buy.y = Constants.SCREEN_SIZE.y - buy.height - 20;
        this.modeSprite.addChild(buy);
        registerOneShotCallback(buy, MouseEvent.CLICK, buyGame);

        var notNow :SimpleButton = UIBits.createButton("Not Now", 1.5);
        notNow.x = buy.x - notNow.width - 20;
        notNow.y = Constants.SCREEN_SIZE.y - notNow.height - 20;
        this.modeSprite.addChild(notNow);
        registerOneShotCallback(notNow, MouseEvent.CLICK, AppContext.mainLoop.popMode);
    }

    protected function buyGame () :void
    {
        AppContext.showGameShop();
        AppContext.mainLoop.popMode();
    }
}

}
