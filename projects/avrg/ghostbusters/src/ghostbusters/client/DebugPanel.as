//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.text.TextField;

import com.threerings.flash.DisplayUtil;
import com.whirled.avrg.AVRGameControlEvent;

// TODO (maybe): not yet updated for new API
public class DebugPanel extends Sprite
{
    public function DebugPanel ()
    {
        _field = new TextField();
        _field.width = 300;
        _field.height = 200;
        this.addChild(_field);

        Game.control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, updateDisplay);
        updateDisplay();
    }

    protected function updateDisplay (... ignored) :void
    {
	var result :String = "{ ";
	
	var props :Object = Game.control.state.getProperties();
	if (props != null) {
            for (var key :String in props) {
		if (result.length > 2) {
                    result += ", ";
		}
		result += key + ": " + props[key];
            }
        }
	result += " }";

	_field.text = result;
    }

    protected var _field :TextField;
}
}
