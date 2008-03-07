// $Id$

package com.threerings.graffiti.model {

public class OfflineModel extends Model
{
    public override function endStroke (id :String) :void
    {
        // when offline we can move the finished stroke straight to the canvas
        var stroke :Stroke = _tempStrokesMap.get(id);
        removeFromTempStrokes(id);
        pushToCanvas(stroke);
    }
}
}
