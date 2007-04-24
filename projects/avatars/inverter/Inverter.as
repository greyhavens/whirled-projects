//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.ProgressEvent;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

[SWF(width="600", height="450")]
public class Inverter extends Sprite
{
    public static const URL :String = "http://media.whirled.com/c95c59abc8da0ac99628fbc4c68799b93c129716.swf";

    public static const WIDTH :int = 600;
    public static const HEIGHT :int = 450;

    public static const CONTENT_WIDTH :int = 200;
    public static const CONTENT_HEIGHT :int = 150;

    public function Inverter ()
    {
        _loader = new Loader();
        addChild(_loader);

        _loader.contentLoaderInfo.sharedEvents.addEventListener("controlConnect", controlPassThru);

        _loader.addEventListener(ProgressEvent.PROGRESS, checkAlignment);
        _loader.addEventListener(Event.COMPLETE, checkAlignment);
        _loader.load(new URLRequest(URL),
            //new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));
            new LoaderContext(false, new ApplicationDomain(null), null));
    }

    /**
     * This is called when your avatar's orientation changes or when it transitions from not
     * walking to walking and vice versa.
     */
    protected function checkAlignment (... ignored) :void
    {
        var w :Number;
        var h :Number;
        try {
            w = _loader.contentLoaderInfo.width;
            h = _loader.contentLoaderInfo.height;

        } catch (err :Error) {
            w = CONTENT_WIDTH;
            h = CONTENT_HEIGHT;
        }

        var normal :Boolean = (_ourState == NORMAL);
        _loader.x = (WIDTH - w) / 2;
        _loader.y = normal ? 0 : h;
        _loader.scaleY = normal ? 1 : -1;
        _setPreferredY(normal ? 0 : 10000);
        _setHotSpot(w / 2, normal ? h : 0, normal ? NaN : -h);
    }


    protected function controlPassThru (evt :Object) :void
    {
        var userProps :Object = evt.userProps;

        replaceProp(userProps, "getStates_v1", function (orig :Function) :Function {
            return function () :Array {
                return StateMultiplexor.createStates(orig(), STATES);
            };
        });
        replaceProp(userProps, "stateSet_v1", function (orig :Function) :Function {
            return function (newState :String) :void {
                orig(StateMultiplexor.getState(newState, 0));
                setState(newState);
                checkAlignment();
            }
        });

        // dispatch it upwards
        this.root.loaderInfo.sharedEvents.dispatchEvent((evt as Event).clone());

        var hostProps :Object = evt.hostProps;

        replaceProp(hostProps, "getState_v1", function (orig :Function) :Function {
            // set up our current shite
            setState(orig());

            return function () :String {
                return StateMultiplexor.getState(orig(), 0);
            }
        });

        _setPreferredY = hostProps["setPreferredY_v1"];
        _setHotSpot = hostProps["setHotSpot_v1"];
    }

    protected function replaceProp (props :Object, propName :String, replacer :Function) :void
    {
        // so fucking loosy-goosy
        if (props != null && propName in props) {
            props[propName] = replacer(props[propName]);
            trace("+++ replaced " + propName);
        }
    }

    protected function setState (fullState :String) :void
    {
        if (fullState == null) {
            _ourState = NORMAL;

        } else {
            _ourState = Math.max(0, STATES.indexOf(StateMultiplexor.getState(fullState, 1)));
        }
        trace("fullState '" + fullState + "', ourState=" + _ourState);
    }

    protected var _loader :Loader;

    protected var _ourState :int = NORMAL;

    protected var _setPreferredY :Function;
    protected var _setHotSpot :Function;

    protected static const NORMAL :int = 0;
    protected static const INVERTED :int = 1;

    protected static const STATES :Array = [ "Normal", "Inverted" ];
}
}
