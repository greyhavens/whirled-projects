package  {

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.TimerEvent;
import flash.utils.Timer;

import flash.events.Event; // To work out when a frame is entered.
import org.papervision3d.view.Viewport3D; // We need a viewport
import org.papervision3d.cameras.*; // Import all types of camera
import org.papervision3d.scenes.Scene3D; // We'll need at least one scene
import org.papervision3d.render.BasicRenderEngine; // And we need a renderer
import org.papervision3d.objects.primitives.Cone;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.parsers.Collada;
import org.papervision3d.objects.parsers.MD2;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.utils.MaterialsList;
import org.papervision3d.core.proto.MaterialObject3D;

import org.papervision3d.core.math.Number3D;

import org.papervision3d.core.animation.channel.AbstractChannel3D;

[SWF(width="600", height="450")]
public class QuakeMix extends Sprite
{
    public function QuakeMix ()
    {
        _control = new AvatarControl(this);

        initPapervision(600, 450);
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);
        DataPack.load(_control.getDefaultDataPack(), packLoaded);

        _control.setHotSpot(600/2, 450 - 30, 300);
    }

    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);

        if (_pack != null) {
            _pack.close();
        }
    }

    protected function packLoaded (pack :Object) :void
    {
        if (pack is DataPack) {
            _pack = pack as DataPack;
            _pack.getDisplayObjects({
                player: "body_skin", weapon: "weapon_skin"}, initScene);
        } else {
            trace("Ruh oh!");
        }
    }

    protected function initScene (textures :Object) :void
    {
        // Set up player model
        {
            var player_material :MaterialObject3D = new BitmapMaterial(
                    Bitmap(textures.player as DisplayObject).bitmapData);

            _model = new MD2();
            _model.load(_pack.getFile("body_md2"), player_material);
            _model.rotationX = 90;
            _model.y = -20;
            scene.addChild(_model);
        }

        // Set up weapon model
        if (_pack.getBoolean("show_weapon")) {
            var weapon_material :MaterialObject3D = new BitmapMaterial(
                    Bitmap(textures.weapon as DisplayObject).bitmapData);

            _weapon = new MD2();
            _weapon.load(_pack.getFile("weapon_md2"), weapon_material);
            _weapon.rotationX = _model.rotationX;
            _weapon.y = _model.y;
            scene.addChild(_weapon);
        }

        camera.x = 0;
        camera.y = 30;
        camera.z = -100;
        camera.zoom = 10;
        camera.lookAt(_model);

        _control.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _control.addEventListener(ControlEvent.STATE_CHANGED, handleState);
        _control.addEventListener(ControlEvent.AVATAR_SPOKE, handleSpoke);

        var clips :Array = [];
        for (var n :String in _model.getChannelsByName()) {
            clips.push(n);
        }
        clips.sort();

        var states :Array, actions :Array;
        if (TRIM_CLIPS) {
            states = clips.filter(function (n :*, ... etc) :Boolean {
                        return INVALID_STATES.indexOf(n) == -1 &&
                               INVALID_BOTH.indexOf(n) == -1;
                    });
            actions = clips.filter(function (n :*, ... etc) :Boolean {
                        return INVALID_ACTIONS.indexOf(n) == -1 &&
                               INVALID_BOTH.indexOf(n) == -1;
                    });

            // Specially make sure this is first
            states.unshift("stand");
        } else {
            states = clips;
            actions = clips;
        }

        // Remove "stand" and "all" from the list
        /*clips = clips.filter(function (n :*, ... rest) :Boolean {
                    return n != "stand" && n != "all";
                }).sort();*/
        // Make sure "stand" is first
        //clips.unshift("stand");

        _control.registerStates(states);
        _control.registerActions(actions);

        // We're ready to render now
        addEventListener(Event.ENTER_FRAME, handleFrame);
        _control.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleAppearanceChanged);

        // Initialize
        handleAppearanceChanged();
        playState(_control.getState());
    }

    protected function initPapervision (width :Number, height :Number) :void
    {
        viewport = new Viewport3D(width, height);
        addChild(viewport);

        renderer = new BasicRenderEngine();
        scene = new Scene3D();
        camera = new Camera3D();
    }

    protected function playWeapon (name :String) :void
    {
        if (_weapon != null) {
            if (_weapon.getAnimationChannelByName(name) == null) {
            // Hide the weapon when playing a death animation
            //if (name.indexOf("death") >= 0) {
                _weapon.visible = false;
            } else {
                _weapon.visible = true;
                _weapon.play(name);
            }
        }
    }

    protected function playAction (name :String, important :Boolean = true, onDone :Function = null) :void
    {
        _action = name;

        // Whether or not this action should be interrupted by minor changes
        _importantAction = important;

        playWeapon(_action);

        _model.completedCallback = onDone || stopAction;
        _model.play(_action);
    }

    protected function stopAction () :void
    {
        _action = null;
        playState(_state);
    }

    protected function playState (name :String, looping :Boolean = true) :void
    {
        _state = name;

        var runSpeed :Number = _pack.getNumber("run_speed");
        _control.setMoveSpeed(isCrouching() ? runSpeed/3 : runSpeed);

        if (_action == null) {
            _model.completedCallback = looping ?
                    function() :void { } :
                    function() :void { _model.stop() };
            _model.play(_state);

            playWeapon(_state);
        }
    }

    protected function handleSpoke (event :Event) :void
    {
        playAction(_pack.getString("talk_action"));
    }

    protected function handleAction (event :ControlEvent) :void
    {
        playAction(event.name);
    }

    protected function handleState (event :ControlEvent) :void
    {
        playState(event.name);
    }

    protected function isCrouching () :Boolean
    {
        return _state == "crstand" || _state == "crstnd";
    }

    protected function pause() :void
    {
        _model.stop();
        if (_weapon != null) {
            _weapon.stop();
        }
    }

    protected function handleAppearanceChanged (event :Event = null) :void
    {
        if (_control.isSleeping()) {
            var sleep :String = _pack.getString("sleep_action");

            if (_action != sleep) {
                // Go to sleep, and pause when the animation finishes
                playAction(sleep, false, pause);
            }
        } else {
            var run :String = isCrouching() ? "crwalk" : "run";

            if (_control.isMoving()) {
                if (_action != run) {
                    playAction(run, false, function () :void { });
                }
            } else {
                if ( _action != null && ! _importantAction) {
                    stopAction();
                }
            }
        }

        _model.rotationY = -_control.getOrientation() + 90;
        if (_weapon != null) {
            _weapon.rotationY = _model.rotationY;
        }
    }

    protected function handleFrame (event :Event) :void
    {
        renderer.renderScene(scene, camera, viewport);
    }

    protected var _control :AvatarControl;
    protected var _pack :DataPack;

    protected var _model :MD2;
    protected var _weapon :MD2;

    protected var _state :String, _action :String;
    protected var _importantAction :Boolean;

    protected var viewport :Viewport3D;
    protected var renderer :BasicRenderEngine;
    protected var scene :Scene3D;
    protected var camera :Camera3D;

    /** Whether or not we care about trimming the action/state list. */
    protected const TRIM_CLIPS :Boolean = true;

    /** Keep these out of the action list. */
    protected const INVALID_ACTIONS :Object = [
            "stand", "crstand", "crstnd"
        ];

    /** Keep these out of the state list. */
    protected const INVALID_STATES :Object = [
            "attack", "crattck", "crattack", "crdeath", "crdeth", "crpain",
            "death", "flip", "flipoff", "jump", "pain", "point", "salute",
            "taunt", "wave"
        ];
    
    /** Keep these out of both lists. */
    protected const INVALID_BOTH :Object = [
            "all", // This is added by MD2.as, we don't really care
            "stand", // Remove this and re-add it after processing to the first slot
            "crwalk", "run" // Avatar movement uses these, not actions/states
        ];
}

}
