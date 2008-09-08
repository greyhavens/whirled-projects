package joingame.view
{
    import com.whirled.contrib.simplegame.objects.SceneObject;
    
    import flash.display.Sprite;
    
    import com.threerings.util.ArrayUtil;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.audio.*;
    import com.whirled.contrib.simplegame.objects.*;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.contrib.simplegame.util.*;
    import com.whirled.game.GameControl;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import joingame.*;
    import joingame.model.*;
    import joingame.net.JoinGameEvent;
    
    public class JoinAttackAnimation extends SceneObject
    {
        public function JoinAttackAnimation()//xfrom :int, yfrom :int, xto :int, yto :int)
        {
            _sprite = new Sprite();
            _sprite.graphics.beginFill(0);
            _sprite.graphics.drawEllipse(-10, -10, 20, 20);
            _sprite.graphics.endFill();
        }

        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        } 

        protected var _sprite :Sprite;
    }
}