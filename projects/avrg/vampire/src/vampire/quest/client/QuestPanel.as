package vampire.quest.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.*;

public class QuestPanel extends SceneObject
{
    public function QuestPanel ()
    {
        _panelMovie = ClientCtx.instantiateMovieClip("quest", "quest_panel");

        var contents :MovieClip = _panelMovie["draggable"];
        _tfJuice = contents["juice_total"];

        var self :QuestPanel = this;
        var closeBtn :SimpleButton = _panelMovie["close"];
        registerListener(closeBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.dockSprite.hideDockedPanel(self, false);
            });
        registerListener(ClientCtx.questData, PlayerJuiceEvent.QUEST_JUICE_CHANGED,
            function (e :PlayerJuiceEvent) :void {
                updateQuestJuice();
            });

        // Location buttons
        for each (var loc :LocationDesc in Locations.getLocationList()) {
            var locBtn :SimpleButton = contents[loc.name];
            if (locBtn != null) {
                registerLocButtonListener(locBtn, loc);
            } else {
                log.warning("Can't find location button", "loc", loc);
            }
        }

        // Quest list
        _questList = new QuestListController(contents, _panelMovie["button_up"],
            _panelMovie["button_down"]);

        updateQuestJuice();
    }

    override protected function destroyed () :void
    {
        _questList.shutdown();
    }

    protected function registerLocButtonListener (btn :SimpleButton, loc :LocationDesc) :void
    {
        registerListener(btn, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.dockSprite.showLocationPanel(loc);
            });
    }

    protected function updateQuestJuice () :void
    {
        _tfJuice.text = String(ClientCtx.questData.questJuice);
    }

    override public function get displayObject () :DisplayObject
    {
        return _panelMovie;
    }

    protected var _sprite :Sprite;
    protected var _dockedPanelLayer :Sprite;
    protected var _panelMovie :MovieClip;
    protected var _tfJuice :TextField;
    protected var _questList :QuestListController;

    protected static var log :Log = Log.getLog(QuestPanel);
}

}
