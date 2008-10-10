package {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.*;
import flash.net.*;

import com.adobe.serialization.json.JSON;

import com.threerings.util.Command;
import com.threerings.flash.FrameSprite;

import com.whirled.*;

[SWF(width="500", height="375")]
public class Feeder extends FrameSprite
{
    public function Feeder ()
    {
        //var top :Sprite = new Sprite();

        /*_title = new TextField();
        _title.text = "Hello";
        top.addEventListener(MouseEvent.CLICK, onTitleClick);
        _title.autoSize = TextFieldAutoSize.LEFT;
        _title.mouseEnabled = false;
        _story = new TextField();
        _story.y = 20;
        _story.text = "World";

        top.addChild(_title);
        top.buttonMode = true;
        top.addChild(_story);
        addChild(top);*/

        _ctrl = new ToyControl(this);
        DataPack.load(_ctrl.getDefaultDataPack(), onPack);
    }

    public function onPack (pack :DataPack) :void
    {
        _source = pack.getString("feed");

        update();
    }

    public function update () :void
    {
        var loader :URLLoader = new URLLoader();
        var request :URLRequest = new URLRequest();

        var query :URLVariables = new URLVariables();
        query.q = _source;
        query.v = "1.0";

        request.url = "http://ajax.googleapis.com/ajax/services/feed/load";
        request.data = query;

        Command.bind(loader,  Event.COMPLETE, function () :void {
            var json :Object = JSON.decode(loader.data);

            if (json.responseStatus != 200) {
                throw new Error(json.responseDetails);
            }

            setFeed(json.responseData.feed);
        });

        loader.load(request);
    }

    protected function setFeed (feed :Object) :void
    {
        _feed = feed;

        var text :String = _feed.title;
        if (_feed.description) {
            text += " - " + _feed.description;
        }
        var title :Label = new Label(text, _feed.link);
        addChild(title);

        setStory(0);
    }

    protected function setStory (index :int) :void
    {
        if (_story) {
            removeChild(_story);
        }

        _story = new Story(_feed.entries[index]);
        Command.bind(_story, MouseEvent.CLICK, setStory, (index+1)%_feed.entries.length);
        _story.y = 30;
        addChild(_story);
    }

    protected var _ctrl :ToyControl;
    protected var _source :String;

    protected var _story :Story;

    protected var _feed :Object;
}
}
