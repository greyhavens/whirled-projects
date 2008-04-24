//
// $Id$

package editor {

import mx.core.UIComponent;
import mx.controls.TextInput;

public class TextDetail extends Detail
{
    public function TextDetail (attr :XML)
    {
        super(attr);
        _input = new TextInput();
        _input.text = attr.toString();
        _input.width = 150;
    }

    public override function setData (defxml :XML) :void
    {
        defxml.@[name] = _input.text;
    }

    protected override function input () :UIComponent
    {
        return _input;
    }

    protected var _input :TextInput;
}
}
