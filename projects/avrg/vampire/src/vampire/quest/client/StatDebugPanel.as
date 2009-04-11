package vampire.quest.client {

import flash.text.TextField;

import vampire.quest.PlayerQuestStats;

public class StatDebugPanel extends GenericDraggableWindow
{
    public function StatDebugPanel (stats :PlayerQuestStats) :void
    {
        super(500);
        _stats = stats;

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
            _stats.setStat(getEnteredName(), getEnteredVal());
        });

        createButton("Get Stat", function (...ignored) :void {
            var name :String = getEnteredName();
            setStatusText("Stat", "name", name, "val", _stats.getStat(name));
        });

        createButton("List Stats", function (...ignored) :void {
            setStatusText("Stats", "names", _stats.getStatNames());
        });
    }

    protected function getEnteredName () :String
    {
        return _nameField.text;
    }

    protected function getEnteredVal () :Object
    {
        var text :String = _valueField.text;
        return (text == null || text.length == 0 || text == "null" ? null : text);
    }

    protected var _stats :PlayerQuestStats;

    protected var _nameField :TextField;
    protected var _valueField :TextField;
}

}
