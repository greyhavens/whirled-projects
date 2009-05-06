package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.client.SpriteUtil;
import vampire.quest.*;

public class QuestNotification extends SceneObject
{
    public function QuestNotification (quest :QuestDesc, questStatus :int)
    {
        _quest = quest;
        _status = questStatus;

        _sprite = SpriteUtil.createSprite();
    }

    override protected function addedToDB () :void
    {
        var movie :MovieClip = ClientCtx.instantiateMovieClip("quest", "popup_sitequest");

        var contents :MovieClip = movie["contents"];
        var tfGranter :TextField = contents["context_name"];
        var tfQuestName :TextField = contents["item_name"];

        tfGranter.text = _quest.npcName + "'s Quest";
        tfQuestName.text = _quest.displayName;

        var iconPlaceholder :MovieClip = contents["quest_icon_placeholder"];
        iconPlaceholder.addChild(ClientCtx.instantiateMovieClip("quest", _quest.npcPortraitName));

        var burst :MovieClip = contents["complete_burst"];
        var checkmark :MovieClip = contents["complete_check"];
        if (_status != PlayerQuestData.STATUS_COMPLETE) {
            burst.parent.removeChild(burst);
            checkmark.parent.removeChild(checkmark);
        }

        _sprite.addChild(movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _quest :QuestDesc;
    protected var _status :int;
}

}
