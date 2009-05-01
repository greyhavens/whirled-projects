package vampire.quest.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
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

        createButton("Reload NPC Dialogs", function (...ignored) :void {
            QuestDialogLoader.loadQuestDialogs(
                function () :void {
                    setStatusText("Successfully loaded NPC Dialogs");
                },
                function (err :String) :void {
                    setStatusText("Error loading NPC Dialogs (see log)");
                },
                true);
        });

        createButton("Clear All Data", function (...ignored) :void {
            clearProps();
            clearQuests();
            clearActivities();
        });

        createNewLayoutRow(15);

        // props
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

        createButton("Clear Props", clearProps);

        createNewLayoutRow();

        // Quests
        createButton("Add Quest", function (...ignored) :void {
            var name :String = getEnteredName();
            var quest :QuestDesc = Quests.getQuestByName(name);
            if (quest == null) {
                setStatusText("No quest named " + name + " exists.");
            } else {
                ClientCtx.questData.addQuest(quest);
            }
        });

        createButton("Complete Quest", function (...ignored) :void {
            var name :String = getEnteredName();
            var quest :QuestDesc = Quests.getQuestByName(name);
            if (quest == null) {
                setStatusText("No quest named " + name + " exists.");
            } else {
                ClientCtx.questData.completeQuest(quest);
            }
        });

        createButton("List Quests", function (...ignored) :void {
            var text :String = "Quests [";
            var needsSeparator :Boolean;
            for each (var quest :QuestDesc in Quests.getAllQuests()) {
                if (needsSeparator) {
                    text += ", ";
                }
                text += quest.name;
                needsSeparator = true;
            }

            text += "]";

            setStatusText(text);
        });

        createButton("Clear Quests", clearQuests);

        createNewLayoutRow();

        // Activities
        createButton("Unlock Activity", function (...ignored) :void {
            var name :String = getEnteredName();
            var activity :ActivityDesc = Activities.getActivityByName(name);
            if (activity == null) {
                setStatusText("No activity named " + name + " exists.");
            } else {
                ClientCtx.questData.unlockActivity(activity);
            }
        });

        createButton("Lock Activity", function (...ignored) :void {
            var name :String = getEnteredName();
            var activity :ActivityDesc = Activities.getActivityByName(name);
            if (activity == null) {
                setStatusText("No activity named " + name + " exists.");
            } else {
                ClientCtx.questData.debugLockActivity(activity);
            }
        });

        createButton("List Activities", function (...ignored) :void {
            var text :String = "Activities [";
            var needsSeparator :Boolean;
            for each (var activity :ActivityDesc in Activities.getAllActivities()) {
                if (needsSeparator) {
                    text += ", ";
                }
                text += activity.name;
                needsSeparator = true;
            }

            text += "]";

            setStatusText(text);
        });

        createButton("Lock All Activities", clearActivities);

        createNewLayoutRow();

        createButton("+Juice", function (...ignored) :void {
            ClientCtx.questData.questJuice += 20;
        });

        createButton("-Juice", function (...ignored) :void {
            ClientCtx.questData.questJuice = Math.max(ClientCtx.questData.questJuice - 20, 0);
        });

        createNewLayoutRow(15);
        layoutElement(TextBits.createText("Locations", 1.2));
        createNewLayoutRow();
        for each (var loc :LocationDesc in Locations.getLocationList()) {
            addLocation(loc);
        }
    }

    protected function clearProps (...ignored) :void
    {
        for each (var statName :String in ClientCtx.questProps.getPropNames()) {
            ClientCtx.questProps.clearProp(statName);
        }
    }

    protected function clearQuests (...ignored) :void
    {
        for each (var questId :int in ClientCtx.questData.activeAndCompleteQuestIds) {
            ClientCtx.questData.debugClearQuest(Quests.getQuest(questId));
            if (QuestClient.questPanel != null) {
                QuestClient.questPanel.debugForceDisplayUpdate();
            }
        }
    }

    protected function clearActivities (...ignored) :void
    {
        for each (var activity :ActivityDesc in ClientCtx.questData.unlockedActivities) {
            ClientCtx.questData.debugLockActivity(activity);
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

    protected static var log :Log = Log.getLog(DebugPanel);
}

}
