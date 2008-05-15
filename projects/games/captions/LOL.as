package {

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.filters.ColorMatrixFilter;
import flash.filters.GlowFilter;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
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
import com.threerings.util.Log;
import com.threerings.util.MultiLoader;
import com.threerings.util.NetUtil;
import com.threerings.util.RandomUtil;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;

import com.threerings.flash.DisplayUtil;

import com.whirled.game.*;

/**
 * TODO:
 * - save captioned images?
 */
[SWF(width="700", height="500")]
public class LOL extends Sprite
{
    public static const DEBUG :Boolean = false;

    public function LOL () 
    {
//        trace("Started up LOLcaptions, build ID: reload10");
        _ctrl = new GameControl(this);
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

        _formatter = new TextFieldFormatter();
        _formatter.addEventListener(
            TextFieldFormatter.ENTER_PRESSED_EVENT, handleEnterPressedOnInput);

        _ctrl.local.addEventListener(SizeChangedEvent.SIZE_CHANGED, handleSizeChanged);

        _content = new Sprite();
        addChild(_content);

        _mask = new Shape();
        _mask.graphics.beginFill(0x000000, 1);
        _mask.graphics.drawRect(0, 0, IDEAL_WIDTH, IDEAL_HEIGHT);
        _content.addChild(_mask);

        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _searchPhotos = new SearchFlickrPhotoService();

        _game = new CaptionGame(_ctrl, _searchPhotos);
        _game.addEventListener(CaptionGame.TICK_EVENT, updateClock);
        _game.addEventListener(CaptionGame.PHASE_CHANGED_EVENT, handlePhaseChanged);
        _game.addEventListener(CaptionGame.ROUND_WILL_START_EVENT, handleRoundWillStart);

        _game.configureTrophyConsecutiveWin("3wins", 3);
        _game.configureTrophyConsecutiveWin("5wins", 5);
        _game.configureTrophyConsecutiveWin("10wins", 10);
        _game.configureTrophyCaptionsSubmittedEver("10caps", 10);
        _game.configureTrophyCaptionsSubmittedEver("100caps", 100);
        _game.configureTrophyCaptionsSubmittedEver("500caps", 500);
        _game.configureTrophyCaptionsSubmittedEver("1000caps", 1000);
        _game.configureTrophyUnanimous("unanimous", 5 /* mincaptions*/);

        _tagWidget = new TagWidget(_ctrl, _searchPhotos);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleSubmitCaption);

        // get us rolling
        updateSize(_ctrl.local.getSize());
        initTheme();
    }

    protected function initTheme () :void
    {
        var newTheme :String = _ctrl.net.get("theme") as String;
        if (_theme == newTheme) {
            showPhoto();
            return;
        }

        if (_ui != null) {
            _content.removeChild(_ui);
            _ui = null;
        }
        _curImage = null;
        _theme = newTheme;

        var ui :Class;
        switch (_theme) {
        default:
        case LOL_THEME:
            ui = LOL_THEME_UI;
            break;

        case SILENT_THEME:
            ui = SILENT_THEME_UI;
            break;
        }

        MultiLoader.getLoaders(ui, handleUILoaded, false, ApplicationDomain.currentDomain);
    }

    protected function handleUILoaded (loader :Loader) :void
    {
        _ui = loader.content as MovieClip;
        _ui.mask = _mask;
        _content.addChild(_ui);

        var fontName :String = "captionFont";
        if (_theme == LOL_THEME) {
            fontName += "2";
        }
        var fontClass :Class =
            loader.contentLoaderInfo.applicationDomain.getDefinition(fontName) as Class;
        _captionFont = new fontClass();

//        trace(DisplayUtil.dumpHierarchy(_ui));

        // For some reason, when the movie wraps around, we need to re-grab all the bits
        _ui.addEventListener("frameFirst", initUIBits);

        // listen for these two events for shrinky/expandy
        _ui.addEventListener("frameWinner", shrinkImageForWinnerScreen);
        _ui.addEventListener("frameResults", unshrinkImageForResultsScreen);

        initUIBits();
    }

    protected function initUIBits (... ignored) :void
    {
//        trace("isFrameFirst: " + ignored[0]);

        _image = find("image") as UILoader;
        if (_image == null) {
            Log.dumpStack();
            // the UI doesn't seem to be ready to read. Wait.
            return;
        }

        _pageButton = find("flickr_button") as SimpleButton;

        _skipBox = find("skip") as CheckBox;
        if (_skipBox == null) {
            trace("The fuckup is happening. Catching the fuckup. Unfucking the fuckup.");
            Log.dumpStack();
            _theme = null;
            initTheme();
            return;
        }
        _skipBox.label = "              "; // so that it's more easily clickable

        _input = find("text_input") as TextField;
        _input.height = 200;

        _clock = find("clock") as TextField;
        _clock.selectable = false;

        _doneButton = find("Done_button") as SimpleButton;
        _editButton = find("Edit_button") as SimpleButton;

        _participateButton = find("EnterCaption_button") as SimpleButton;

        _notParticipating = find("np_checkbox") as CheckBox;
        _notParticipating.label = "              "; // so that it's more easily clickable

        _tagPane = find("tag_scrollpane") as ScrollPane;
        _tagPane.horizontalScrollPolicy = ScrollPolicy.OFF;
        _tagPane.verticalScrollPolicy = ScrollPolicy.OFF;
        _tagWidget.setSize(_tagPane.width, _tagPane.height);
        _tagPane.source = _tagWidget;

        _inputPalette = find("input_palette") as Sprite;

        _votingPane = find("voting_scrollpane") as ScrollPane;
        _resultsPane = find("results_scrollpane") as ScrollPane;

        _winningCaption = find("winning_caption") as TextField;
        // unfortunately, Brittney couldn't do all this herself..
        _winningCaption.parent.parent.mouseChildren = false;
        _winningCaption.parent.parent.mouseEnabled = false;

        _winnerName = find("winner_name") as TextField;
        _winnerName.selectable = false;

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

        _skipBox.addEventListener(Event.CHANGE, handleVoteToSkip);
        _doneButton.addEventListener(MouseEvent.CLICK, handleSubmitButton);
        _editButton.addEventListener(MouseEvent.CLICK, handleSubmitButton);
        _pageButton.addEventListener(MouseEvent.CLICK, handlePhotoPageButton);

        _image.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
        _image.addEventListener(Event.COMPLETE, handleImageComplete);

        _participateButton.addEventListener(MouseEvent.CLICK, handleStartParticipating);
        _notParticipating.addEventListener(Event.CHANGE, handleStopParticipating);

        _input.embedFonts = true;
        _winningCaption.embedFonts = true;

        switch (_theme) {
        default:
            _formatter.configure();
            break;

        case LOL_THEME:
            _formatter.configure(_captionFont.fontName);
            break;

        case SILENT_THEME:
            var grain :MovieClip = find("film_grain") as MovieClip;
            grain.mouseEnabled = false;
            grain.mouseChildren = false;
            _formatter.configure(_captionFont.fontName, 0xFFFFFF, false);
            break;
        }
        _formatter.watch(_input, handleTextFieldChanged);
        _formatter.watch(_winningCaption, handleWinningCaptionFieldChanged);

        showPhoto();
        initThemeSpecificUI();

        checkPhase();
    }

    protected function initThemeSpecificUI () :void
    {
        switch (_ctrl.net.get("theme")) {
        default:
        case LOL_THEME:
            // nada, currently
            break;

        case SILENT_THEME:
            // make a grayscale filter for the image
            const T :Number = 1 / 3;
            _image.filters = [ new ColorMatrixFilter([
                T, T, T, 0, 0,
                T, T, T, 0, 0,
                T, T, T, 0, 0,
                0, 0, 0, 1, 0]) ];
            break;
        }
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
     */
    protected function checkPhase () :void
    {
        initTheme();
        if (_ui == null) {
            return;
        }

        switch (_game.getCurrentPhase()) {
        case CaptionGame.CAPTIONING_PHASE:
            initCaptioning();
            break;

        case CaptionGame.VOTING_PHASE:
            initVoting();
            if (_participating && (_frameBehavior == ANIMATE_TO_FRAME) && (_input.text == "")) {
                setParticipating(false);
            }
            break;

        case CaptionGame.RESULTS_PHASE:
            initResults();
            break;
        }

        if (_frameBehavior != DONT_ALTER_FRAME) {
            showFrame(_frameBehavior == ANIMATE_TO_FRAME);
        }
    }

    protected function showPhoto () :Boolean
    {
        var url :String = _game.getPhoto();
        if (url != null && _curImage != url) {
            if (_image != null) {
                _curImage = url;
                loadInto(_image, url);

                _pageButton.visible = (_game.getPhotoPage() != null);
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

        if (!nowEditing && StringUtil.isBlank(_input.text)) {
            // don't let them be "done" with nothing
            return;
        }

        configureIsEditing(nowEditing);

        if (!nowEditing) {
            handleSubmitCaption(event);

        } else {
            _input.stage.focus = _input;
            _input.setSelection(_input.length, _input.length);
        }

        _game.setDoneCaptioning(!nowEditing);
    }

    protected function handleEnterPressedOnInput (event :ValueEvent) :void
    {
        // We know this came from the input area, so make it like pressing done.
        handleSubmitButton(event);
        // Tell the formatter that we don't want the enter to go through.
        event.preventDefault();
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

    protected function handleStopParticipating (event :Event) :void
    {
        setParticipating(false);
    }

    protected function handleStartParticipating (event :Event) :void
    {
        setParticipating(true);
    }

    protected function setParticipating (part :Boolean) :void
    {
        _participating = part;
        _game.setParticipating(part);
        configureIsEditing(part);
        displayParticipating();
    }

    protected function handleCaptionVote (event :Event) :void
    {
        var box :DataCheckBox = (event.currentTarget as DataCheckBox);
        var value :int = int(box.data);
        var accepted :Boolean = _game.setCaptionVote(value, box.selected);

        if (!accepted) {
            // the vote was rejected, probably because the user is a luser and is voting for all
            box.selected = false;
        }
    }

    protected function handlePhotoPageButton (event :MouseEvent) :void
    {
        var pageUrl :String = _game.getPhotoPage();
        if (pageUrl != null) {
            NetUtil.navigateToURL(pageUrl, null);
        }
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

    protected function initCaptioning () :void
    {
        if (_input == null || _input.stage == null) {
            return;
        }

        _votingPane.source = null;
        _resultsPane.source = null;
        _input.text = "";
        _doneButton.enabled = true;
        _skipBox.selected = false;

        configureIsEditing(_participating);
        displayParticipating();
        _timer.start();
    }

    protected function configureIsEditing (editing :Boolean) :void
    {
        _input.type = editing ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
        _input.selectable = editing;

        _doneButton.visible = editing;
        _editButton.visible = !editing;

        _skipBox.parent.visible = editing;
        _notParticipating.parent.visible = editing;

        colorInputPalette();
    }

    protected function colorInputPalette () :void
    {
        if (_theme != LOL_THEME) {
            return;
        }

        var g :Graphics = _inputPalette.graphics;
        g.clear();
        if (_input.type == TextFieldType.INPUT) {
            var w :int = MIN_IMAGE_WIDTH;
            try {
                if (_image.content != null) {
                    w = Math.max(_image.content.width, w);
                }
            } catch (err :SecurityError) {
                // no problem, we don't care
            }
            //trace("coloring, (" + (_image.content != null) + ") " + w + ", " + _image.scaleX);

            var p :Point = _input.localToGlobal(new Point());
            p = _inputPalette.globalToLocal(p);

            g.beginFill(0xFFFFFF, .4);
            g.drawRoundRect(p.x, 0, w, _input.textHeight + 4, 10, 10);
        }
    }

    protected function displayParticipating () :void
    {
        _participateButton.visible = !_participating;
        _notParticipating.visible = _participating;
        _inputPalette.visible = _participating;

        if (_participating) {
            _notParticipating.selected = false;
        }
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
for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
        for (var ii :int = 0; ii < caps.length; ii++) {
            var cb :DataCheckBox = new DataCheckBox();
            var width :int = PANE_WIDTH - 30; // save some room for the checkbox icon
            cb.data = ii;
            cb.setStyle("disabledTextFormat", _textFormat);
            cb.setStyle("textFormat", _textFormat);
            cb.textField.autoSize = TextFieldAutoSize.LEFT;
            cb.label = String(caps[ii]);

            cb.addEventListener(Event.CHANGE, handleCaptionVote);
            if (ii == ourIdx) {
                cb.enabled = false;
            }
            cb.setSize(PANE_WIDTH, 22);
            cb.validateNow();
            cb.textField.width = PANE_WIDTH * 2;;
            if (cb.textField.textWidth + 5 > width) {
                cb.textField.wordWrap = true;
            }
            cb.textField.width = width;
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
for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
        for (var ii :int = 0; ii < results.length; ii++) {
            var result :Object = results[ii];
            var width :int = PANE_WIDTH;

            var votes :Label = new Label();
            votes.setStyle("textFormat", _nameFormat);
            votes.text = " " + result.votes;
            votes.setSize(46, 30);
            votes.validateNow();
            width -= votes.textField.textWidth + 5;
            votes.textField.width = votes.textField.textWidth + 5;
            votes.x = width;
            votes.y = yPos;
            s.addChild(votes);

            var name :Label = new Label();
            name.setStyle("textFormat", _nameFormat);
            name.text = "- " + result.playerName;
            name.setSize(100, 30);
            width -= 100 + 5;
            name.x = width;
            name.y = yPos;
            s.addChild(name);

            var lbl :Label = new Label();
            lbl.setStyle("textFormat", _textFormat);
            lbl.text = String(result.caption);
            lbl.textField.wordWrap = true;
            lbl.setSize(width - 36, 30);
            lbl.validateNow();
            var height :int = lbl.textField.textHeight + 4;
            lbl.setSize(width - 36, height);
            lbl.x = 36;
            lbl.y = yPos;
            s.addChild(lbl);

            if (ii == 0 && jj == 0) {
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
        _formatter.format(_winningCaption);

        // remove any old star
        var oldStar :DisplayObject = find("star");
        if (oldStar != null) {
            oldStar.parent.removeChild(oldStar);
        }

        var star :DisplayObject = new STAR_ICON() as DisplayObject;
        star.name = "star";

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

    /**
     * A frame callback for setting us up for the winner screen.
     */
    protected function shrinkImageForWinnerScreen (... ignored) :void
    {
        try {
            if (_image.content != null) {
                var loaderInfo :LoaderInfo = _image.content.loaderInfo;
                // we need to make room for the "<bla> has won" label that shouldn't overlap
                // the image
                const MAX :int = 380;
                if (loaderInfo.height > MAX) {
                    var scale :Number = MAX / loaderInfo.height;
                    _image.content.scaleX = scale
                    _image.content.scaleY = scale
                    alignImage();
                }
            }
        } catch (err :SecurityError) {
            // oh well!
        }
        if (_winningCaption != null) {
            handleWinningCaptionFieldChanged(_winningCaption);
        }
    }

    /**
     * A frame callback for setting us up for the winner screen.
     */
    protected function unshrinkImageForResultsScreen (... ignored) :void
    {
        try {
            if (_image.content != null) {
                _image.content.scaleX = 1;
                _image.content.scaleY = 1;
                alignImage();
            }
        } catch (err :SecurityError) {
            // oh well!
        }
        if (_winningCaption != null) {
            handleWinningCaptionFieldChanged(_winningCaption);
        }
    }

    protected function alignImage () :void
    {
        if (_theme != LOL_THEME) {
            return;
        }
        // TODO: width/height should be available earlier!
        try {
            if (_image.content != null) {
                _image.x = (MAX_IMAGE_WIDTH - _image.content.width) / 2;
                _image.y = (MAX_IMAGE_HEIGHT - _image.content.height) / 2;
            }
        } catch (err :SecurityError) {
            // oh well!
        }
    }

    /**
     * Handle image loading.
     */
    protected function handleImageProgress (event :ProgressEvent) :void
    {
        if (event.target == _image) {
            alignImage();
        }
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
        // and also update the text field position
        if (_input != null) {
            handleTextFieldChanged(_input);
        }
        if (_winningCaption != null) {
            handleWinningCaptionFieldChanged(_winningCaption);
        }

        if (event.target == _image) {
            // set it up to draw the bitmap smoothly at scale
            if (_image.content is Bitmap) {
                Bitmap(_image.content).smoothing = true;
            }
            alignImage();
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
        if (_theme != LOL_THEME) {
            return;
        }

        var w :int = MIN_IMAGE_WIDTH;
        var h :int = MAX_IMAGE_HEIGHT;
        // position the field properly over the image control
        try {
            if (_image.content != null) {
                w = Math.max(w, _image.content.width);
                h = _image.content.height;
            }
        } catch (err :SecurityError) {
            // cope
        }

        field.width = w;

        var fieldHeight :int;
        if (field.text == "") {
            field.text = "W";
            fieldHeight = field.textHeight + 4;
            field.text = "";

        } else {
            fieldHeight = field.textHeight + 4;
        }

        var p :Point = new Point((MAX_IMAGE_WIDTH - w) / 2,
            (MAX_IMAGE_HEIGHT - h) / 2 + h - fieldHeight);
        p = _image.parent.localToGlobal(p);
        var paletteP :Point = _inputPalette.parent.globalToLocal(p);
        _inputPalette.y = paletteP.y;

        p = _inputPalette.globalToLocal(p);
        field.x = p.x;
        field.y = p.y;

        colorInputPalette();
    }

    protected function handleWinningCaptionFieldChanged (field :TextField) :void
    {
        if (_theme != LOL_THEME) {
            return;
        }

        var w :int = MIN_IMAGE_WIDTH;
        var h :int = MAX_IMAGE_HEIGHT;
        var scale :Number = 1;
        // position the field properly over the image control
        try {
            if (_image.content != null) {
                scale = _image.content.scaleX;
                w = Math.max(w * scale, _image.content.width);
                h = _image.content.height;
            }
        } catch (err :SecurityError) {
            // cope
        }

        field.scaleX = scale;
        field.scaleY = scale;
        field.width = w / scale;

        var fieldHeight :int = field.textHeight + 4;
        var p :Point = new Point((MAX_IMAGE_WIDTH - w) / 2,
            (MAX_IMAGE_HEIGHT - h) / 2 + h - (fieldHeight * scale));
        p = _image.parent.localToGlobal(p);
        p = field.parent.globalToLocal(p);
        field.x = p.x;
        field.y = p.y;
    }

    protected function handlePhaseChanged (event :Event) :void
    {
        _frameBehavior = ANIMATE_TO_FRAME;
        checkPhase();
    }

    /**
     * Handle the game's ROUND_WILL_START event, which is only dispatched to the instance
     * in control.
     */
    protected function handleRoundWillStart (event :Event) :void
    {
        // pick a new theme
        _ctrl.net.set("theme", THEMES[RandomUtil.getWeightedIndex(THEME_WEIGHTS)]);
    }

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        updateSize(event.size);
    }

    protected function updateSize (size :Point) :void
    {
        var width :int = Math.max(size.x, IDEAL_WIDTH);
        var height :int = Math.max(size.y, IDEAL_HEIGHT);

        // draw black behind everything
        this.graphics.clear();
        this.graphics.beginFill(0x000000, 1);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();

        var xscale :Number = width / IDEAL_WIDTH;
        var yscale :Number = height / IDEAL_HEIGHT;
        var scale :Number = Math.min(xscale, yscale);
        // scale will be 1 or higher, since we don't let width/height get smaller than IDEAL
        _content.scaleX = scale;
        _content.scaleY = scale;

        _content.x = (width - (IDEAL_WIDTH * scale)) / 2;
        _content.y = (height - (IDEAL_HEIGHT * scale)) / 2;
    }

    protected function handleUnload (... ignored) :void
    {
        _timer.reset();
    }

    [Embed(source="rsrc/winner_icon.swf")]
    protected static const WINNER_ICON :Class;

    [Embed(source="rsrc/dq_icon.png")]
    protected static const DISQUAL_ICON :Class;

    [Embed(source="rsrc/Star.swf")]
    protected static const STAR_ICON :Class;

    [Embed(source="rsrc/lol_theme.swf", mimeType="application/octet-stream")]
    protected static const LOL_THEME_UI :Class;

    [Embed(source="rsrc/silent_theme.swf", mimeType="application/octet-stream")]
    protected static const SILENT_THEME_UI :Class;

    protected static const IDEAL_WIDTH :int = 700;
    protected static const IDEAL_HEIGHT :int = 500;

    /** _frameBehavior constants. */
    protected static const ANIMATE_TO_FRAME :int = 0;
    protected static const SKIP_TO_FRAME :int = 1;
    protected static const DONT_ALTER_FRAME :int = 2;

    /** For now, these are just used for layout of the _input and _winningCaption fields.
     * It might be nice to restrict flickr photos to those sizes. */
    protected static const MIN_IMAGE_WIDTH :int = 350;
    protected static const MIN_IMAGE_HEIGHT :int = 350;

    /** The maximum size of an image. */
    protected static const MAX_IMAGE_WIDTH :int = 500;
    protected static const MAX_IMAGE_HEIGHT :int = 500;

    /** The width of the voting/results pane, which is the ideal width, minus padding, 
     * minus the sidebar and minus a possible scrollbar. */
    protected static const PANE_WIDTH :int = IDEAL_WIDTH - (16 + 250 + 16);

    /** Theme constants. */
    protected static const LOL_THEME :String = "lol";
    protected static const SILENT_THEME :String = "silent";

    /** The themes we're using. */
    protected static const THEMES :Array = [ LOL_THEME, SILENT_THEME ];
    protected static const THEME_WEIGHTS :Array = [ 3, 1 ];
//    protected static const THEMES :Array = [ LOL_THEME ];
//    protected static const THEMES :Array = [ SILENT_THEME ];

    protected var _ctrl :GameControl;

    protected var _game :CaptionGame;

    protected var _searchPhotos :SearchFlickrPhotoService;

    protected var _frameBehavior :int = SKIP_TO_FRAME;

    /** A sprite containing our UI. */
    protected var _content :Sprite;

    /** The currently selected theme. */
    protected var _theme :String;

    /** The currently shown image. */
    protected var _curImage :String;

    protected var _tagWidget :TagWidget;

    protected var _ui :MovieClip;

    protected var _mask :Shape;

    protected var _formatter :TextFieldFormatter;

    protected var _textFormat :TextFormat = new TextFormat(
        "_sans", 18, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);

    protected var _nameFormat :TextFormat = new TextFormat(
        "_sans", 12, 0xFFFFFF, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);

    protected var _captionFont :Font;

    protected var _image :UILoader;

    protected var _skipBox :CheckBox;

    protected var _input :TextField;

    protected var _inputPalette :Sprite;

    protected var _clock :TextField;

    protected var _winnerName :TextField;

    protected var _winningCaption :TextField;

    protected var _votingPane :ScrollPane;
    protected var _resultsPane :ScrollPane;

    protected var _tagPane :ScrollPane;

    /** Are we "participating" in the captioning? */
    protected var _participating :Boolean = true;

    protected var _doneButton :SimpleButton;
    protected var _editButton :SimpleButton;
    protected var _participateButton :SimpleButton;
    protected var _notParticipating :CheckBox;

    protected var _pageButton :SimpleButton;

    protected var _previewImage :Array = [];

    protected var _previewBox :Array = [];

    protected var _timer :Timer;
}
}
