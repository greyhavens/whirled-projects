package {

import flash.display.Sprite;
import flash.text.TextField;
import com.threerings.util.StringUtil;
import com.whirled.avrg.AVRGameControl;

public class FunctionPanel extends Sprite
{
    public function FunctionPanel (ctrl :AVRGameControl, functions :Array, sequenced :Boolean)
    {
        var depth :int = 40;
        _ctrl = ctrl;
        _sequenced = sequenced;

        _output = new TextField();
        _output.width = 349;
        _output.height = 99;
        _output.y = 150 - depth;
        _output.border = true;
        _output.wordWrap = true;
        addChild(_output);

        var maxPerPage :int = _output.y / 20 - 1;
        if (functions.length <= maxPerPage) {
            addChild(setupGrid(functions));

        } else {
            var groups :TabPanel = new TabPanel();
            var tabNum :int = 1;
            for (var start :int = 0; start < functions.length; start += maxPerPage) {
                groups.addTab("group" + tabNum, 
                    new Button("G" + tabNum), 
                    setupGrid(functions.slice(start, start + maxPerPage)));
                tabNum++;
            }
            addChild(groups);
        }

    }

    protected function setupGrid (functions :Array) :GridPanel
    {
        var heights :Array = [];
        var ii :int;
        for (ii = 0; ii < functions.length; ++ii) {
            heights.push(20);
        }

        var grid :GridPanel = new GridPanel(
            [150], heights);

        for (ii = 0; ii < functions.length; ++ii) {
            var spec :FunctionSpec = functions[ii] as FunctionSpec;
            var params :ParameterPanel = new ParameterPanel(spec.parameters, spec.name);
            params.x = 150;
            params.visible = false;
            addChild(params);
            _functions[spec.name] = new FunctionEntry(spec, params);

            var fnButt :Button = new Button(spec.name, spec.name);
            grid.addCell(0, ii, fnButt);
            fnButt.addEventListener(ButtonEvent.CLICK, handleFunctionClick);
            params.callButton.addEventListener(ButtonEvent.CLICK, handleCallClick);
        }

        return grid;
    }

    protected function handleFunctionClick (evt :ButtonEvent) :void
    {
        var entry :FunctionEntry = _functions[evt.action];
        if (entry == null) {
            output("Function " + evt.action + " not found");
            return;
        }

        if (entry != _selected) {
            if (_selected != null) {
                _selected.params.visible = false;
            }
            _selected = entry;
            _selected.params.visible = true;
        }
    }

    protected function parseParameters (entry :FunctionEntry, local :Boolean) :Array
    {
        var inputs :Array = entry.params.getInputs();
        var params :Array = entry.spec.parameters;
        for (var ii :int = 0; ii < inputs.length; ++ii) {
            if (params[ii] is CallbackParameter) {
                if (local) {
                    inputs[ii] = makeGenericCallback(entry.spec);
                }
            } else {
                inputs[ii] = params[ii].parse(inputs[ii]);
            }
        }
        return inputs;
    }

    protected function makeGenericCallback (fn :FunctionSpec) :Function
    {
        function callback (...args) :void {
            _ctrl.local.feedback("Callback from " + fn.name + " invoked with " + 
                                 "arguments " + StringUtil.toString(args));
        }

        return callback;
    }

    protected function handleCallClick (evt :ButtonEvent) :void
    {
        if (_selected == null) {
            return;
        }

        try {
            var params :Array = parseParameters(_selected, true);
            if (_sequenced) {
                var sequenceId :int = ++_sequenceId;
                output("Calling " + _selected.spec.name + " with arguments " + 
                    StringUtil.toString(params) + " and sequence id " + sequenceId);
                params.unshift(sequenceId);

            } else {
                output("Calling " + _selected.spec.name + " with arguments " + 
                    StringUtil.toString(params));
            }
            var value :Object = _selected.spec.func.apply(null, params);
            output("Result: " + StringUtil.toString(value));

        } catch (e :Error) {
            var msg :String = e.getStackTrace();
            if (msg == null) {
                msg = e.toString();
            }
            output(msg);
        }
    }

    protected function output (str :String) :void
    {
        _output.appendText(str);
        _output.appendText("\n");
        _output.scrollV = _output.maxScrollV;
    }

    protected var _ctrl :AVRGameControl;
    protected var _functions :Object = {};
    protected var _output :TextField;
    protected var _selected :FunctionEntry;
    protected var _sequenced :Boolean;
    protected static var _sequenceId :int = 0;
}

}

class FunctionEntry
{
    public var spec :FunctionSpec;
    public var params :ParameterPanel;

    public function FunctionEntry (spec :FunctionSpec, params :ParameterPanel)
    {
        this.spec = spec;
        this.params = params;
    }
}
