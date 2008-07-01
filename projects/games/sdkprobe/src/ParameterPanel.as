package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import com.threerings.util.StringUtil;

public class ParameterPanel extends Sprite
{
    public static const CELL_HEIGHT :int = 25;

    public function ParameterPanel (parameters :Array, title :String=null)
    {
        var row :int;
        var heights :Array = [];
        _entries = [];
        for (row = 0; row < parameters.length; ++row) {
            heights.push(CELL_HEIGHT);
            var param :Parameter = parameters[row] as Parameter;
            var label :Button = new Button(
                param.name + " :" + param.typeDisplay, param.name);
            label.addEventListener(ButtonEvent.CLICK, handleLabelClick);
            var input :TextField = new TextField();
            //input.autoSize = TextFieldAutoSize.LEFT;
            if (param is CallbackParameter) {
                input.textColor = 0x808080;
                input.text = "callback";
            } else {
                input.border = true;
                input.type = TextFieldType.INPUT;
            }
            if (param.optional) {
                input.visible = false;
            }
            _entries.push(new ParameterEntry(param, label, input));
        }

        heights.push(CELL_HEIGHT);
        _grid = new GridPanel([150, 200], heights);

        for (row = 0; row < _entries.length; ++row) {
            var entry :ParameterEntry = _entries[row];
            _grid.addCell(0, row + 1, entry.label);
            _grid.addCell(1, row + 1, entry.input);
            entry.input.width = _grid.getCellSize(1, row).x;
            entry.input.height = _grid.getCellSize(1, row).y;
        }

        
        var buttonGrid :GridPanel = new GridPanel([100, 100], [CELL_HEIGHT]);

        _call = new Button("Local Call", "call");
        buttonGrid.addCell(0, 0, _call);

        _serverCall = new Button("Server Call", "callonserver");
        buttonGrid.addCell(1, 0, _serverCall);

        _grid.addCell(1, 0, buttonGrid);

        if (title != null) {
            var titleText :TextField = new TextField();
            titleText.autoSize = TextFieldAutoSize.LEFT;
            titleText.text = title;
            _grid.addCell(0, 0, titleText);
        }

        addChild(_grid);
    }

    public function get callButton () :Button
    {
        return _call;
    }

    public function get serverCallButton () :Button
    {
        return _serverCall;
    }

    public function getInputs () :Array
    {
        var args :Array = [];
        for each (var entry :ParameterEntry in _entries) {
            if (!entry.input.visible) {
                break;
            }
            args.push(entry.input.text);
        }
        return args;
    }

    protected function handleLabelClick (evt :ButtonEvent) :void
    {
        var paramName :String = evt.action;
        var clicked :int;
        for (clicked = 0; clicked < _entries.length; ++clicked) {
            if (_entries[clicked].param.name == paramName) {
                break;
            }
        }

        if (clicked == _entries.length) {
            trace("Parameter not found: " + evt);
        }

        var row :int;
        var entry :ParameterEntry = _entries[clicked] as ParameterEntry;
        if (entry.input.visible && entry.param.optional) {
            for (row = clicked; row < _entries.length; ++row) {
                _entries[row].input.visible = false;
            }

        } else if (!entry.input.visible) {
            for (row = 0; row <= clicked; ++row) {
                _entries[row].input.visible = true;
            }
        }
    }

    protected var _call :Button;
    protected var _serverCall :Button;
    protected var _grid :GridPanel;
    protected var _entries :Array;
}

}

import flash.text.TextField;

class ParameterEntry
{
    public var param :Parameter;
    public var label :Button;
    public var input :TextField;

    public function ParameterEntry (
        param :Parameter,
        label :Button,
        input :TextField)
    {
        this.param = param;
        this.label = label;
        this.input = input;
    }
}
