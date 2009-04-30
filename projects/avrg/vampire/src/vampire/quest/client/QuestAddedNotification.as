package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

import vampire.quest.*;

public class QuestAddedNotification extends SceneObject
{
    public function QuestAddedNotification (quest :QuestDesc)
    {
        _movie = ClientCtx.instantiateMovieClip("quest", "popup_sitequest");

        var contents :MovieClip = _movie["contents"];
        var tfGranter :TextField = contents["context_name"];
        var tfQuestName :TextField = contents["item_name"];

        tfGranter.text = quest.npcName;
        tfQuestName.text = quest.displayName;

        var iconPlaceholder :MovieClip = contents["quest_icon_placeholder"];
        iconPlaceholder.addChild(ClientCtx.instantiateMovieClip("quest", quest.npcPortraitName));
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
}

}
