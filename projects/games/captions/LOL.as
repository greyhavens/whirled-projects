package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.LoaderInfo;
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
import fl.containers.UILoader;
import fl.controls.Button;
import fl.controls.CheckBox;
import fl.controls.Label;
import fl.controls.ScrollPolicy;
import fl.controls.TextArea;
import fl.controls.TextInput;

import com.threerings.util.ClassUtil;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;
import com.threerings.util.StringUtil;

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
        _game.addEventListener(CaptionGame.PHASE_CHANGED_EVENT, handlePhaseChanged);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleSubmitCaption);

        // get us rolling
        if (showPhoto()) {
            updateClock();
            checkPhase(SKIP_TO_FRAME);
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
        checkPhase(SKIP_TO_FRAME);
    }


    protected function initUIBits () :void
    {
        // find all the children we care about
        for (var ii :int = 0; ii < 4; ii++) {
            var pi :UILoader = find("preview_pane_" + (ii + 1)) as UILoader;
            pi.addEventListener(MouseEvent.CLICK, handlePreviewPhotoClick);
            pi.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
            pi.addEventListener(Event.COMPLETE, handleImageComplete);
            var pb :CheckBox = find("checkbox_" + (ii + 1)) as CheckBox;
            pb.addEventListener(Event.CHANGE, handlePreviewVote);
            _previewImage[ii] = pi;
            _previewBox[ii] = pb;
        }

        _image = find("image") as UILoader;
        _skipBox = find("skip") as CheckBox;
        _skipBox.label = "              "; // so that it's more easily clickable

        _input = find("text_input") as TextField;
        _input.height = 200;

        _clock = find("clock") as TextField;
        _clock.selectable = false;
        _doneButton = find("done") as Button;

        _doneButton.label = "";
        updateButtonSkin();

        _inputPalette = find("input_palette") as Sprite;

        _votingPane = find("voting_scrollpane") as ScrollPane;
        _resultsPane = find("results_scrollpane") as ScrollPane;

        _winningCaption = find("winning_caption") as TextField;
        // TEMP?
        _winningCaption.selectable = false;
        _winningCaption.mouseEnabled = false;
        _winnerName = find("winner_name") as TextField;
        _winnerName.selectable = false;

        _skipBox.addEventListener(Event.CHANGE, handleVoteToSkip);
        _doneButton.addEventListener(MouseEvent.CLICK, handleSubmitButton);

        _image.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
        _image.addEventListener(Event.COMPLETE, handleImageComplete);


        // set up LOL formatting on the two textfields
        _formatter.watch(_input, handleTextFieldChanged);
        _formatter.watch(_winningCaption);

        checkPhase(DONT_ALTER_FRAME);
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
     * @param frameBehavior one of ANIMATE_TO_FRAME, SKIP_TO_FRAME, DONT_ALTER_FRAME.
     */
    protected function checkPhase (frameBehavior :int) :void
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

        if (frameBehavior != DONT_ALTER_FRAME) {
            showFrame(frameBehavior == ANIMATE_TO_FRAME);
        }
    }

    protected function showPhoto () :Boolean
    {
        var url :String = _game.getPhoto();
        if (url != null) {
            if (_image != null) {
                loadInto(_image, url);
            }
            return true;
        }

        return false;
    }

    protected function loadInto (image :UILoader, url :String) :void
    {
        if (url != null) {
            image.load(new URLRequest(url),
                new LoaderContext(true, ApplicationDomain.currentDomain));
        } else {
            image.source = null;
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
        _input.selectable = nowEditing;
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
        var image :UILoader = event.currentTarget as UILoader;

        for (var ii :int = 0; ii < 4; ii++) {
            if (image == _previewImage[ii]) {
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
        if (_input.type == TextFieldType.INPUT) {
            var w :int = MIN_IMAGE_WIDTH;
            if (_image.content != null) {
                w = Math.max(_image.content.width, w);
            }

            g.beginFill(0xFFFFFF, .25);
            g.drawRoundRect((_inputPalette.width - w) / 2, 0, w, _input.textHeight + 4, 10, 10);
        }
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

        _input.type = TextFieldType.INPUT;
        _input.text = "";
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
        // set up an unnoticable glow filter so that we fade correctly
        s.filters = [ new GlowFilter(0xFFFFFF, .01, 1, 1, 1) ];
        const GAP :int = 10;
        var yPos :int = 0;
for (var jj :int = 0; jj < 20; jj++) {
        for (var ii :int = 0; ii < caps.length; ii++) {
            var cb :DataCheckBox = new DataCheckBox();
            cb.data = ii;
            cb.setStyle("disabledTextFormat", _textFormat);
            cb.setStyle("textFormat", _textFormat);
            cb.label = deHTML(String(caps[ii]));
            cb.textField.width = PANE_WIDTH - 30;
            cb.textField.wordWrap = true;

            cb.addEventListener(Event.CHANGE, handleCaptionVote);
            if (ii == ourIdx) {
                cb.enabled = false;
            }
            cb.setSize(PANE_WIDTH, 22);
            cb.validateNow();
            var height :int = cb.textField.textHeight + 4;
            cb.setSize(PANE_WIDTH, height);
            cb.y = yPos;
            yPos += height + GAP;

            s.addChild(cb);
        }
}
        _votingPane.verticalScrollPosition = 0;
        _votingPane.source = s;
    }

    protected function initResults () :void
    {
        _timer.stop();

        var results :Array = _game.getResults();
        var s :Sprite = new Sprite();
        // set up an unnoticable glow filter so that we fade correctly
        s.filters = [ new GlowFilter(0xFFFFFF, .01, 1, 1, 1) ];
        const GAP :int = 10;
        var yPos :int = 0;
for (var jj :int = 0; jj < 20; jj++) {
        for (var ii :int = 0; ii < results.length; ii++) {
            var result :Object = results[ii];
            var width :int = PANE_WIDTH;

            var votes :Label = new Label();
            votes.setStyle("textFormat", _textFormat);
            votes.text = ", " + result.votes;
            votes.setSize(46, 30);
            votes.validateNow();
            width -= votes.textField.textWidth + 5;
            votes.textField.width = votes.textField.textWidth + 5;
            votes.x = width;
            votes.y = yPos;
            s.addChild(votes);

            var name :Label = new Label();
            name.setStyle("textFormat", _textFormat);
            name.text = "- " + result.playerName;
            name.setSize(100, 30);
            width -= 100 + 5;
            name.x = width;
            name.y = yPos;
            s.addChild(name);

            var lbl :Label = new Label();
            lbl.setStyle("textFormat", _textFormat);
            lbl.text = deHTML(String(result.caption));
            lbl.textField.wordWrap = true;
            lbl.setSize(width, 30);
            lbl.validateNow();
            var height :int = lbl.textField.textHeight + 4;
            lbl.setSize(width, height);
            lbl.x = 0;
            lbl.y = yPos;
            s.addChild(lbl);

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
                dicon.y = yPos;
                s.addChild(dicon);
            }

            yPos += height + GAP;
        }
}
        _resultsPane.verticalScrollPosition = 0;
        _resultsPane.source = s;

        // see if there are any preview pics to vote on...
        var previews :Array = _game.getPreviews();
        for (var count :int = 0; count < 4; count++) {
            var pi :UILoader = _previewImage[count] as UILoader;
            var pb :CheckBox = _previewBox[count] as CheckBox;
            var url :String = previews[count] as String;
            loadInto(pi, url);
            pi.visible = (url != null);
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
        // TODO: See if we can properly access the width/height DURING loading.
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
        // and also update the text field position
        if (_input != null) {
            trace("Image complete: updating input");
            handleTextFieldChanged(_input);
        }
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
        _ui.gotoAndPlay(frame);
    }

    protected function handleTextFieldChanged (field :TextField) :void
    {
        var w :int = MIN_IMAGE_WIDTH;
        var h :int = 500;
        // position the field properly over the image control
        if (_image.content != null) {
            w = Math.max(w, _image.content.width);
            h = _image.content.height;
        }

        field.width = w;
        field.background = true;
        field.backgroundColor = 0xFF0000;
        field.alpha = .30;

        var fieldHeight :int;

        // TESTING
        if (StringUtil.isBlank(field.text) && field.text != "") {
            trace("-===-=-=======================");
        }
        if (field.text == "") {
            field.text = "W";
            fieldHeight = field.textHeight + 4;
            field.text = "";

        } else {
            fieldHeight = field.textHeight + 4;
        }

        if (fieldHeight < 10) {
            trace("text is '" + field.text + "'");
            Log.dumpStack();
        }

        trace("Field width: " + w);
        trace("Field textHeight: " + fieldHeight);

        var p :Point = new Point((500 - w) / 2, (500 - h) / 2 + h - fieldHeight);
        p = _image.localToGlobal(p);
        var paletteP :Point = _inputPalette.parent.globalToLocal(p);
        _inputPalette.y = paletteP.y;

        p = _inputPalette.globalToLocal(p);
        field.x = p.x;
        field.y = p.y;

        colorInputPalette();

//        if (_game.getCurrentPhase() == CaptionGame.CAPTIONING_PHASE) {
//            // move the input palette
//            p = field.localToGlobal(new Point(0, 0));
//            p = _inputPalette.parent.globalToLocal(p);
//            _inputPalette.y = p.y;
//
//            colorInputPalette();
//        }
    }

    protected function handlePhaseChanged (event :Event) :void
    {
        checkPhase(ANIMATE_TO_FRAME);
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

    /** Constants to pass to checkPhase(). */
    protected static const ANIMATE_TO_FRAME :int = 0;
    protected static const SKIP_TO_FRAME :int = 1;
    protected static const DONT_ALTER_FRAME :int = 2;

    /** For now, these are just used for layout of the _input and _winningCaption fields.
     * It might be nice to restrict flickr photos to those sizes. */
    protected static const MIN_IMAGE_WIDTH :int = 350;
    protected static const MIN_IMAGE_HEIGHT :int = 350;

    /** The width of the voting/results pane, which is the ideal width, minus padding, 
     * minus the sidebar and minus a possible scrollbar. */
    protected static const PANE_WIDTH :int = IDEAL_WIDTH - (16 + 250 + 16);

    protected var _ctrl :WhirledGameControl;

    protected var _game :CaptionGame;

    protected var _ui :MovieClip;

    protected var _mask :Shape;

    protected var _formatter :LOLTextFieldFormatter;

    protected var _loader :EmbeddedSwfLoader;

    protected var _frameReachedCallback :Function;

    protected var _textFormat :TextFormat = new TextFormat(
        "_sans", 24, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);

    protected var _image :UILoader;

    protected var _skipBox :CheckBox;

    protected var _input :TextField;

    protected var _inputPalette :Sprite;

    protected var _clock :TextField;

    protected var _winnerName :TextField;

    protected var _winningCaption :TextField;

    protected var _votingPane :ScrollPane;
    protected var _resultsPane :ScrollPane;

    protected var _doneButton :Button;

    protected var _previewImage :Array = [];

    protected var _previewBox :Array = [];

    protected var _timer :Timer;
}
}
