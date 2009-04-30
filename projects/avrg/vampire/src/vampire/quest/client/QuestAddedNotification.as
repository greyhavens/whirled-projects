package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.feeding.client.SpriteUtil;
import vampire.quest.*;

public class QuestAddedNotification extends SceneObject
{
    public function QuestAddedNotification (quest :QuestDesc)
    {
        _quest = quest;
        _sprite = SpriteUtil.createSprite();
    }

    override protected function addedToDB () :void
    {
        var movie :MovieClip = ClientCtx.instantiateMovieClip("quest", "popup_sitequest");

        var contents :MovieClip = movie["contents"];
        var tfGranter :TextField = contents["context_name"];
        var tfQuestName :TextField = contents["item_name"];

        tfGranter.text = _quest.npcName;
        tfQuestName.text = _quest.displayName;

        var iconPlaceholder :MovieClip = contents["quest_icon_placeholder"];
        iconPlaceholder.addChild(ClientCtx.instantiateMovieClip("quest", _quest.npcPortraitName));

        _sprite.addChild(movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _quest :QuestDesc;
}

}
