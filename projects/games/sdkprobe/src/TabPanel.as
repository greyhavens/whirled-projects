package {

import flash.display.DisplayObject;
import flash.display.Sprite;

public class TabPanel extends Sprite
{
    public function TabPanel ()
    {
    }

    public function addTab (
        name :String, 
        button :Button, 
        contents :DisplayObject) :void
    {
        var tab :Tab = new Tab();
        tab.name = name;
        tab.button = button;
        tab.contents = contents;
        _tabs.push(tab);

        var rhs :int = 0;
        if (_tabs.length > 0) {
            var lastButt :Button = _tabs[_tabs.length - 1].button;
            trace("Last button width is " + lastButt.width);
            rhs = lastButt.x + lastButt.width + 10;
        }
        button.x = rhs;
        contents.visible = false;
        contents.y = 20;
        button.addEventListener(ButtonEvent.CLICK, handleButtonClick);
        addChild(button);
        addChild(contents);
    }

    public function selectTab (name :String) :void
    {
        for each (var t :Tab in _tabs) {
            if (t.name == name) {
                if (_selected != t) {
                    if (_selected != null) {
                        _selected.contents.visible = false;
                    }
                    t.contents.visible = true;
                    _selected = t;
                    return;
                }
            }
        }
    }

    protected function handleButtonClick (event :ButtonEvent) :void
    {
        for each (var t :Tab in _tabs) {
            if (t.button == event.target) {
                selectTab(t.name);
                return;
            }
        }
    }
  
    protected var _selected :Tab;
    protected var _tabs :Array = [];
}

}


import flash.display.DisplayObject;

class Tab
{
    public var name :String;
    public var button :Button;
    public var contents :DisplayObject;
}
