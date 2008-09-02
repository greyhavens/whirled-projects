package client {

import com.threerings.util.MultiLoader;

import flash.media.Sound;
import flash.system.ApplicationDomain;

public class ShipTypeResources
{
    public var shipAnim :Class, shieldAnim :Class, explodeAnim :Class, shotAnim :Class,
        secondaryAnim :Class;
    public var shotSound :Sound, supShotSound :Sound, spawnSound :Sound, engineSound :Sound;

    public function loadAssets (callback :Function) :void
    {
        _callback = callback;
        _resourcesDomain = new ApplicationDomain();
        MultiLoader.getLoaders(swfAsset, loadComplete, false, _resourcesDomain);
    }

    protected function get swfAsset () :Class
    {
        return null;
    }

    protected function loadComplete (result :Object) :void
    {
        if (result is Error) {
            _callback(false);
        } else {
            _callback(true);
            successHandler();
        }
    }

    protected function successHandler () :void
    {
        shipAnim = getLoadedClass("ship");
        shieldAnim = getLoadedClass("ship_shield");
        explodeAnim = getLoadedClass("ship_explosion_big");
        shotAnim = getLoadedClass("beam");
        shotSound = Sound(new (getLoadedClass("beam.wav"))());
        supShotSound = Sound(new (getLoadedClass("beam_powerup.wav"))());
        spawnSound = Sound(new (getLoadedClass("spawn.wav"))());
        engineSound = Sound(new (getLoadedClass("engine_sound.wav"))());
    }

    protected function getLoadedClass (name :String) :Class
    {
        return _resourcesDomain.getDefinition(name) as Class;
    }

    protected var _resourcesDomain :ApplicationDomain;
    protected var _callback :Function;
}

}
