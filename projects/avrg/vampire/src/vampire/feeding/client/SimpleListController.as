package vampire.feeding.client {

import com.whirled.contrib.simplegame.SimObject;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

public class SimpleListController extends SimObject
{
    public function SimpleListController (data :Array,
                                          listParent :MovieClip,
                                          rowNameBase :String,
                                          columnNames :Array,
                                          upButton :SimpleButton = null,
                                          downButton :SimpleButton = null)
    {
        _data = data;
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
            registerListener(_upButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    if (_firstVisibleDataIdx > 0) {
                        _firstVisibleDataIdx--;
                        updateView();
                    }
                });
        }

        if (_downButton != null) {
            registerListener(_downButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    if (_firstVisibleDataIdx + _rows.length < _data.length) {
                        _firstVisibleDataIdx++;
                        updateView();
                    }
                });
        }

        updateView();
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
            if (dataIndex >= _data.length) {
                row.visible = false;

            } else {
                row.visible = true;
                var data :Object = _data[dataIndex];
                for each (var columnName :String in _columnNames) {
                    var column :TextField = row[columnName];
                    if (data.hasOwnProperty(columnName)) {
                        column.text = data[columnName];
                        column.visible = true;
                    } else {
                        column.visible = false;
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

    protected var _listParent :MovieClip;
    protected var _columnNames :Array;
    protected var _rows :Array = [];

    protected var _upButton :SimpleButton;
    protected var _downButton :SimpleButton;

    protected var _firstVisibleDataIdx :int;

    protected var _data :Array;
}

}
