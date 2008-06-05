package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.view.UnitAnimationFactory;
import popcraft.data.UnitData;

public class CreatureIntroMode extends AppMode
{
    override protected function setup () :void
    {
        _creatureData = GameContext.gameData.units[GameContext.spLevel.newCreatureType];

        // draw dim background
        var dimness :Shape = new Shape();
        var g :Graphics = dimness.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        this.modeSprite.addChild(dimness);

        _movie = SwfResource.instantiateMovieClip("manual", "manual");
        _movie.x = Constants.SCREEN_DIMS.x * 0.5;
        _movie.y = Constants.SCREEN_DIMS.y * 0.5;
        this.modeSprite.addChild(_movie);

        var leftPage :MovieClip = _movie["pageL"];
        var rightPage :MovieClip = _movie["pageR"];

        // creature animation
        var creatureAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(
            _creatureData, GameContext.localPlayerInfo.playerColor, "walk_SW");
        if (null == creatureAnim) {
            creatureAnim = UnitAnimationFactory.instantiateUnitAnimation(
                _creatureData, GameContext.localPlayerInfo.playerColor, "stand_SW");
        }

        MovieClip(rightPage["image"]).addChild(creatureAnim);

        // creature intro text
        TextField(leftPage["text"]).text = _creatureData.introText;

        // Play button
        var button :SimpleTextButton = new SimpleTextButton("OK");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.x = (Constants.SCREEN_DIMS.x * 0.5) - (button.width * 0.5);
        button.y = 400;

        this.modeSprite.addChild(button);

        this.modeSprite.visible = false;
    }

    override protected function enter () :void
    {
        this.modeSprite.visible = true;

        AudioManager.instance.playSoundNamed("sfx_create_" + _creatureData.name);
    }

    override protected function exit () :void
    {
        this.modeSprite.visible = false;
    }

    protected var _movie :MovieClip;
    protected var _creatureData :UnitData;
}

}
