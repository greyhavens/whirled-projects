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

import org.papervision3d.core.animation.channel.AbstractChannel3D;

// TODO: Crouch mode
// TODO: Adjust anchor point
// TODO: Perspective

[SWF(width="600", height="300")]
public class QuakeMix extends Sprite
{
    public function QuakeMix ()
    {
        _control = new AvatarControl(this);

        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);
        DataPack.load(_control.getDefaultDataPack(), packLoaded);

        initPapervision(600, 300);
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
            _pack.getDisplayObjects("texture", initScene);
        } else {
            trace("Ruh oh!");
            //initScene(pack);
        }
    }

    protected function initScene (texture :Object) :void
    {
        var material :MaterialObject3D = new BitmapMaterial(
                Bitmap(texture as DisplayObject).bitmapData);

        _model = new MD2();
        _model.load(_pack.getFile("md2"), material);

        //model = new Collada(_pack.getFileAsXML("mesh"));
        //model.material = material;
        //model = new Cone(material);
        _model.moveDown(100);
        _model.scale = 20;
        _model.pitch(-30);

        scene.addChild(_model);

        var clips :Array = [];

        // TODO: There's gotta be a better way to do this
        for (var n :String in _model.getChannelsByName()) {
            clips.push(n);
        }
        clips.sort();

        trace("Initial state: " + _control.getState());
        _control.registerStates(clips);
        _control.registerActions(clips);

        _control.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _control.addEventListener(ControlEvent.STATE_CHANGED, handleState);
        _control.addEventListener(ControlEvent.AVATAR_SPOKE, handleSpoke);

        // We're ready to render now
        addEventListener(Event.ENTER_FRAME, handleFrame);
        _control.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleAppearanceChanged);

        // Initialize
        handleAppearanceChanged();
    }

    protected function initPapervision (width :Number, height :Number) :void
    {
        viewport = new Viewport3D(width, height);
        addChild(viewport);

        renderer = new BasicRenderEngine();
        scene = new Scene3D();
        camera = new Camera3D();
    }

    protected function playAction(name :String, onDone :Function = null) :void
    {
        _action = name;

        _model.completedCallback = onDone || stopAction;
        _model.play(_action);
    }

    protected function stopAction() :void
    {
        _action = null;
        playState(_state);
    }

    protected function playState(name :String, looping :Boolean = true) :void
    {
        _state = name;

        if (_action == null) {
            _model.completedCallback = looping ?
                    function() :void { } :
                    function() :void { _model.stop() };
            _model.play(_state);
        }
    }

    protected function handleSpoke (event :Event) :void
    {
        playAction("jump");
    }

    protected function handleAction (event :ControlEvent) :void
    {
        trace("Handling action");
        playAction(event.name);
    }

    protected function handleState (event :ControlEvent) :void
    {
        trace("Handling state");
        playState(event.name);
    }

    protected function handleAppearanceChanged (event :Event = null) :void
    {
        if (_control.isSleeping()) {
            if (_action != "death") {
                playAction("death", function () { _model.stop() });
            }
        } else {
            if (_control.isMoving()) {
                if (_action != "run") {
                    playAction("run", function () { });
                }
            } else {
                if (_action == "run") {
                    stopAction();
                }
            }
        }

        var logical :Array = _control.getLogicalLocation();
        var pixel :Array = _control.getPixelLocation();

        _model.rotationX = 90;
        _model.rotationY = -_control.getOrientation() + 90;
    }

    protected function handleFrame (event :Event) :void
    {
        renderer.renderScene(scene, camera, viewport);
    }

    protected var _control :AvatarControl;
    protected var _pack :DataPack;

    protected var _model :MD2;

    protected var _state :String, _action :String;

    protected var viewport :Viewport3D;
    protected var renderer :BasicRenderEngine;
    protected var scene :Scene3D;
    protected var camera :Camera3D;
}

}
