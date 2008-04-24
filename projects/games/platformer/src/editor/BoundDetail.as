//
// $Id$

package editor {

import mx.collections.ArrayCollection;
import mx.containers.Box;
import mx.containers.HBox;

import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.controls.Label;

import piece.BoundedPiece;

public class BoundDetail extends Detail
{
    public function BoundDetail (attr :XML = null)
    {
        super(attr);
        _x = new TextInput();
        _x.width = 30;
        _y = new TextInput();
        _y.width = 30;
        _type = new ComboBox();
        _type.dataProvider = new ArrayCollection([
            { label:"none", data:BoundedPiece.BOUND_NONE },
            { label:"all", data:BoundedPiece.BOUND_ALL },
            { label:"outer", data:BoundedPiece.BOUND_OUTER },
            { label:"inner", data:BoundedPiece.BOUND_INNER } ]);
        if (attr != null) {
            _y.text = attr.@y;
            _x.text = attr.@x;
            _type.selectedIndex = attr.@type;
        }
    }

    public override function createBox () :Box
    {
        var box :HBox = new HBox();
        var label :Label = new Label();
        label.text = "x:";
        box.addChild(label);
        box.addChild(_x);
        label = new Label();
        label.text = "y:";
        box.addChild(label);
        box.addChild(_y);
        box.addChild(_type);
        return box;
    }

    public override function setData (defxml :XML) :void
    {
        if (_x.text == "" || _y.text == "") {
            return;
        }
        var xml :XML = <bound/>;
        xml.@x = _x.text;
        xml.@y = _y.text;
        xml.@type = _type.selectedItem.data;
        defxml.appendChild(xml);
    }

    protected var _x :TextInput;
    protected var _y :TextInput;
    protected var _type :ComboBox;
}
}
