package {

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.net.*;

import com.adobe.serialization.json.JSON;

import fl.containers.ScrollPane;
import fl.controls.*;
import fl.skins.*;

import com.threerings.util.Command;

import com.whirled.*;

[SWF(width="335", height="268")]
public class Feeder extends Sprite
{
    DefaultScrollPaneSkins;
    DefaultButtonSkins;

    public function Feeder ()
    {
        _ctrl = new ToyControl(this);
        DataPack.load(_ctrl.getDefaultDataPack(), onPack);
    }

    public function onPack (pack :DataPack) :void
    {
        _source = pack.getString("Feed");
        _sourceCount = pack.getNumber("Count");

        update();
    }

    public function update () :void
    {
        var loader :URLLoader = new URLLoader();
        var request :URLRequest = new URLRequest();

        var query :URLVariables = new URLVariables();
        query.q = _source;
        query.v = "1.0";
        query.num = _sourceCount;

        request.url = "http://ajax.googleapis.com/ajax/services/feed/load";
        request.data = query;

        Command.bind(loader,  Event.COMPLETE, function () :void {
            var json :Object = JSON.decode(loader.data);

            if (json.responseStatus != 200) {
                var error :TextField = new TextField();
                error.text = json.responseDetails;
                error.autoSize = TextFieldAutoSize.LEFT;
                addChild(error);
                throw new Error(json.responseDetails);
            }

            setFeed(json.responseData.feed);
        });

        loader.load(request);
    }

    protected function setFeed (feed :Object) :void
    {
        _feed = feed;

        var title :TextField = new TextField();
        title.styleSheet = Story.createStyleSheet();
        title.htmlText += "<a class='title' href='event:"+_feed.link+"'>"+_feed.title+"</a>";
        title.addEventListener(TextEvent.LINK, function (event :TextEvent) :void {
            navigateToURL(new URLRequest(event.text));
        });
        if (_feed.description) {
            title.htmlText += " :: " + _feed.description;
        }
        addChild(title);

        var prev :Button = createButton(PREV, 3);
        Command.bind(prev, MouseEvent.CLICK, nextStory, -1);
        addChild(prev);

        title.width = prev.x;

        var next :Button = createButton(NEXT, 2);
        Command.bind(next, MouseEvent.CLICK, nextStory, +1);
        addChild(next);

        var reload :Button = createButton(RELOAD, 1);
        Command.bind(reload, MouseEvent.CLICK, update);
        addChild(reload);

        _index = 0;
        nextStory(0);
    }

    protected function createButton (icon :Class, right :int) :Button
    {
        var button :Button = new Button();
        button.label = "";
        button.setStyle("icon", DisplayObject(new icon()));
        button.x = 320+ScrollBar.WIDTH - right*30;
        button.setSize(30, 20);
        return button;
    }

    protected function nextStory (delta :int) :void
    {
        _index = (_index+delta) % _feed.entries.length;
        while (_index < 0) {
            _index += _feed.entries.length;
        }

        setStory(new Story(_feed.entries[_index]));
    }

    protected function setStory (story :Story) :void
    {
        if (_storyPanel != null) {
            removeChild(_storyPanel);
        }

        //Command.bind(story, MouseEvent.CLICK, setStory, (index+1)%_feed.entries.length);
        //_story.y = 30;

        _storyPanel = new ScrollPane();
        _storyPanel.verticalScrollPolicy = ScrollPolicy.AUTO;
        _storyPanel.horizontalScrollPolicy = ScrollPolicy.AUTO;
        _storyPanel.y = 30;
        _storyPanel.width = 320+ScrollBar.WIDTH;
        _storyPanel.height = 240;

        Command.bind(story, Event.CHANGE, function () :void {
            story.width = story.width; // Needed to force the width to update. Only in Flash...
            _storyPanel.update();
        });

        _storyPanel.source = story;
        addChild(_storyPanel);
    }

    protected var _ctrl :ToyControl;
    protected var _source :String;
    protected var _sourceCount :int;

    protected var _storyPanel :ScrollPane;

    protected var _feed :Object;
    protected var _index :int;

    [Embed(source="arrow_left.png")]
    protected static const PREV :Class;
    [Embed(source="arrow_rotate_clockwise.png")]
    protected static const RELOAD :Class;
    [Embed(source="arrow_right.png")]
    protected static const NEXT :Class;
}
}
