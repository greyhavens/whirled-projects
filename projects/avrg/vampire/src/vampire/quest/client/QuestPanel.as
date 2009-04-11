package vampire.quest.client {

import flash.text.TextField;

import vampire.quest.PlayerQuestData;

public class QuestPanel extends GenericDraggableWindow
{
    public function QuestPanel (questData :PlayerQuestData) :void
    {
        super(500);
        _questData = questData;

        layoutElement(TextBits.createText("Quests", 3));
        createNewLayoutRow(10);
    }

    protected var _questData :PlayerQuestData;
}

}
