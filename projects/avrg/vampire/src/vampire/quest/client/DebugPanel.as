package vampire.quest.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;

import flash.text.TextField;

import vampire.quest.*;

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

        createButton("Quests", function (...ignored) :void {
            QuestClient.showQuestPanel(true);
        });

        createNewLayoutRow(15);

        // buttons
        createButton("Set Prop", function (...ignored) :void {
            ClientCtx.questProps.setProp(getEnteredName(), getEnteredVal());
        });

        createButton("Get Prop", function (...ignored) :void {
            var name :String = getEnteredName();
            setStatusText("Prop", "name", name, "val", ClientCtx.questProps.getProp(name));
        });

        createButton("List Props", function (...ignored) :void {
            setStatusText("Props", "names", ClientCtx.questProps.getPropNames());
        });

        createButton("Clear Props", function (...ignored) :void {
            for each (var statName :String in ClientCtx.questProps.getPropNames()) {
                ClientCtx.questProps.clearProp(statName);
            }
        });

        createButton("Clear Quests", function (...ignored) :void {
            for each (var questId :int in ClientCtx.questData.activeAndCompleteQuestIds) {
                ClientCtx.questData.debugClearQuest(questId);
            }
        });

        createButton("+Juice", function (...ignored) :void {
            ClientCtx.questData.questJuice += 20;
        });

        createButton("-Juice", function (...ignored) :void {
            ClientCtx.questData.questJuice = Math.max(ClientCtx.questData.questJuice - 20, 0);
        });

        createButton("Reset Debug Quest", function (...ignored) :void {
            ClientCtx.questData.questJuice = 100;
            ClientCtx.questData.addQuest(Quests.getQuestByName("TestQuest").id);
            ClientCtx.questData.unlockActivity(Activities.getActivityByName("whack_small"));
            ClientCtx.questData.curLocation = Locations.getLocationByName("HomeBase");
        });

        createNewLayoutRow(15);
        layoutElement(TextBits.createText("Locations", 1.2));
        createNewLayoutRow();
        for each (var loc :LocationDesc in Locations.getLocationList()) {
            addLocation(loc);
        }
    }

    protected function addLocation (loc :LocationDesc) :void
    {
        if (!ArrayUtil.contains(_locs, loc)) {
            createButton(loc.displayName, function (...ignored) :void {
                QuestClient.goToLocation(loc);
            });

            _locs.push(loc);
        }
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
    protected var _locs :Array = [];
}

}
