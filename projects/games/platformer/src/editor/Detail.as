//
// $Id$

package editor {

import mx.containers.Box;
import mx.containers.HBox;
import mx.core.UIComponent;
import mx.controls.ComboBox;
import mx.controls.TextInput;
import mx.controls.Label;
import mx.utils.ArrayUtil;

public class Detail
{
    public var name :String;

    public function Detail (attr :XML = null)
    {
        if (attr != null) {
            this.name = attr.name();
        }
    }

    public function createBox () :Box
    {
        var box :HBox = new HBox();
        var label :Label = new Label();
        label.text = name + ":";
        box.addChild(label);
        box.addChild(input());
        return box;
    }

    public function setData (defxml :XML) :void
    {
    }

    protected function input () :UIComponent
    {
        return new Label();
    }
}
}
