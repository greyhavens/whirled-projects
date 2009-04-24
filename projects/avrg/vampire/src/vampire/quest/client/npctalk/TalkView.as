package vampire.quest.client.npctalk {

import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.client.*;

public class TalkView extends DraggableObject
{
    public function TalkView (program :Program)
    {
        _program = program;

        _npcPanel = ClientCtx.instantiateMovieClip("quest", "NPC_panel", false, true);
        _tfSpeech = _npcPanel["NPC_chat"];
        _tfSpeech.text = "";

        for (var ii :int = 0; ii < 3; ++ii) {
            var tfResponse :TextField = _npcPanel["player_answer_0" + String(ii + 1)];
            tfResponse.text = "";
            createResponseHandler(tfResponse, ii);
            _tfResponses.push(tfResponse);
        }
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _program.run(this);
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_npcPanel);
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        _program.update(dt);
        if (!_program.isRunning) {
            destroySelf();
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _npcPanel;
    }

    public function say (speakerName :String, text :String) :void
    {
        _tfSpeech.text = text;
    }

    public function setResponses (ids :Array, responses :Array) :void
    {
        if (responses.length != ids.length) {
            throw new Error("responses.length != ids.length");
        }

        _curResponseIds = ids;

        for (var ii :int = 0; ii < _tfResponses.length; ++ii) {
            var tfResponse :TextField = _tfResponses[ii];
            tfResponse.text = (ii < responses.length ? responses[ii] : "");
        }

        // Clear the last response out every time a new set of responses is created
        ProgramCtx.lastResponseId = null;
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
    protected var _tfResponses :Array = [];

    protected var _curResponseIds :Array = [];
}

}
