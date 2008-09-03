package client {

import flash.media.Sound;

public class WaspShipTypeResources extends ShipTypeResources
{
    public var secondaryExplode :Class;
    public var secondarySound :Sound;
    public var secondaryExplodeSound :Sound;

    override protected function secondaryShotCreated (ship :Ship, args :Array) :void
    {
        ClientContext.game.playSoundAt(secondarySound, args[2], args[3]);
    }

    override protected function get swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        secondaryAnim = getLoadedClass("torpedo");
        secondaryExplode = getLoadedClass("torpedo_explosion");
        secondarySound = Sound(new (getLoadedClass("torpedo_shot.wav"))());
        secondaryExplodeSound = Sound(new (getLoadedClass("torpedo_explode.wav"))());
    }

    [Embed(source="../../rsrc/ships/wasp.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}

}
