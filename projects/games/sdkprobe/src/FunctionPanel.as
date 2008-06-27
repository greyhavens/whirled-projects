package {

import flash.display.Sprite;
import flash.text.TextField;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.threerings.util.StringUtil;

public class FunctionPanel extends Sprite
{
    public static const VOID :Object = new Void();

    public function FunctionPanel (ctrl :GameControl, functions :Array)
    {
        _ctrl = ctrl;

        var maxPerPage :int = 14;
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
       

        _output = new TextField();
        _output.width = 699;
        _output.height = 199;
        _output.y = 300;
        _output.border = true;
        _output.wordWrap = true;
        addChild(_output);
    }

    protected function setupGrid (functions :Array) :GridPanel
    {
        var heights :Array = [];
        var ii :int;
        for (ii = 0; ii < functions.length; ++ii) {
            heights.push(20);
        }

        var grid :GridPanel = new GridPanel(
            [150, 150], heights);

        for (ii = 0; ii < functions.length; ++ii) {
            var name :String = functions[ii].name;
            _functions[name] = functions[ii];

            var fnButt :Button = new Button(name, name);
            grid.addCell(0, ii, fnButt);
            fnButt.addEventListener(ButtonEvent.CLICK, handleFunctionClick);
        }

        return grid;
    }

    protected function handleFunctionClick (evt :ButtonEvent) :void
    {
        var spec :FunctionSpec = _functions[evt.action];
        if (spec == null) {
            output("Function " + evt.action + " not found");
            return;
        }

        try {
            output("Calling " + spec.name);
            var value :Object = spec.func.apply(null, []);
            if (value != undefined) {
                output("Result: " + StringUtil.toString(value));
            }

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

    protected var _ctrl :GameControl;
    protected var _functions :Object = {};
    protected var _output :TextField;
}

}

