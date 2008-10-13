package ghostbusters.client.fight.lantern {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import ghostbusters.client.fight.common.*;

public class GhostHeart extends SceneObject
{
    public function GhostHeart (radius :Number, maxHealth :Number)
    {
        _radius = radius;
        _maxHealth = maxHealth;
        _health = maxHealth;


//        var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
//        modeSprite.addChild(swfRoot);
//        var _playerPlacerMain :MovieClip = MovieClip(swfRoot["player_placer_main"]);
//
//        var heart :DisplayObject = SwfResource.getSwfDisplayRoot("lantern.heart");

//        heart = SwfResource.getSwfDisplayRoot("lantern.heart");


//        var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("lantern.heart"));
//        heart = swfRoot["heart_symbol"];


        var swf :SwfResource = (ResourceManager.instance.getResource("lantern.heart") as SwfResource);
        var heartClass :Class = swf.getClass("heart_symbol");
        heart = new heartClass() as MovieClip;
//        trace("is highlight=" + (heart.highlight != null));
//        trace("is highlight=" + (heart["highlight"] != null));
//        trace("heart.numChildren=" + heart.numChildren);
//        trace("heart.getChildAt(1).numChildren=" + (heart.getChildAt(1) as MovieClip).numChildren);
//        trace("heart.getChildAt(0).numChildren=" + (heart.getChildAt(0) as MovieClip).numChildren);
//        heart.getChildAt(0).alpha = 1;
//        heart.getChildAt(1).alpha = 1;
//        (heart.getChildAt(0) as MovieClip).getChildAt(1).alpha = 0;
        (heart.getChildAt(1) as MovieClip).getChildAt(0).alpha = 0;
        
        //speech bubble = (heart.getChildAt(1) as MovieClip).getChildAt(1).alpha = 0;
//        heart.getChildAt(1). = 0;
//        
//        var heartBOrderClass :Class = swf.getClass("highlight");
//        var heartBorder :MovieClip = new heartBOrderClass();
//        heart["highlight"] = new heartBOrderClass();
//        heart["highlight"].alpha = 0;
//        heart = new Sprite();
        
        
//        trace(heart.accessibilityProperties);
//        heart = SwfResource.instantiateMovieClip("lantern.heart", "MovieClip");
//        Rand.setup();
//        var heart :DisplayObject = new SimpleTextButton(REAL_CAMPAIGN_INFORMATION[ Rand.nextIntRange(0, REAL_CAMPAIGN_INFORMATION.length, 0) ]);

        //Clutter
//        for( var k :int = 0; k < 30; k++) { 
//            var clutter :MovieClip = MovieClip(heart["clutter"]);
//            clutter.x = 
//        }
        
//        var heart :DisplayObject = SwfResource.getSwfDisplayRoot("lantern.heart");
        

//        var scale :Number = _radius / HEART_RADIUS_BASE;


//        trace("fresh: x=" + heart.x + ", y=" + heart.y + ", w=" + heart.width + ", h=" + heart.height);
        


//        trace("heart.width=" + heart.width);
        _sprite = new Sprite();
        
//        _sprite.graphics.beginFill(0xffffff);
//        _sprite.graphics.drawEllipse(heart.x,heart.y,heart.width,heart.height);
//        _sprite.graphics.drawEllipse(-25, -25, 50, 50);
//        _sprite.graphics.endFill();
        
//        heart.x = -(heart.width * 0.5);
        heart.y = -20;
        
//        _sprite.graphics.lineStyle(4, 0xffffff);
//        _sprite.graphics.drawEllipse(-heart.width/2, -heart.height/2, heart.width, heart.height);
//        _sprite.graphics.drawEllipse(-heart.x, -heart.y, heart.width, heart.height);
        _sprite.addChild(heart);
        _sprite.scaleX = 0.7;
        _sprite.scaleY = 0.7;
        
        

        //var heartBounds :Rectangle = heart.getBounds(_sprite);
        //heart.x = -heartBounds.x - heart.width / 2;
        //heart.y = -heartBounds.y - heart.height / 2;
    }

    public function offsetHealth (offset :Number) :void
    {
        _health += offset;
        _health = Math.max(_health, 0);
        _health = Math.min(_health, _maxHealth);
        
        (heart.getChildAt(1) as MovieClip).getChildAt(0).alpha = (_maxHealth - _health) / _maxHealth;
//        var cm :ColorMatrix = new ColorMatrix();
//        cm.colorize(0x0000FF, 1 - (_health / _maxHealth));
//
//        _sprite.filters = [ cm.createFilter() ];
    }
    
    public function showBorder() :void
    {
//        (heart.getChildAt(1) as MovieClip).getChildAt(0).alpha = 1;
    }
    public function get health () :Number
    {
        return _health;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    public var heart :MovieClip;

    protected var _sprite :Sprite;
    protected var _radius :Number;
    protected var _maxHealth :Number;
    protected var _health :Number;

    protected static const BEAT_SCALE :Number = 1.2;
    protected static const BEAT_DELAY :Number = 0.05;

    protected static const HEART_RADIUS_BASE :Number = 41;
//    protected static const HEART_RADIUS_BASE :Number = 11;
    
//    protected static const REAL_CAMPAIGN_INFORMATION :Array = ["blah1", "blah2", "blah3" ];
    
}

}
