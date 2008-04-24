//
// $Id$

package editor {

import mx.core.UIComponent;
import mx.controls.ComboBox;
import mx.utils.ArrayUtil;

public class ComboDetail extends Detail
{
    public function ComboDetail (attr :XML, options :Array)
    {
        super(attr);
        _combo = new ComboBox();
        _combo.dataProvider = options;
        _combo.selectedIndex = ArrayUtil.getItemIndex(attr.toString(), options);
        _combo.width = 150;
    }

    public override function setData (defxml :XML) :void
    {
        defxml.@[name] = _combo.selectedLabel;
    }

    protected override function input () :UIComponent
    {
        return _combo;
    }

    protected var _combo :ComboBox;
}
}
