package def {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Tower definition from an xml settings file.
 */
public class TowerDefinition
{
    public var pack :PackDefinition;
    public var swf :EmbeddedSwfLoader;

    public var id :String;

    public var width :int;
    public var height :int;
    
    public var cost :int;
    public var rangeMax :Number;
    public var pauseBetweenMissiles :Number;

    public var buttonStyleName :String;
    public var description :String;

    public var animationRest :Class;
    public var animationLeft :Class;
    public var animationRight :Class;
    public var animationUp :Class;
    public var animationDown :Class;

    public var missileSpeed :Number;
    public var missileDamage :Number;
    public var missileAnimations :Array; // of Class
    
    public function TowerDefinition (swf :EmbeddedSwfLoader, pack :PackDefinition, tower :XML)
    {
        this.pack = pack;
        this.swf = swf;

        this.id = tower.@id;
        this.width = tower.@width;
        this.height = tower.@height;
        
        this.buttonStyleName = tower.@styleName;
        this.description = tower.@description;

        this.cost = tower.@cost
        this.rangeMax = tower.@rangeMax;
        this.pauseBetweenMissiles = tower.@pauseBetweenMissiles;

        for each (var anim :XML in tower.animations.*) {
                var prop :String = anim.name().localName;
                var value :String = String(anim);
                this[prop] = this.swf.getClass(value);
            }

        this.missileSpeed = tower.missiles.@maxvel;
        this.missileDamage = tower.missiles.@damage;

        this.missileAnimations = new Array();
        for each (anim in tower..animation) {
                this.missileAnimations.push(this.swf.getClass(anim));
            }
    }

    public function get guid () :String
    {
        return pack.name + ": " + id; 
    }
    
    public function toString () :String
    {
        return "[Tower guid=" + guid + ", swf=" + swf + "]";
    }
}
}
