package vampire.quest.client.npctalk {

import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.client.TextBits;

public class TalkView extends DraggableObject
{
    public function TalkView (program :Program)
    {
        _program = program;

        _sprite = new Sprite();
        var g :Graphics = _sprite.graphics;
        g.lineStyle(3, 0xffffff);
        g.beginFill(0x990000);
        g.drawRect(0, 0, 400, 250);
        g.endFill();

        _tfSpeaker = new TextField();
        _sprite.addChild(_tfSpeaker);
        _tfSpeech = new TextField();
        _sprite.addChild(_tfSpeech);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _program.run(this);
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        _program.update(dt);
        if (_program.isDone) {
            destroySelf();
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function say (speakerName :String, text :String) :void
    {
        TextBits.initTextField(_tfSpeaker, speakerName, 1.5, 0, 0x0000ff);
        TextBits.initTextField(_tfSpeech, text, 1.5, WIDTH - 20, 0xffffff, "left");

        updateView();
    }

    public function setResponses (ids :Array, responses :Array) :void
    {
        if (responses.length != ids.length) {
            throw new Error("responses.length != ids.length");
        }

        if (_responseButtons.length > 0) {
            for each (var button :SimpleButton in _responseButtons) {
                button.parent.removeChild(button);
            }

            _responseButtons = [];
        }

        for (var ii :int = 0; ii < responses.length; ++ii) {
            var response :String = responses[ii];
            var id :String = ids[ii];
            var textButton :SimpleButton = new SimpleButton(
                TextBits.createText(response, 1.2, WIDTH - 20, 0, "left"),
                TextBits.createText(response, 1.2, WIDTH - 20, 0xffffff, "left"),
                TextBits.createText(response, 1.2, WIDTH - 20, 0xffffff, "left"),
                TextBits.createText(response, 1.2, WIDTH - 20, 0xffffff, "left"));

            createResponseHandler(textButton, id);

            _responseButtons.push(textButton);
            _sprite.addChild(textButton);
        }

        // Clear the last response out every time a new set of responses is created
        ProgramCtx.lastResponseId = null;

        updateView();
    }

    protected function createResponseHandler (button :SimpleButton, responseId :String) :void
    {
        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                ProgramCtx.lastResponseId = responseId;
            });
    }

    protected function updateView () :void
    {
        var y :Number = 10;

        _tfSpeaker.x = 10;
        _tfSpeaker.y = y;
        y += _tfSpeaker.height + 5;

        _tfSpeech.x = 10;
        _tfSpeech.y = y;
        y += _tfSpeech.height + 10;

        for each (var button :DisplayObject in _responseButtons) {
            button.x = 10;
            button.y = y;
            y += button.height + 1;
        }
    }

    protected var _program :Program;

    protected var _sprite :Sprite;
    protected var _tfSpeaker :TextField;
    protected var _tfSpeech :TextField;
    protected var _responseButtons :Array = [];

    protected static const WIDTH :Number = 400;
    protected static const HEIGHT :Number = 250;
}

}
