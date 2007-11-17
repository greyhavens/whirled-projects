package modes {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.containers.Canvas;
import mx.controls.Button;
import mx.controls.Image;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Assert;
import com.threerings.util.ClassUtil;

public class SelectBoard extends GameModeCanvas
{
    public function SelectBoard (playCallback :Function)
    {
        _playCallback = playCallback;
    }

    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();
        
        var bg :Image = new Image();
        addChild(bg);
        bg.source = new _select();

        var movie :MovieClip = (bg.source as MovieClip);
        trace(ClassUtil.getClassName(movie));
        // trace(DisplayUtil.dumpHierarchy());
    }
    
    [Embed(source="../../rsrc/selectscreen/selectscreen.swf")]
    private static const _select :Class;

    protected var _playCallback :Function;
}
}
