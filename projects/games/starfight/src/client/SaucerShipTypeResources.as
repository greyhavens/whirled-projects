package client {

import flash.media.Sound;

import net.CreateMineMessage;
import net.LaserShotMessage;
import net.ShipMessage;

public class SaucerShipTypeResources extends ShipTypeResources
{
    public var mineFriendly :Class, mineEnemy :Class, mineExplode :Class;
    public var mineSound :Sound, mineExplodeSound :Sound;

    override protected function primaryShotCreated (ship :Ship, message :ShipMessage) :void
    {
        var msg :LaserShotMessage = LaserShotMessage(message);
        var sound :Sound = (msg.isSuper) ? supShotSound : shotSound;
        ClientContext.game.playSoundAt(sound, ship.boardX, ship.boardY);
    }

    override protected function secondaryShotCreated (ship :Ship, message :ShipMessage) :void
    {
        var msg :CreateMineMessage = CreateMineMessage(message);
        ClientContext.game.playSoundAt(mineSound, msg.boardX, msg.boardY);
    }

    override protected function get swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        mineFriendly = getLoadedClass("mine_friendly");
        mineEnemy = getLoadedClass("mine_enemy");
        mineExplode = getLoadedClass("mine_explode");
        mineSound = Sound(new (getLoadedClass("mine_lay.wav"))());
        mineExplodeSound = Sound(new (getLoadedClass("mine_explode.wav"))());
    }

    [Embed(source="../../rsrc/ships/xyru.swf", mimeType="application/octet-stream")]
    protected static var SHIP :Class;
}

}
