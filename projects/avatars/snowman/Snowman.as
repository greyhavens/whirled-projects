//
// $Id$
//
// Snowman - an avatar for Whirled

package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.Event;

import flash.utils.ByteArray;
import flash.utils.getTimer;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

import org.papervision3d.Papervision3D;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.components.as3.flash9.PV3DScene3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.Cone;
import org.papervision3d.objects.Cylinder;
import org.papervision3d.objects.Sphere;
import org.papervision3d.scenes.MovieScene3D;
import org.papervision3d.scenes.Scene3D;

[SWF(width="150", height="250")]
public class Snowman extends Sprite
{
    public function Snowman ()
    {
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _control = new AvatarControl(this);

        _control.setMoveSpeed(200);

        // Uncomment this to be notified when the player speaks
        // _control.addEventListener(ControlEvent.AVATAR_SPOKE, avatarSpoke);

        // Uncomment this to export custom avatar actions
        // _control.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        // _control.setActions("Test action");

        var ba :ByteArray = _control.getDefaultDataPack();
        if (ba != null) {
            _pack = new DataPack(ba);
            _pack.getDisplayObjects([ "texture" ], gotTexture);

        } else {
            createScene();
        }
    }

    protected function gotTexture (results :Object) :void
    {
        createScene(results["texture"] as Bitmap, _pack.getData("eyeColor"), _pack.getData("noseColor"), _pack.getData("hatColor"));
        _pack = null; // no longer needed
    }

    protected function createScene (
        texture :Bitmap = null, eyeColor :uint = 0x000033, noseColor :uint = 0xFFa900,
        hatColor :* = undefined) :void
    {
        if (texture == null) {
            texture = (new SNOW_TEXTURE()) as Bitmap;
        }
        var sprite :Sprite = new Sprite();
        sprite.x = 75;
        sprite.y = 200;
        addChild(sprite);

        _scene = new Scene3D(sprite);
        var rootNode :DisplayObject3D = new DisplayObject3D("rootNode");
        _scene.addChild(rootNode);

        var material :MaterialObject3D;
        //material = new ColorMaterial(0xDDDDFF);
        material = new BitmapMaterial(texture.bitmapData);
        var buttSphere :Sphere = new Sphere(material, 150, 16, 10);
        buttSphere.y = 150;

        var midSphere :Sphere = new Sphere(material, 100, 16, 10);
        midSphere.y = 400;

        var headSphere :Sphere = new Sphere(material, 50, 16, 10);
        headSphere.y = 550;

        material = new ColorMaterial(eyeColor);
        var leftEye :Sphere = new Sphere(material, 8);
        leftEye.x = -10;
        leftEye.y = 575;
        leftEye.z = 40;

        var rightEye :Sphere = new Sphere(material, 8);
        rightEye.x = 10;
        rightEye.y = 575;
        rightEye.z = 40;

        //material = new BitmapMaterial(Bitmap(new TEXTURE()).bitmapData);
        material = new ColorMaterial(noseColor);
        // Cone is broken, it always makes a cylinder, so just use cylinder directly
        var nose :Cylinder = new Cylinder(material, 10, 100, 16, 10, .01);
        nose.rotationX = 270;
        nose.z = 90;
        nose.y = 550;

        rootNode.addChild(buttSphere);
        rootNode.addChild(midSphere);
        rootNode.addChild(headSphere);
        rootNode.addChild(nose);
        rootNode.addChild(leftEye);
        rootNode.addChild(rightEye);

        // possibly add the optional hat
        if (undefined !== hatColor) {
            material = new ColorMaterial(uint(hatColor));
            var brim :Cylinder = new Cylinder(material, 80, 5, 16);
            brim.pitch(-20);
            brim.y = 595;
            brim.z = -10;

            var hat :Cylinder = new Cylinder(material, 30, 30, 16);
            hat.pitch(-20);
            hat.y = 615;
            rootNode.addChild(brim);
            rootNode.addChild(hat);
        }

        _camera = new Camera3D(buttSphere);
        // put the camera at the same height as the head..
        _camera.y = 600;

        _scene.renderCamera(_camera);

        // start listening for appearance changed
        _control.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        // and do one now
        appearanceChanged();
    }

    /**
     * This is called when your avatar's orientation changes or when it transitions from not
     * walking to walking and vice versa.
     */
    protected function appearanceChanged (event :Object = null) :void
    {
        var needRender :Boolean = updateOrientation();

        if (needRender) {
            _scene.renderCamera(_camera);
        }
    }

    /**
     */
    protected function updateOrientation () :Boolean
    {
        var targetOrient :Number = _control.getOrientation();

        var needRender :Boolean = true;

        if (targetOrient == _orient) {
            needRender = false;
            _stamp = NaN;

        } else if (isNaN(_orient)) {
            _orient = targetOrient;

        } else {
            var now :Number = getTimer();
            if (isNaN(_stamp)) {
                needRender = false;

            } else {
                // figure out which way to rotate the orient.
                var upDist :Number = (targetOrient + 360) - _orient;
                if (upDist > 360) {
                    upDist -= 360;
                }

                var downDist :Number = (_orient + 360) - targetOrient;
                if (downDist > 360) {
                    downDist -= 360;
                }

                var maxDegrees :Number = REORIENT_RATE * (now - _stamp) / 1000;
                if (upDist < downDist) {
                    _orient += Math.min(upDist, maxDegrees);

                } else {
                    _orient -= Math.min(downDist, maxDegrees);
                }

                if (_orient > 360) {
                    _orient -= 360;

                } else if (_orient < 0) {
                    _orient += 360;
                }
            }

            _stamp = now;
        }
        
        if (needRender) {
            var radians :Number = _orient * Math.PI / 180;
            _camera.x = CAMERA_DISTANCE * Math.sin(radians);
            _camera.z = CAMERA_DISTANCE * Math.cos(radians);
        }

        if (_orient != targetOrient) {
            if (!_enterFrame) {
                addEventListener(Event.ENTER_FRAME, handleFrame);
                _enterFrame = true;
            }
        } else {
            if (_enterFrame) {
                removeEventListener(Event.ENTER_FRAME, handleFrame);
                _enterFrame = false;
                _stamp = NaN;
            }
        }

        return needRender;
    }

    /**
     * This is called when your avatar speaks.
     */
    protected function avatarSpoke (event :Object = null) :void
    {
    }

    /**
     * This is called when the user selects a custom action exported on your avatar or when any
     * other trigger event is received.
     */
    protected function handleAction (event :ControlEvent) :void
    {
    }

    protected function handleFrame (event :Event = null) :void
    {
        appearanceChanged();
    }

    /**
     * This is called when your avatar is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME

        if (_enterFrame) {
            removeEventListener(Event.ENTER_FRAME, handleFrame);
            _enterFrame = false;
        }
    }

    [Embed(source="snow.jpg")]
    protected static const SNOW_TEXTURE :Class;

    protected static const CAMERA_DISTANCE :Number = 400;

    /** The maximum amount we re-orient, in degrees, per second. */
    protected static const REORIENT_RATE :Number = 125;

    protected var _control :AvatarControl;

    protected var _orient :Number = NaN;

    protected var _stamp :Number;

    /** Are we listening on ENTER_FRAME? */
    protected var _enterFrame :Boolean = false;

    protected var _scene :Scene3D;

    protected var _camera :Camera3D;

    protected var _pack :DataPack;
}
}
