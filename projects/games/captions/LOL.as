package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.filters.GlowFilter;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.utils.ByteArray;
import flash.utils.Timer;

import fl.core.UIComponent;
import fl.containers.ScrollPane;
import fl.controls.Button;
import fl.controls.CheckBox;
import fl.controls.Label;
import fl.controls.ScrollPolicy;
import fl.controls.TextArea;
import fl.controls.TextInput;

import com.threerings.util.ClassUtil;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

import com.threerings.flash.DisplayUtil;

import com.threerings.ezgame.SizeChangedEvent;

import com.whirled.WhirledGameControl;

/**
 * TODO:
 * - save captioned images.
 * - be able to view the flickr page of an image.
 */
[SWF(width="700", height="500")]
public class LOL extends Sprite
{
    public static const DEBUG :Boolean = false;

    public function LOL () 
    {
        _ctrl = new WhirledGameControl(this);
        if (!_ctrl.isConnected()) {
            var oops :TextField = new TextField();
            oops.width = IDEAL_WIDTH;
            oops.height = IDEAL_HEIGHT;
            oops.multiline = true;
            oops.defaultTextFormat = _textFormat;
            oops.htmlText = "<P align=\"center\"><font size=\"+2\">LOLcaptions</font><br><br>" +
                "The fun flickr captioning game.<br><br>" +
                "This game is multiplayer and<br>must be played inside Whirled.</P>";
            addChild(oops);
            return;
        }

        _formatter = new LOLTextFieldFormatter();

        _ctrl.addEventListener(SizeChangedEvent.TYPE, handleSizeChanged);

        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, handleUILoaded);
        _loader.load(new UI() as ByteArray);

