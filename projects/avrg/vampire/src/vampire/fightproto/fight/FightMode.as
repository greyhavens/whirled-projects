package vampire.fightproto.fight {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleTimer;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.fightproto.*;

public class FightMode extends AppMode
{
    public function skillSelected (skill :Skill) :void
    {
        log.info("Skill selected: " + skill.name);
        if (skill.cooldown > 0 && isSkillInCooldown(skill)) {
            log.info("Not casting skill (in cooldown): " + skill.name);
            return;
        }

        if (ClientCtx.player.energy < skill.energyCost) {
            log.info("Not casting skill (not enough energy): " + skill.name);
            return;
        }

        // CAST
        var eventText :EventText;
        var baddie :Baddie = Baddie.getSelectedBaddie();
        var damage :Number = skill.damageOutput.next();
        if (damage > 0) {
            baddie.curHealth -= damage;

            eventText = new EventText(
                "- " + damage,
                EventText.BAD,
                baddie.x, baddie.y - baddie.height);
            addSceneObject(eventText, GameCtx.uiLayer);
        }

        var health :Number = skill.healOutput.next();
        if (health > 0) {
            ClientCtx.player.offsetHealth(health);

            eventText = new EventText(
                "+ " + health,
                EventText.GOOD,
                GameCtx.playerView.x, GameCtx.playerView.y - GameCtx.playerView.height);
            addSceneObject(eventText, GameCtx.uiLayer);
        }

        // COOLDOWN
        if (skill.cooldown > 0) {
            addObject(new SimpleTimer(skill.cooldown, null, false, skill.name + "_cooldown"));
        }

        // ENERGY COST
        ClientCtx.player.offsetEnergy(-skill.energyCost);
    }

    public function getSkillCooldownTimeLeft (skill :Skill) :Number
    {
        var timer :SimpleTimer = getObjectNamed(skill.name + "_cooldown") as SimpleTimer;
        return (timer != null ? timer.timeLeft : 0);
    }

    public function isSkillInCooldown (skill :Skill) :Boolean
    {
        return (getSkillCooldownTimeLeft(skill) > 0);
    }

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
