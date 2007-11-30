package def {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Enemy definition from an xml settings file.
 */
public class EnemyDefinition
{
    public var pack :PackDefinition;
    public var swf :EmbeddedSwfLoader;

    public var id :String;
    public var name :String;
    public var isFlying :Boolean;
    
    public var health :Number;
    public var speed :Number;
    public var powerup :Number;

    public var animationLeft :Class;
    public var animationRight :Class;
    public var animationUp :Class;
    public var animationDown :Class;

    public function EnemyDefinition (swf :EmbeddedSwfLoader, pack :PackDefinition, enemy :XML)
    {
        this.pack = pack;
        this.swf = swf;

        this.id = enemy.@id;
        this.name = enemy.@name;
        this.isFlying = enemy.@isFlying;

        this.health = enemy.@health;
        this.speed = enemy.@speed;
        this.powerup = enemy.@powerup;

        for each (var anim :XML in enemy.animations.*) {
                var prop :String = anim.name().localName;
                var value :String = String(anim);
                this[prop] = this.swf.getClass(value);
            }
    }
}
}

