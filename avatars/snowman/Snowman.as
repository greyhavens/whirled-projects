//
// $Id$
//
// Snowman - an avatar for Whirled

package {

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

import flash.utils.ByteArray;
import flash.utils.getTimer;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

import org.papervision3d.Papervision3D;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.materials.MovieMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Cone;
import org.papervision3d.objects.primitives.Cylinder;
import org.papervision3d.objects.primitives.Sphere;
import org.papervision3d.view.BasicView;

[SWF(width="600", height="300")]
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
            _pack.getDisplayObjects(
                {headTexture: "headTexture", midTexture: "midTexture", buttTexture: "buttTexture"},
                gotPackObjects);

        } else {
            createScene();
        }
    }

    protected function gotPackObjects (results :Object) :void
    {
        createScene(results["headTexture"] as DisplayObject,
            results["midTexture"] as DisplayObject, results["buttTexture"] as DisplayObject,
            _pack.getData("eyeColor"), _pack.getData("noseColor"), _pack.getData("noseLength"),
            _pack.getData("hatColor"));
        _pack = null; // no longer needed
    }

    protected function createScene (
        headTexture :DisplayObject = null, midTexture :DisplayObject = null,
        buttTexture :DisplayObject = null, eyeColor :uint = 0x000033, noseColor :uint = 0xFFa900,
        noseLength :Number = 100, hatColor :* = undefined) :void
    {
        var fallbackMaterial :MaterialObject3D;
        if (headTexture == null || midTexture == null || buttTexture == null) {
            fallbackMaterial = new BitmapMaterial(((new SNOW_TEXTURE()) as Bitmap).bitmapData);
        }
        _view = new BasicView(600, 550, false);
        addChild(_view);

        var rootNode :DisplayObject3D = new DisplayObject3D("rootNode");
        _view.scene.addChild(rootNode);

        var buttSphere :Sphere = new Sphere(makeMaterial(buttTexture, fallbackMaterial),
            150, 32, 20);
        buttSphere.y = 150;

        var midSphere :Sphere = new Sphere(makeMaterial(midTexture, fallbackMaterial),
            100, 24, 15);
        midSphere.y = 400;

        var headSphere :Sphere = new Sphere(makeMaterial(headTexture, fallbackMaterial),
            50, 16, 10);
        headSphere.y = 550;

        var material :MaterialObject3D = new ColorMaterial(eyeColor);
        var leftEye :Sphere = new Sphere(material, 8);
        leftEye.x = -10;
        leftEye.y = 575;
        leftEye.z = 40;

        var rightEye :Sphere = new Sphere(material, 8);
        rightEye.x = 10;
        rightEye.y = 575;
        rightEye.z = 40;

        material = new ColorMaterial(noseColor);
        // Cone is broken, it always makes a cylinder, so just use cylinder directly
        var nose :Cone = new Cone(material, 10, noseLength, 16, 10);
        nose.rotationX = 270;
        nose.z = 40 + (noseLength / 2);
        nose.y = 550;

        rootNode.addChild(buttSphere);
        rootNode.addChild(midSphere);
        rootNode.addChild(headSphere);
        rootNode.addChild(nose);
        rootNode.addChild(leftEye);
        rootNode.addChild(rightEye);

        // possibly add the optional hat
        if (undefined !== hatColor) {
            var hatNode :DisplayObject3D = new DisplayObject3D();

            material = new ColorMaterial(uint(hatColor));
            var brim :Cylinder = new Cylinder(material, 80, 5, 16);
            var hat :Cylinder = new Cylinder(material, 40, 50, 16);
            hat.y = 20;
            hatNode.addChild(brim);
            hatNode.addChild(hat);

            hatNode.y = 590;
            hatNode.z = -10;
            hatNode.pitch(-20);
            rootNode.addChild(hatNode);
        }

        _camera = _view.cameraAsCamera3D;
        _camera.lookAt(buttSphere);
        // put the camera at the same height as the head..
        _camera.y = 600;

        _view.singleRender();

        // start listening for appearance changed
        _control.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        // and do one now
        appearanceChanged();
    }

    protected function makeMaterial (
        texture :DisplayObject, fallback :MaterialObject3D) :MaterialObject3D
    {
        if (texture == null) {
            return fallback;

        } else if (texture is Bitmap) {
            return new BitmapMaterial(Bitmap(texture).bitmapData);

        } else {
            var movie :MovieClip;
            if (texture is MovieClip) {
                movie = MovieClip(texture);
            } else {
                movie = new MovieClip();
                movie.addChild(texture);
            }
            var material :MovieMaterial = new MovieMaterial(movie, true);
            material.animated = true;
            _animated = true;
            return material;
        }
    }

    /**
     * This is called when your avatar's orientation changes or when it transitions from not
     * walking to walking and vice versa.
     */
    protected function appearanceChanged (event :Object = null) :void
    {
        var needRender :Boolean = updateOrientation();

        if (needRender || _animated) {
            _view.singleRender();
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

        if (_animated || _orient != targetOrient) {
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

    protected var _animated :Boolean = false;

    protected var _control :AvatarControl;

    protected var _orient :Number = NaN;

    protected var _stamp :Number;

    /** Are we listening on ENTER_FRAME? */
    protected var _enterFrame :Boolean = false;

    protected var _view :BasicView;

    protected var _camera :Camera3D;

    protected var _pack :DataPack;
}
}
