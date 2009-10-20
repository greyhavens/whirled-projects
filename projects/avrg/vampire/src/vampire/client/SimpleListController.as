package vampire.client {

import com.threerings.util.HashMap;
import com.threerings.util.EventHandlerManager;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

public class SimpleListController
{
    public function SimpleListController (listParent :MovieClip,
                                          rowNameBase :String,
                                          columnNames :Array,
                                          upButton :SimpleButton = null,
                                          downButton :SimpleButton = null)
    {
        _listParent = listParent;
        _columnNames = columnNames;
        _upButton = upButton;
        _downButton = downButton;

        // Determine how many visible rows there are in this list
        for (var ii :int = 1; ; ++ii) {
            var rowChildName :String = rowNameBase + String(ii);
            var rowChild :MovieClip = listParent[rowChildName];
            if (rowChild == null) {
                break;
            }

            _rows.push(rowChild);
        }

        if (_upButton != null) {
            _events.registerListener(_upButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    if (_firstVisibleDataIdx > 0) {
                        _firstVisibleDataIdx--;
                        updateView();
                    }
                });
        }

        if (_downButton != null) {
            _events.registerListener(_downButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    if (_firstVisibleDataIdx + _rows.length < _data.length) {
                        _firstVisibleDataIdx++;
                        updateView();
                    }
                });
        }
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _events = null;
    }

    /**
     * Add custom column handlers for updating columns that aren't TextFields.
     * @param columnHandler function (disp :DisplayObject, data :Object) :void
     */
    public function addCustomColumnHandler (columnName :String, handler :Function) :void
    {
        _customColumnHandlers.put(columnName, handler);
    }

    public function set data (newData :Array) :void
    {
        _data = newData;
        updateView();
    }

    protected function updateView () :void
    {
        for (var ii :int = 0; ii < _rows.length; ++ii) {
            var row :MovieClip = _rows[ii];
            var dataIndex :int = _firstVisibleDataIdx + ii;
            if (_data == null || dataIndex >= _data.length) {
                row.visible = false;

            } else {
                row.visible = true;
                var data :Object = _data[dataIndex];
                for each (var columnName :String in _columnNames) {
                    var disp :DisplayObject = row[columnName];
                    if (disp != null && data.hasOwnProperty(columnName)) {
                        var columnData :Object = data[columnName];
                        // Does this column have a custom handler? If not, default
                        // to our textColumnHandler
                        var handler :Function = _customColumnHandlers.get(columnName);
                        if (handler == null) {
                            handler = textColumnHandler;
                        }
                        handler(disp, columnData);
                        disp.visible = true;

                    } else {
                        disp.visible = false;
                    }
                }
            }
        }

        if (_upButton != null) {
            _upButton.enabled = _upButton.visible = (_firstVisibleDataIdx > 0);
        }

        if (_downButton != null) {
            _downButton.enabled = _downButton.visible =
                (_firstVisibleDataIdx + _rows.length < _data.length);
        }
    }

    protected static function textColumnHandler (tf :TextField, data :Object) :void
    {
        tf.text = data.toString();
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected var _listParent :MovieClip;
    protected var _columnNames :Array;
    protected var _rows :Array = [];

    protected var _customColumnHandlers :HashMap = new HashMap();

    protected var _upButton :SimpleButton;
    protected var _downButton :SimpleButton;

    protected var _firstVisibleDataIdx :int;

    protected var _data :Array;
}

}
