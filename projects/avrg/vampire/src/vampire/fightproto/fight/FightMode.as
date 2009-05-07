package vampire.fightproto.fight {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.fightproto.*;

public class FightMode extends AppMode
{
    public function skillSelected (skill :Skill) :void
    {
        log.info("Skill selected: " + skill.displayName);
    }

    override protected function setup () :void
    {
        super.setup();

        GameCtx.init();
        GameCtx.mode = this;

        _bgLayer = new Sprite();
        _characterLayer = new Sprite();
        _uiLayer = new Sprite();
        _modeSprite.addChild(_bgLayer);
        _modeSprite.addChild(_characterLayer);
        _modeSprite.addChild(_uiLayer);

        // background
        _bgLayer.addChild(ClientCtx.instantiateBitmap("background"));

        // skill belt
        var skillBelt :SkillBelt = new SkillBelt();
        skillBelt.x = (Constants.SCREEN_SIZE.x - skillBelt.width) * 0.5;
        skillBelt.y = (Constants.SCREEN_SIZE.y - skillBelt.height - 5);
        addSceneObject(skillBelt, _uiLayer);

        // player
        var player :PlayerView = new PlayerView();
        player.x = PLAYER_LOC.x;
        player.y = PLAYER_LOC.y;
        addSceneObject(player, _characterLayer);

        // baddies
        addBaddie(BaddieDesc.BABY_WEREWOLF);

        if (_baddies.length > 0) {
            Baddie(_baddies[0]).select();
        }

        DisplayUtil.sortDisplayChildren(_characterLayer,
            function (a :DisplayObject, b :DisplayObject) :int {
                return (a.y - b.y);
            });
    }

    protected function addBaddie (desc :BaddieDesc) :void
    {
        var baddie :Baddie = new Baddie(desc);
        var loc :Point =
            (_baddies.length < BADDIE_LOCS.length ? BADDIE_LOCS[_baddies.length] : new Point());
        baddie.x = loc.x;
        baddie.y = loc.y;
        addSceneObject(baddie, _characterLayer);

        _baddies.push(baddie);
    }

    protected var _baddies :Array = [];

    protected var _bgLayer :Sprite;
    protected var _characterLayer :Sprite;
    protected var _uiLayer :Sprite;

    protected static const PLAYER_LOC :Point = new Point(184, 453);
    protected static const BADDIE_LOCS :Array = [
        new Point(566, 405)
    ];

    protected static var log :Log = Log.getLog(FightMode);
}

}
