package vampire.quest.client {

import com.threerings.util.StringUtil;

import flash.text.TextField;

import vampire.quest.LocationDesc;
import vampire.quest.PlayerLocationEvent;

public class DebugPanel extends GenericDraggableWindow
{
    public function DebugPanel () :void
    {
        super(500);

        // text entry
        layoutElement(TextBits.createText("Name:", 1.2));
        _nameField = TextBits.createInputText(100, 18, 1.2, 0, "MyProp");
        layoutElement(_nameField);
        layoutElement(TextBits.createText("Val:", 1.2), 10);
        _valueField = TextBits.createInputText(100, 18, 1.2, 0, "MyVal");
        layoutElement(_valueField);

        createNewLayoutRow(15);

        // buttons
        createButton("Set Stat", function (...ignored) :void {
            ClientCtx.stats.setStat(getEnteredName(), getEnteredVal());
        });

        createButton("Get Stat", function (...ignored) :void {
            var name :String = getEnteredName();
            setStatusText("Stat", "name", name, "val", ClientCtx.stats.getStat(name));
        });

        createButton("List Stats", function (...ignored) :void {
            setStatusText("Stats", "names", ClientCtx.stats.getStatNames());
        });

        createNewLayoutRow(15);
        layoutElement(TextBits.createText("Locations", 1.2));
        createNewLayoutRow();
        for each (var loc :LocationDesc in ClientCtx.questData.availableLocations) {
            addLocation(loc);
        }

        registerListener(ClientCtx.questData, PlayerLocationEvent.LOCATION_ADDED,
            function (e :PlayerLocationEvent) :void {
                addLocation(e.location);
            });
    }

    protected function addLocation (loc :LocationDesc) :void
    {
        createButton(loc.displayName, function (...ignored) :void {
            QuestClient.showActivityPanel(loc);
        });
    }

    protected function getEnteredName () :String
    {
        return _nameField.text;
    }

    protected function getEnteredVal () :Object
    {
        var text :String = _valueField.text;
        if (text == null || text.length == 0 || text == "null") {
            return null;
        }

        try {
            return StringUtil.parseNumber(text);
        } catch (e :ArgumentError) {
            // swallow
        }

        return text;
    }

    protected var _nameField :TextField;
    protected var _valueField :TextField;
}

}
