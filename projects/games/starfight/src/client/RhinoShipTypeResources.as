package client {

import flash.media.Sound;

public class RhinoShipTypeResources extends ShipTypeResources
{
    public var warpSound :Sound;
    public var superShotAnim :Class, superShotExplode :Class;

    override protected function get swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        warpSound = Sound(new (getLoadedClass("warp.wav"))());
        superShotAnim = getLoadedClass("missile");
        superShotExplode = getLoadedClass("missile_explosion");
    }

    [Embed(source="../../rsrc/ships/rhino.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}

}
