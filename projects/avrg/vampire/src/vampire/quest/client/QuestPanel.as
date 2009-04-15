package vampire.quest.client {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.text.TextField;

import vampire.quest.*;

public class QuestPanel extends DraggableObject
{
    public function QuestPanel () :void
    {
        _sprite = new Sprite();
        _draggableLayer = new Sprite();
        _sprite.addChild(_draggableLayer);
        _uiLayer = new Sprite();
        _sprite.addChild(_uiLayer);

        ClientCtx.mainLoop.topMode.addSceneObject(new MapView(), _uiLayer);

        var g :Graphics = _draggableLayer.graphics;
        g.lineStyle(1, 0xffffff);
        g.beginFill(0);
        g.drawRect(0, 0, WIDTH, HEIGHT);
        g.endFill();

        _tfQuestJuice = new TextField();
        _tfQuestJuice.x = 10;
        _tfQuestJuice.y = 340;
        _draggableLayer.addChild(_tfQuestJuice);
        updateQuestJuice();

        var title :TextField = TextBits.createText("Quests", 2, 0, 0xffffff);
        title.x = (_sprite.width - title.width) * 0.5;
        title.y = 350;
        _draggableLayer.addChild(title);

        registerListener(ClientCtx.questData, PlayerJuiceEvent.QUEST_JUICE_CHANGED,
            function (e :PlayerJuiceEvent) :void {
                updateQuestJuice();
            });
        registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_ADDED,
            function (e :PlayerQuestEvent) :void {
                addQuest(e.questId);
            });
        registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_COMPLETED,
            function (e :PlayerQuestEvent) :void {
                showQuestCompleted(e.questId);
                removeQuest(e.questId);
            });

        for each (var questId :int in ClientCtx.questData.activeQuests) {
            addQuest(questId);
        }
    }

    protected function updateQuestJuice () :void
    {
        var text :String = "Quest Juice: " + ClientCtx.questData.questJuice;
        TextBits.initTextField(_tfQuestJuice, text, 1.3, 0, 0x00ff00);
    }

    protected function addQuest (questId :int) :void
    {
        var questView :ActiveQuestView = new ActiveQuestView(questId);
        ClientCtx.mainLoop.topMode.addSceneObject(questView, _sprite);
        _activeQuestViews.push(questView);
        updateQuestViews();
    }

    protected function removeQuest (questId :int) :void
    {
        var idx :int = ArrayUtil.indexIf(_activeQuestViews,
            function (questView :ActiveQuestView) :Boolean {
                return questView.questId == questId;
            });

        if (idx >= 0) {
            var questView :ActiveQuestView = _activeQuestViews[idx];
            questView.destroySelf();
            _activeQuestViews.splice(idx, 1);
            updateQuestViews();
        }
    }

    protected function updateQuestViews () :void
    {
        var y :Number = 380;
        for each (var questView :ActiveQuestView in _activeQuestViews) {
            questView.x = 10;
            questView.y = y;

            y += questView.height + 5;
        }
    }

    protected function showQuestCompleted (questId :int) :void
    {

    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggableLayer;
    }

    protected var _locationViews :Array = [];
    protected var _activeQuestViews :Array = [];

    protected var _tfQuestJuice :TextField;

    protected var _sprite :Sprite;
    protected var _draggableLayer :Sprite;
    protected var _uiLayer :Sprite;

    protected static const WIDTH :Number = 700;
    protected static const HEIGHT :Number = 500;
}

}

import flash.display.Sprite;
import flash.text.TextField;
import flash.display.SimpleButton;

import vampire.quest.*;
import vampire.quest.client.*;
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.events.MouseEvent;
import flash.display.DisplayObject;

class ActiveQuestView extends SceneObject
{
    public function ActiveQuestView (questId :int)
    {
        _questId = questId;

        _sprite = new Sprite();

        _tfName = TextBits.createText(this.questDesc.displayName, 1.3, 0, 0x0000ff);
        _sprite.addChild(_tfName);

        _tfStatus = new TextField();
        _sprite.addChild(_tfStatus);

        _completeButton = new SimpleTextButton("Complete");
        _sprite.addChild(_completeButton);
        registerOneShotCallback(_completeButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.questData.completeQuest(_questId);
            });

        registerListener(ClientCtx.stats, PlayerStatEvent.STAT_CHANGED,
            function (statName :String) :void {
                updateView();
            });

        updateView();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get questDesc () :QuestDesc
    {
        return Quests.getQuest(_questId);
    }

    protected function updateView () :void
    {
        var desc :QuestDesc = this.questDesc;

        if (desc.isComplete(ClientCtx.stats)) {
            _completeButton.x = _tfName.x + _tfName.width + 10;
            _completeButton.visible = true;
            _tfStatus.visible = false;
        } else {
            var text :String = desc.description + " " + desc.getProgressText(ClientCtx.stats);
            TextBits.initTextField(_tfStatus, text, 1.3, 0,
                0xffffff);
            _tfStatus.x = _tfName.x + _tfName.width + 5;
            _tfStatus.visible = true;
            _completeButton.visible = false;
        }
    }

    public function get questId () :int
    {
        return _questId;
    }

    protected var _questId :int;

    protected var _sprite :Sprite;
    protected var _tfName :TextField;
    protected var _tfStatus :TextField;
    protected var _completeButton :SimpleButton;
}
