//
// $Id$

package editor {

import mx.containers.Box;
import mx.containers.VBox;
import mx.controls.Button;
import mx.events.FlexEvent;

public class BoundsDetail extends Detail
{
    public function BoundsDetail (attr :XML)
    {
        super(attr);
        for each (var bdef :XML in attr.bound) {
            _bounds.push(new BoundDetail(bdef));
        }
    }

    public override function createBox () :Box
    {
        var box :VBox = new VBox();
        _bbox = new VBox();
        for each (var bound :BoundDetail in _bounds) {
            _bbox.addChild(bound.createBox());
        }
        box.addChild(_bbox);
        var button :Button = new Button();
        button.label = "+";
        button.addEventListener(FlexEvent.BUTTON_DOWN, addBound);
        box.addChild(button);
        return box;
    }

    public override function setData (defxml :XML) :void
    {
        var xml :XML = <bounds/>;
        for each (var bound :BoundDetail in _bounds) {
            bound.setData(xml);
        }
        defxml.appendChild(xml);
    }

    protected function addBound (event :FlexEvent) :void
    {
        var bound :BoundDetail = new BoundDetail();
        _bounds.push(bound);
        _bbox.addChild(bound.createBox());
    }

    protected var _bounds :Array = new Array();
    protected var _bbox :VBox;
}
}
