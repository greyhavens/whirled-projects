package vampire.fightproto.fight {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import vampire.client.SpriteUtil;
import vampire.fightproto.*;

public class FightMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        GameCtx.init();
        GameCtx.mode = this;

        GameCtx.bgLayer = new Sprite();
        GameCtx.characterLayer = new Sprite();
        GameCtx.uiLayer = new Sprite();
        _modeSprite.addChild(GameCtx.bgLayer);
        _modeSprite.addChild(GameCtx.characterLayer);
        _modeSprite.addChild(GameCtx.uiLayer);

        // background
        GameCtx.bgLayer.addChild(ClientCtx.instantiateBitmap("background"));

        // skill belt
        var skillBelt :SkillBelt = new SkillBelt();
        skillBelt.x = (Constants.SCREEN_SIZE.x - skillBelt.width) * 0.5;
        skillBelt.y = (Constants.SCREEN_SIZE.y - skillBelt.height - 5);
        addSceneObject(skillBelt, GameCtx.uiLayer);

        // player
        GameCtx.playerView = new PlayerView();
        GameCtx.playerView.x = PLAYER_LOC.x;
        GameCtx.playerView.y = PLAYER_LOC.y;
        addSceneObject(GameCtx.playerView, GameCtx.characterLayer);

        // baddies
        addBaddie(BaddieDesc.BABY_WEREWOLF);

        if (_baddies.length > 0) {
            Baddie(_baddies[0]).select();
        }

        DisplayUtil.sortDisplayChildren(GameCtx.characterLayer,
            function (a :DisplayObject, b :DisplayObject) :int {
                return (a.y - b.y);
            });
    }

    public function showSkillCastAnimation (skill :Skill, val :int, caster :SceneObject,
        target :SceneObject) :void
    {
        var sprite :Sprite = SpriteUtil.createSprite();

        var skillSprite :Sprite = skill.createSprite(new Point(30, 30), false);
        skillSprite.x = -skillSprite.width * 0.5;
        skillSprite.y = -skillSprite.height * 0.5;
        sprite.addChild(skillSprite);

        var tf :TextField =  TextBits.createText(
            (val > 0 ? "+ " + val : String(val)), 1.5, 0, (val > 0 ? 0x00ff00 : 0xff0000));
        tf.x = -tf.width * 0.5;
        tf.y = skillSprite.y - tf.height;
        sprite.addChild(tf);

        var srcX :Number;
        var srcY :Number;
        var dstX :Number;
        var dstY :Number;
        if (caster != target) {
            srcX = caster.x;
            srcY = caster.y - (caster.height * 0.5);
            dstX = target.x;
            dstY = target.y - (target.height * 0.5);
        } else {
            srcX = caster.x;
            srcY = caster.y - caster.height;
            dstX = caster.x;
            dstY = caster.y - caster.height - 20;
        }

        var animObj :SimpleSceneObject = new SimpleSceneObject(sprite);
        animObj.x = srcX;
        animObj.y = srcY;
        animObj.addTask(new SerialTask(
            LocationTask.CreateSmooth(dstX, dstY, 1),
            new SelfDestructTask()));
        addSceneObject(animObj, GameCtx.uiLayer);
    }

    protected function addBaddie (desc :BaddieDesc) :void
    {
        var baddie :Baddie = new Baddie(desc);
        var loc :Point =
            (_baddies.length < BADDIE_LOCS.length ? BADDIE_LOCS[_baddies.length] : new Point());
        baddie.x = loc.x;
        baddie.y = loc.y;
        addSceneObject(baddie, GameCtx.characterLayer);

        _baddies.push(baddie);
    }

    protected var _baddies :Array = [];

    protected static const PLAYER_LOC :Point = new Point(184, 453);
    protected static const BADDIE_LOCS :Array = [
        new Point(566, 405)
    ];

    protected static var log :Log = Log.getLog(FightMode);
}

}
