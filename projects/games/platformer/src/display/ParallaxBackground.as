//
// $Id$

package display {

import flash.display.DisplayObject;

/**
 * A layer that displays one or more parallax background layers.
 */
public class ParallaxBackground extends Layer
{
    public function addNewLayer (index :int, scaleX :int = 1, scaleY :int = 1) :void
    {
        _layers[index] = new ParallaxLayer(scaleX, scaleY);
        addChildAt(_layers[index], index);
    }

    public function addChildToLayer (disp :DisplayObject, index :int) :void
    {
        if (_layers[index] != null) {
            disp.y = -disp.height;
            _layers[index].addChild(disp);
        }
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        _layers.forEach(function (layer :ParallaxLayer, index :int, arr :Array) :void {
            layer.update(nX, nY);
        });
    }

    /** Our parallax layers. */
    protected var _layers :Array = new Array();
}
}
