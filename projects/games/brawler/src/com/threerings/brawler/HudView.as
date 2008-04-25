package com.threerings.brawler {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import com.threerings.util.StringUtil;

import com.threerings.brawler.actor.Player;
import com.threerings.brawler.actor.Weapon;
import com.threerings.brawler.util.BrawlerUtil;

/**
 * Displays the Brawler HUD.
 */
public class HudView extends Sprite
{
    public function HudView (ctrl :BrawlerController, view :BrawlerView, hud :MovieClip)
    {
        _ctrl = ctrl;
        _view = view;
        addChild(_hud = hud);
    }

    /**
     * Called by the view to initialize the hud.
     */
    public function init () :void
    {
        // initialize states
        _hud.respawn.state = "off";
        _hud.fader.gotoAndStop("out");
        _hud.fader.addEventListener("animationComplete", handleFadeComplete);
		_hud.zoneclear_off.mouseEnabled = false;
		_hud.zoneclear.mouseEnabled = false;
		_hud.zoneclear_off.scaleX = 0.1;
		_hud.zoneclear_off.scaleY = 0.1;
		_hud.zoneclear.scaleX = 0.1;
		_hud.zoneclear.scaleY = 0.1;

        // update the room
        updateRoom();

        // update the connection display
        updateConnection();

        // update the all-clear display
        updateClear();

        // if we're not playing, there's not much to show
        if (!_ctrl.amPlaying) {
            _hud.stats.visible = false;
            _hud.score.visible = false;
            return;
        }

        // update the score
        updateScore();

        // update the hit count
        updateHits();
    }

    /**
     * Called by the view on every frame.
     */
    public function enterFrame (elapsed :Number) :void
    {
        // make sure we've created the local player
        var self :Player = _ctrl.self;
        if (self == null) {
            return;
        }
        // update the hit point display
        _hud.stats.hpnum.text = Math.round(self.hp);
        var frame :Number = Math.round((self.hp / self.maxhp) * 100) + 1;
        if (_hud.stats.hp.bar.currentFrame >= frame) {
            _hud.stats.hp.bar.gotoAndStop(frame);
        } else {
            _hud.stats.hp.bar.nextFrame();
        }
        if (_hud.stats.hp.dmg.currentFrame <= frame) {
            _hud.stats.hp.dmg.gotoAndStop(frame);
            _hud.stats.hp.gotoAndStop(2);
        } else {
            _hud.stats.hp.dmg.prevFrame();
            _hud.stats.hp.gotoAndStop(1);
        }

        // display the warning if appropriate
        setState(_hud.hp_warning, (frame <= 20 && !self.dead) ? "on" : "off");

        // update the weapon display
        setState(_hud.stats.exp.weapon.weapon, Weapon.FRAME_LABELS[self.weapon]);

		// update the energy display (the "depleted" frames follow the normal ones)
        var pct :Number = Math.round(self.energy);
        _hud.stats.energy.gotoAndStop((self.depleted ? 101 : 0) + pct + 1);
        _hud.stats.energy.num.text = pct + "%";

        // display the energy warning if depleted
        setState(_hud.energy_warning, self.depleted ? "on" : "off");

        // update the experience display
        var exp :Number = Math.round(self.experience) + 1;
        if (_hud.stats.exp.currentFrame < exp) {
            _hud.stats.exp.nextFrame();
        } else if (_hud.stats.exp.currentFrame > exp) {
            _hud.stats.exp.prevFrame();
        }

        // update the attack bar
        var level :int = self.attackLevel + 1;
        for (var ii :int = 1; ii <= PUNCH_LEVELS; ii++) {
            setState(_hud.attacks["p" + ii], (level < ii) ? "off" : (level == ii ? "next" : "on"));
        }
        level = Math.floor(level * (KICK_LEVELS / PUNCH_LEVELS));
        for (ii = 1; ii <= KICK_LEVELS; ii++) {
            setState(_hud.attacks["k" + ii], (level < ii) ? "off" : (level == ii ? "next" : "on"));
        }
        setState(_hud.attacks.pk, (self.experience == Player.MAX_EXPERIENCE) ? "on" : "off");

        // update the respawn clock
        var respawn :int = self.respawnCountdown;
        if (respawn > 0) {
            setState(_hud.respawn, "on");
            _hud.dc.text = StringUtil.prepad(respawn.toString(), 2, "0");
            _hud.dc.visible = true;

        } else {
            setState(_hud.respawn, "off");
            _hud.dc.visible = false;
        }
    }

    /**
     * Fades in or out.
     */
    public function fade (type :String, callback :Function = null) :void
    {
        if (_fadeType == type) {
            return;
        }
        _hud.fader.gotoAndPlay(_fadeType = type);
    }

    /**
     * Updates the connection display.
     */
    public function updateConnection () :void
    {
        _hud.connection.text = _ctrl.control.game.amInControl() ? "Host" : "Client";
    }

    /**
     * Sets the messages per second display.
     */
    public function updateMPS (mps :Number) :void
    {
        _hud.mps_output.text = "MPS: " + mps;
        _hud.mps_output.textColor = (mps >= 8) ? 0xFF0000 : 0xFFFFFF;
    }

    /**
     * Updates the throttled message queue length display.
     */
    public function updateTBS () :void
    {
        _hud.tbs_output.text = _ctrl.throttle.enqueued;
    }

    /**
     * Sets the frames per second display.
     */
    public function updateFPS (fps :Number) :void
    {
        _hud.fps_output.text = "FPS: " + fps;
        _hud.fps_output.textColor = (fps < 20) ? 0xFF0000 : 0xFFFFFF;
    }

    /**
     * Updates the clock display.
     */
    public function updateClock () :void
    {
        var minutes :Number = Math.floor(_ctrl.clock / 60);
        var seconds :String = (_ctrl.clock % 60).toString();
        _hud.time.text = minutes + "'" + StringUtil.prepad(seconds, 2, "0") + "''";
		_hud.score_par.text = (_ctrl.calculateGrade("damage"));
		_hud.score_time.text = (_ctrl.calculateGrade("time"));
		_hud.score_grade.text = _ctrl.calculateGrade()+"%";

		var self :Player = _ctrl.self;
        if (self == null) {
            return;
        }

		if (_ctrl.difficulty_setting != "Easy"){
			if(self.blocking && _ctrl.timeSpentBlocking_awarded != true){
				_ctrl.timeSpentBlocking += 1;
				if(_ctrl.timeSpentBlocking >= _ctrl.timeSpentBlocking_goal && _ctrl.timeSpentBlocking_awarded != true){
					_ctrl.control.player.awardTrophy("cautious");
					_ctrl.timeSpentBlocking_awarded = true;
				}
			}
			if(_ctrl.lemmingCount >= _ctrl.lemmingCount_goal && _ctrl.lemmingCount_awarded != true){
				_ctrl.control.player.awardTrophy("lemming");
				_ctrl.lemmingCount_awarded = true;
			}
			if(_ctrl.damageTaken >= _ctrl.damageTaken_goal && _ctrl.damageTaken_awarded != true){
				_ctrl.control.player.awardTrophy("battle_scarred");
				_ctrl.damageTaken_awarded = true;
			}
			if(_ctrl.coinsCollected >= _ctrl.coinsCollected_goal && _ctrl.coinsCollected_awarded != true){
				_ctrl.control.player.awardTrophy("extra_life");
				_ctrl.coinsCollected_awarded = true;
			}
			if(_ctrl.weaponsBroken >= _ctrl.weaponsBroken_goal && _ctrl.weaponsBroken_awarded != true){
				_ctrl.control.player.awardTrophy("entropy");
				_ctrl.weaponsBroken_awarded = true;
			}
			if(_ctrl.weaponsCollected >= _ctrl.weaponsCollected_goal && _ctrl.weaponsCollected_awarded != true){
				_ctrl.control.player.awardTrophy("arms_dealer");
				_ctrl.weaponsCollected_awarded = true;
			}
		}
    }

    /**
     * Returns the contents of the clock display.
     */
    public function get clock () :String
    {
        return _hud.time.text;
    }

    /**
     * Updates the score.
     */
    public function updateScore (increment :int = 0) :void
    {
        _hud.score.text = _ctrl.score;
        if (increment > 0) {
            _hud.score_add.score_add.score_add.text = "+" + increment;
            _hud.score_add.gotoAndPlay("go");
        }
    }

    /**
     * Updates the hit count.
     */
    public function updateHits () :void
    {
        var hits :int = (_ctrl.self == null) ? 0 : _ctrl.self.hits;
        if (hits > 0) {
            _hud.hitcounter.num.hits.text = hits;
            _hud.hitcounter.gotoAndPlay("go");
        } else {
            _hud.hitcounter.gotoAndStop("stop");
        }
    }

    /**
     * Updates the room display.
     */
    public function updateRoom () :void
    {
        _hud.zone.text = _hud.levelname.text + " - ZONE " + _ctrl.room;
    }

    /**
     * Updates the all-clear display.
     */
    public function updateClear () :void
    {
		if(_ctrl.clear){
			if(_hud.go.playthrough != true){
				_hud.go.playthrough = true;
				_hud.go.gotoAndPlay(1);
			}
		}else{
			_hud.go.playthrough = false;
		}
        _hud.go.visible = _ctrl.clear;
    }

    /**
     * Adds a blip to the radar display.
     */
    public function addRadarBlip (blip :Sprite) :void
    {
        _hud.radar.view.addChild(blip);
    }

    /**
     * Removes a blip from the radar display.
     */
    public function removeRadarBlip (blip :Sprite) :void
    {
        _hud.radar.view.removeChild(blip);
    }

    /**
     * Updates the position of a radar blip, given the x coordinate of its target.
     */
    public function updateRadarBlip (blip :Sprite, x :Number) :void
    {
        blip.x = (x / _view.ground.width) * 200;
        blip.y = 0;
    }

    /**
     * Shows that the player's weapon has been damaged.
     */
    public function weaponDamaged () :void
    {
        // returns to idle after showing damage effect
        _hud.stats.exp.weapon.gotoAndPlay("damage");
    }

	/**
     * Flash PICKUP image for new weapon.
     */
    public function showPickUp(weaponX:Number) :void
    {
		var self :Player = _ctrl.self;
        if (self == null) {
            return;
        }
		var local :Point = self.parent.localToGlobal(new Point(weaponX, 0));
		_hud.pickup.x = local.x;
        if(_hud.pickup.currentFrame > 14){
				_hud.pickup.gotoAndPlay(1);
		}
    }

	/**
     * Toggle Zone Clear results.
     */
    public function zoneClear(off:Boolean = false) :void
    {
		if(off){
			_hud.zoneclear_off.scaleX = 1.0;
			_hud.zoneclear_off.scaleY = 1.0;
			_hud.zoneclear.scaleX = 0.1;
			_hud.zoneclear.scaleY = 0.1;
			_hud.zoneclear_off.alpha = 1;

			//_hud.zoneclear.alpha = 0;
			_hud.zoneclear.alpha = 1;
			_hud.zoneclear_off.gotoAndPlay(1);
			_hud.zoneclear.gotoAndStop(1);
		}else{
			_hud.zoneclear_off.scaleX = 0.1;
			_hud.zoneclear_off.scaleY = 0.1;
			_hud.zoneclear.scaleX = 1.0;
			_hud.zoneclear.scaleY = 1.0;

			_hud.zoneclear.alpha = 1;
			_hud.zoneclear_off.alpha = 0;
			var pct :Number = Math.round(_ctrl.calculateGrade("grade",false));
			var grade :Number = BrawlerUtil.indexIfLessEqual(GRADE_LEVELS, pct);
			_hud.zoneclear.grade.points.text = (GRADES[grade]);
			_hud.zoneclear.percent.points.text = pct;
			_hud.zoneclear_off.grade.points.text = (GRADES[grade]);
			_hud.zoneclear_off.percent.points.text = pct;
			_hud.zoneclear.gotoAndPlay(2);

			//Award Trophy and Room for beating room at rank S on Normal+
			if (_ctrl.difficulty_setting != "Easy" || _ctrl.difficulty_setting != "Normal"){
				if ((GRADES[grade]) == "S"){
					//Got a rank S!
					var zone:int = _ctrl.room-1;
					if (_ctrl.control.player.awardTrophy(String("room"+zone))) {
						_ctrl.control.player.awardPrize(String("prize_z"+zone));
					}
				}
			}
		}
    }

    /**
     * Called when the fade animation completes.
     */
    protected function handleFadeComplete (event :Event) :void
    {
        var type :String = _fadeType;
        _fadeType = null;
        if (type == "out") {
            _ctrl.fadedOut();
        }
    }

    /**
     * Goes to the specified label and stops if the clip isn't already there.
     */
    protected static function setState (clip :MovieClip, state :String) :void
    {
        var ostate :String = (clip.state == undefined) ? clip.currentLabel : clip.state;
        if (ostate != state) {
            clip.alpha = 1; // make sure it's visible
            clip.gotoAndStop(clip.state = state);
        }
    }

    /** The Brawler controller. */
    protected var _ctrl :BrawlerController;

    /** The main Brawler view. */
    protected var _view :BrawlerView;

    /** The game hud. */
    protected var _hud :MovieClip;

    /** The type of fade being performed. */
    protected var _fadeType :String;

    /** The number of punch levels in the attack bar. */
    protected static const PUNCH_LEVELS :int = 6;

    /** The number of kick levels in the attack bar. */
    protected static const KICK_LEVELS :int = 3;

	/** The array of possible grades. */
    protected static const GRADES :Array = [ "S", "A", "B", "C", "D", "F" ];

	/** The required percent score for each grade. */
    protected static const GRADE_LEVELS :Array = [ 100, 90, 80, 70, 60, 0 ];
}
}