        _mask = new Shape();
        _mask.graphics.beginFill(0x000000, 1);
        _mask.graphics.drawRect(0, 0, IDEAL_WIDTH, IDEAL_HEIGHT);
        addChild(_mask);

        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _game = new CaptionGame(_ctrl);
        _game.addEventListener(CaptionGame.TICK_EVENT, updateClock);
        _game.addEventListener(CaptionGame.PHASE_CHANGED_EVENT, checkPhase);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleSubmitCaption);

        // get us rolling
        if (showPhoto()) {
            updateClock();
            checkPhase();
        }
    }

    protected function handleUILoaded (event :Event) :void
    {
        _ui = _loader.getContent() as MovieClip;
        _ui.mask = _mask;
        updateSize(_ctrl.getSize());
        addChild(_ui);
        _loader = null;

        trace(DisplayUtil.dumpHierarchy(_ui));

        // For some reason, when the movie wraps around, we need to re-grab all the bits
        _ui.addFrameScript(0, initUIBits);

        initUIBits();
        checkPhase();
    }


    protected function initUIBits () :void
    {
        // find all the children we care about
        for (var ii :int = 0; ii < 4; ii++) {
            var pp :ScrollPane = find("preview_pane_" + (ii + 1)) as ScrollPane;
            pp.horizontalScrollPolicy = ScrollPolicy.OFF;
            pp.verticalScrollPolicy = ScrollPolicy.OFF;
            pp.addEventListener(MouseEvent.CLICK, handlePreviewPhotoClick);
            pp.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
            pp.addEventListener(Event.COMPLETE, handleImageComplete);
            var pb :CheckBox = find("checkbox_" + (ii + 1)) as CheckBox;
            pb.addEventListener(Event.CHANGE, handlePreviewVote);
            _previewPane[ii] = pp;
            _previewBox[ii] = pb;
        }

        _image = find("image") as ScrollPane;
        _image.horizontalScrollPolicy = ScrollPolicy.OFF;
        _image.verticalScrollPolicy = ScrollPolicy.OFF;
        _skipBox = find("skip") as CheckBox;
        // TEMP?
        _skipBox.label = "              "; // so that it's more easily clickable

        // TEMP: have brittney place a TextField
        var ta :TextArea = find("text_input") as TextArea;
        //_input.setStyle("upSkin", new Shape());
        ta.visible = false;
        _input = new TextField();
        _input.type = TextFieldType.INPUT;
        _input.x = ta.x;
        _input.y = ta.y;
        _input.width = ta.width;
        _input.height = ta.height;
        ta.parent.addChild(_input);

        _clock = find("clock") as TextField;
        _clock.selectable = false;
        _doneButton = find("done") as Button;

        _doneButton.label = "";
        updateButtonSkin();

        _inputPalette = find("input_palette") as Sprite;

        _votingPane = find("voting_scrollpane") as ScrollPane;
        _resultsPane = find("results_scrollpane") as ScrollPane;

        _winningCaption = find("winning_caption") as TextField;
        _winnerName = find("winner_name") as TextField;
        _winnerName.selectable = false;

        _skipBox.addEventListener(Event.CHANGE, handleVoteToSkip);
        _doneButton.addEventListener(MouseEvent.CLICK, handleSubmitButton);

        _image.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
        _image.addEventListener(Event.COMPLETE, handleImageComplete);

        checkPhase(null);
    }

    /**
     * Helper for initUIBits.
     */
    protected function find (name :String) :DisplayObject
    {
        // find deeply
        return DisplayUtil.findInHierarchy(_ui, name, false);
    }

    protected function updateClock (... ignored) :void
    {
        var remaining :int = _game.getSecondsRemaining();

        var minStr :String = String(int(remaining / 60));
        var secStr :String = String(remaining % 60);
        if (secStr.length == 1) {
            secStr = "0" + secStr;
        }

        if (_clock != null) {
            _clock.text = minStr + ":" + secStr;
        }

        if (remaining == 0 && _game.getCurrentPhase() == CaptionGame.CAPTIONING_PHASE) {
            _timer.stop();
            handleSubmitCaption(); // one last time!
            if (_input != null) {
                _input.type = TextFieldType.DYNAMIC;
                //_input.editable = false;
                //_formatter.format(_input);
            }
            if (_doneButton != null) {
                _doneButton.enabled = false;
            }
        }
    }

    /**
     * @param arg null: don't change the current frame
     *            undefined: skip to current frame
     *            non-null: animate to current frame
     */
    protected function checkPhase (arg :* = undefined) :void
    {
        switch (_game.getCurrentPhase()) {
        case CaptionGame.CAPTIONING_PHASE:
            initCaptioning();
            break;

        case CaptionGame.VOTING_PHASE:
            initVoting();
            break;

        case CaptionGame.RESULTS_PHASE:
            initResults();
            break;
        }

        if (arg !== null) {
            var animate :Boolean = (arg !== undefined);
            showFrame(animate);
        }
    }

    protected function showPhoto () :Boolean
    {
        var url :String = _game.getPhoto();
        if (url != null) {
            if (_image != null) {
                loadIntoPane(_image, url);
            }
            return true;
        }

        return false;
    }

    protected function loadIntoPane (pane :ScrollPane, url :String) :void
    {
        if (url != null) {
            pane.load(new URLRequest(url),
                new LoaderContext(true, ApplicationDomain.currentDomain));
        } else {
            pane.source = null;
        }
    }

    protected function handleSubmitButton (event :Event) :void
    {
        var nowEditing :Boolean = (_input.type == TextFieldType.DYNAMIC);

        if (!nowEditing && _input.text == "") {
            // don't let them be "done" with nothing
            return;
        }

        _input.type = nowEditing ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
        colorInputPalette();

        //_doneButton.label = nowEditing ? "Done" : "Edit";
        updateButtonSkin();

        if (!nowEditing) {
            handleSubmitCaption(event);

        } else {
            _input.stage.focus = _input;
            _input.setSelection(_input.length, _input.length);
        }
    }

    /**
     * Called both by the Timer event and when the user presses the (largely unneeded)
     * enter button.
     */
    protected function handleSubmitCaption (event :Event = null) :void
    {
        if (_input != null) {
            _game.submitCaption(_input.text);
        }
    }

    protected function handleVoteToSkip (event :Event) :void
    {
        _game.voteToSkipPhoto(_skipBox.selected);
    }

    protected function handleCaptionVote (event :Event) :void
    {
        var box :DataCheckBox = (event.currentTarget as DataCheckBox);
        var value :int = int(box.data);
        _game.setCaptionVote(value, box.selected);
    }

    protected function handlePreviewPhotoClick (event :MouseEvent) :void
    {
        var pane :ScrollPane = event.currentTarget as ScrollPane;

        for (var ii :int = 0; ii < 4; ii++) {
            if (pane == _previewPane[ii]) {
                var box :CheckBox = _previewBox[ii] as CheckBox;
                if (box.enabled && box.visible) {
                    box.selected = !box.selected;
                    // and manually submit the vote
                    _game.setPreviewVote(ii, box.selected);
                }
                return;
            }
        }

        trace("DO NOT WANT");
        Log.dumpStack();
    }

    protected function handlePreviewVote (event :Event) :void
    {
        var box :CheckBox = (event.currentTarget as CheckBox);
        for (var ii :int = 0; ii < 4; ii++) {
            if (box == _previewBox[ii]) {
                _game.setPreviewVote(ii, box.selected);
                return;
            }
        }

        trace("DO NOT WANT");
        Log.dumpStack();
    }

    protected function colorInputPalette () :void
    {
        var g :Graphics = _inputPalette.graphics;
        g.clear();
        g.beginFill(0xFFFFFF, (_input.type == TextFieldType.INPUT) ? .25 : 0);
        g.drawRoundRect(0, 0, _inputPalette.width, _inputPalette.height, 10, 10);
    }

    protected function updateButtonSkin () :void
    {
        // go ahead and instantiate the skins so that they switch smoother later
        var upSkin :DisplayObject;
        var downSkin :DisplayObject;
        if (_input.type == TextFieldType.INPUT) {
            upSkin = new DONE_UP_SKIN() as DisplayObject;
            downSkin = new DONE_DOWN_SKIN() as DisplayObject;
        } else {
            upSkin = new EDIT_UP_SKIN() as DisplayObject;
            downSkin = new EDIT_DOWN_SKIN() as DisplayObject;
        }

        _doneButton.setStyle("upSkin", upSkin);
        _doneButton.setStyle("overSkin", upSkin);
        _doneButton.setStyle("downSkin", downSkin);
        _doneButton.setStyle("disabledSkin", downSkin);
    }

    protected function initCaptioning () :void
    {
        if (_input == null || _input.stage == null) {
            return;
        }
        showPhoto();

        _votingPane.source = null;
        _resultsPane.source = null;

        _input.text = "";
        _formatter.watch(_input);
        _doneButton.enabled = true;
        _skipBox.selected = false;
        colorInputPalette();

        _timer.start();
    }

    protected function initVoting () :void
    {
        _resultsPane.source = null;
        _timer.stop();
        var caps :Array = _game.getVotableCaptions();
        var ourIdx :int = _game.getOurCaptionIndex();

        var s :Sprite = new Sprite();
for (var jj :int = 0; jj < 1; jj++) {
        for (var ii :int = 0; ii < caps.length; ii++) {
            var cb :DataCheckBox = new DataCheckBox();
            cb.label = deHTML(String(caps[ii]));

            cb.setStyle("disabledTextFormat", _textFormat);
            cb.setStyle("textFormat", _textFormat);
            cb.data = ii;
            cb.addEventListener(Event.CHANGE, handleCaptionVote);
            if (ii == ourIdx) {
                cb.enabled = false;
            }
            cb.setSize(400, 22);
            cb.y = (jj * 100) + ii * 25;

            s.addChild(cb);
        }
}
        _votingPane.verticalScrollPosition = 0;
        _votingPane.source = s;
    }

    protected function initResults () :void
    {
        _votingPane.source = null;
        _timer.stop();

        var results :Array = _game.getResults();
        var s :Sprite = new Sprite();
for (var jj :int = 0; jj < 1; jj++) {
        for (var ii :int = 0; ii < results.length; ii++) {
            var result :Object = results[ii];
            var y :int = (jj * 100) + (ii * 25);

            var lbl :Label = new Label();
            lbl.setStyle("textFormat", _textFormat);
            lbl.text = deHTML(String(result.caption));
            lbl.setSize(300, 42);
            lbl.x = 50;
            lbl.y = y;
            s.addChild(lbl);
            
            var name :Label = new Label();
            name.setStyle("textFormat", _textFormat);
            name.text = "- " + result.playerName + ", " + result.votes;
            name.setSize(100, 42);
            name.x = 350;
            name.y = y;
            s.addChild(name);

            if (ii == 0) {
                displayWinningCaption(String(result.caption), String(result.playerName));
            }

            var icon :Class = null;
            if (result.winner) {
                icon = WINNER_ICON;

            } else if (result.disqual) {
                icon = DISQUAL_ICON;
            }

            if (icon != null) {
                var dicon :DisplayObject = new icon() as DisplayObject;
                dicon.y = y;
                s.addChild(dicon);
            }
        }
}
        _resultsPane.verticalScrollPosition = 0;
        _resultsPane.source = s;

        // see if there are any preview pics to vote on...
        var previews :Array = _game.getPreviews();
        for (var count :int = 0; count < 4; count++) {
            var pp :ScrollPane = _previewPane[count] as ScrollPane;
            var pb :CheckBox = _previewBox[count] as CheckBox;
            var url :String = previews[count] as String;
            loadIntoPane(pp, url);
            pp.visible = (url != null);
            pb.selected = false;
            pb.visible = (url != null);
        }
    }

    protected function displayWinningCaption (caption :String, name :String) :void
    {
        _winningCaption.text = caption;

        var star :DisplayObject = new STAR_ICON() as DisplayObject;

        var truncing :Boolean = false;
        while (true) {
            _winnerName.text = name + (truncing ? "..." : "") + " wins!";

            if (_winnerName.textWidth + star.width < IDEAL_WIDTH) {
                break;
            }

            if (truncing) {
                name = name.substr(0, name.length - 1);
            } else {
                name = name.substr(0, name.length -  3);
                truncing = true;
            }
        }

        // then add the star
        const PAD :int = 10;
        star.y = _winnerName.y;
        star.x = _winnerName.x + (IDEAL_WIDTH - _winnerName.textWidth) / 2 - star.width - PAD;
        _winnerName.parent.addChild(star);
    }

    protected function deHTML (s :String) :String
    {
        s = s.replace("&", "&amp;");
        s = s.replace("<", "&lt;");
        s = s.replace(">", "&gt;");

        return s;
    }

    /**
     * Handle image loading.
     */
    protected function handleImageProgress (event :ProgressEvent) :void
    {
        centerImage(event.currentTarget as ScrollPane);
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
        centerImage(event.currentTarget as ScrollPane);
    }

    /**
     * Get the _ui sequence for the current phase.
     */
    protected function getFrameForPhase () :String
    {
        switch (_game.getCurrentPhase()) {
        default:
            return "caption";

        case CaptionGame.VOTING_PHASE:
            return "voting";

        case CaptionGame.RESULTS_PHASE:
            return "results";
        }
    }

    protected function showFrame (animate :Boolean = true) :void
    {
        if (_ui == null) {
            return;
        }

        var frame :String = getFrameForPhase();
        if (!animate) {
            frame += "_end";
        }
        trace((animate ? "animating" : "skipping") + " to frame " + frame);
        _ui.gotoAndPlay(frame);
    }

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        updateSize(event.size);
    }

    protected function updateSize (size :Point) :void
    {
        var width :int = Math.max(size.x, IDEAL_WIDTH);
        var height :int = Math.max(size.y, IDEAL_HEIGHT);

        this.graphics.clear();
        this.graphics.beginFill(0x000000, 1);
        this.graphics.drawRect(0, 0, width, height);

        _ui.x = _mask.x = (width - IDEAL_WIDTH) / 2;
        _ui.y = _mask.y = (height - IDEAL_HEIGHT) / 2;
    }

    protected function centerImage (pane :ScrollPane) :void
    {
        if (pane.content == null) {
            return;
        }
        var w :int = pane.content.width;
        var h :int = pane.content.height;

        var size :int = (pane == _image) ? 500 : 100;

        pane.x = (size - w) / 2;
        pane.y = (size - h) / 2;
    }

    protected function handleUnload (... ignored) :void
    {
        _timer.reset();
    }

    [Embed(source="rsrc/winner_icon.png")]
    protected static const WINNER_ICON :Class;

    [Embed(source="rsrc/dq_icon.png")]
    protected static const DISQUAL_ICON :Class;

    [Embed(source="rsrc/Star.swf")]
    protected static const STAR_ICON :Class;

    [Embed(source="rsrc/DoneButton.swf")]
    protected static const DONE_UP_SKIN :Class;

    [Embed(source="rsrc/DoneClick.swf")]
    protected static const DONE_DOWN_SKIN :Class;

    [Embed(source="rsrc/EditButton.swf")]
    protected static const EDIT_UP_SKIN :Class;

    [Embed(source="rsrc/EditClick.swf")]
    protected static const EDIT_DOWN_SKIN :Class;

    [Embed(source="rsrc/ui.swf", mimeType="application/octet-stream")]
    protected static const UI :Class;

    protected static const IDEAL_WIDTH :int = 700;

    protected static const IDEAL_HEIGHT :int = 500;

    protected var _ctrl :WhirledGameControl;

    protected var _game :CaptionGame;

    protected var _ui :MovieClip;

    protected var _mask :Shape;

    protected var _formatter :LOLTextFieldFormatter;

    protected var _loader :EmbeddedSwfLoader;

    protected var _frameReachedCallback :Function;

    protected var _textFormat :TextFormat = new TextFormat(
        "_sans", 24, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);

    protected var _image :ScrollPane;

    protected var _skipBox :CheckBox;

    protected var _input :TextField;

    protected var _inputPalette :Sprite;

    protected var _clock :TextField;

    protected var _winnerName :TextField;

    protected var _winningCaption :TextField;

    protected var _votingPane :ScrollPane;
    protected var _resultsPane :ScrollPane;

    protected var _doneButton :Button;

    protected var _previewPane :Array = [];

    protected var _previewBox :Array = [];

//
//    /** Whether the caption is on the bottom or top. */
//    protected var _captionOnBottom :Boolean;

    protected var _timer :Timer;
}
}
