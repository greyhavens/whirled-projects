package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import vampire.client.ClientUtil;
import vampire.quest.client.npctalk.*;

public class NpcTalkPanel extends SceneObject
{
    public function NpcTalkPanel (program :Program)
    {
        _program = program;

        _npcPanel = ClientCtx.instantiateMovieClip("quest", "NPC_panel", false, true);

        var content :MovieClip = _npcPanel["draggable"];

        _tfSpeech = content["NPC_chat"];
        _tfSpeech.text = "";

        for (var ii :int = 0; ii < BUTTON_LOCS.length; ++ii) {
            var responseButton :SimpleButton = ClientCtx.instantiateButton("quest", "button_bubble");
            createResponseHandler(responseButton, ii);
            _responseButtons.push(responseButton);

            var loc :Point = BUTTON_LOCS[ii];
            responseButton.x = loc.x;
            responseButton.y = loc.y;
            _npcPanel.addChild(responseButton);
        }

        clearResponses();
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _program.run(this);
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_npcPanel);

        if (_program != null) {
            _program.exit();
            _program = null;
        }

        super.destroyed();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_program != null) {
            _program.update(dt);
            if (!_program.isRunning) {
                QuestClient.hideDockedPanel(true);
                QuestClient.showLastDisplayedLocationPanel();
                _program = null;
                return;
            }

            if (_needResponseUpdate) {
                updateResponses();
            }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _npcPanel;
    }

    public function say (speakerName :String, text :String) :void
    {
        _tfSpeech.text = text;

        // Clear the last response out every time something new is said
        ProgramCtx.lastResponseId = null;
    }

    public function setResponses (ids :Array, responses :Array) :void
    {
        if (responses.length != ids.length) {
            throw new Error("responses.length != ids.length");
        }

        _curResponseIds = ids;
        _curResponses = responses;
        _needResponseUpdate = true;
    }

    public function clearResponses () :void
    {
        setResponses([], []);
    }

    public function addResponse (id :String, response :String) :void
    {
        _curResponseIds.push(id);
        _curResponses.push(response);
        _needResponseUpdate = true;
    }

    protected function updateResponses () :void
    {
        if (_curResponseIds.length != _curResponses.length) {
            throw new Error("responses.length != ids.length");
        }

        for (var ii :int = 0; ii < _responseButtons.length; ++ii) {
            var button :SimpleButton = _responseButtons[ii];
            if (ii < _curResponses.length) {
                button.visible = true;
                ClientUtil.setButtonText(button, _curResponses[ii]);
            } else {
                button.visible = false;
            }
        }

        _needResponseUpdate = false;
    }

    protected function createResponseHandler (button :InteractiveObject, idx :int) :void
    {
        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                if (idx < _curResponseIds.length) {
                    ProgramCtx.lastResponseId = _curResponseIds[idx];
                }
            });
    }

    protected var _program :Program;

    protected var _npcPanel :MovieClip;
    protected var _tfSpeech :TextField;
    protected var _responseButtons :Array = [];

    protected var _curResponses :Array = [];
    protected var _curResponseIds :Array = [];
    protected var _needResponseUpdate :Boolean;

    protected static const BUTTON_LOCS :Array = [
        new Point(205, 163), new Point(205, 206), new Point(205, 249)
    ];
}

}
