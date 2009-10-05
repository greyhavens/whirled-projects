package popcraft.lobby {

import com.threerings.display.DisplayUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.objects.SceneObject;
import com.whirled.game.GameContentEvent;
import com.whirled.game.NetSubControl;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.ui.HeadshotSprite;
import popcraft.ui.UIBits;

public class PlayerOptionsPopup extends SceneObject
{
    public static function show (parent :DisplayObjectContainer) :void
    {
        var topMode :AppMode = ClientCtx.mainLoop.topMode;
        var popup :PlayerOptionsPopup = topMode.getObjectNamed(NAME) as PlayerOptionsPopup;
        if (popup == null) {
            popup = new PlayerOptionsPopup();
            topMode.addSceneObject(popup, parent);
        }

        popup.initPlayerOptions();
        popup.visible = true;
    }

    public function PlayerOptionsPopup ()
    {
        _sprite = new Sprite();
        var g :Graphics = _sprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        _movie = ClientCtx.instantiateMovieClip("multiplayer_lobby", "player_options_panel");
        _movie.x = _sprite.width * 0.5;
        _movie.y = _sprite.height * 0.5;
        _sprite.addChild(_movie);

        // This will be used in some callbacks later in the function
        var thisPopup :PlayerOptionsPopup = this;

        var lockedOverlay :SimpleButton = _movie["lock"];
        if (ClientCtx.isMpCustomizationUnlocked) {
            lockedOverlay.visible = false;
        } else {
            lockedOverlay.visible = true;

            // Show the game shop if the player clicks the unlock button
            registerListener(lockedOverlay, MouseEvent.CLICK,
                function (...ignored) :void {
                    ClientCtx.showAcademyGameShop();
                });

            // If the player purchases the proper level pack while this screen is open,
            // close it and reload
            registerListener(ClientCtx.gameCtrl.player, GameContentEvent.PLAYER_CONTENT_ADDED,
                function (...ignored) :void {
                    if (ClientCtx.isMpCustomizationUnlocked) {
                        var wasVisible :Boolean = thisPopup.visible;
                        var parent :DisplayObjectContainer = thisPopup.displayObject.parent;
                        thisPopup.destroySelf();
                        if (wasVisible) {
                            PlayerOptionsPopup.show(parent);
                        }
                    }
                });
        }

        var ii :int;
        var positioner :MovieClip;

        // fill in the player portraits
        for (ii = 0; ii < Constants.PLAYER_PORTRAIT_NAMES.length; ++ii) {
            positioner = _movie["portrait" + ii];
            positioner.visible = false;

            var portraitName :String = Constants.PLAYER_PORTRAIT_NAMES[ii];
            var portrait :DisplayObject;
            if (portraitName != Constants.DEFAULT_PORTRAIT) {
                portrait = ClientCtx.instantiateBitmap(portraitName);
                portrait.width = positioner.width;
                portrait.height = positioner.height;
            } else {
                portrait = new HeadshotSprite(ClientCtx.seatingMgr.localPlayerSeat,
                    positioner.width, positioner.height);
            }

            var portraitButton :Sprite = new Sprite();
            portraitButton.addChild(portrait);
            portraitButton.x = positioner.x;
            portraitButton.y = positioner.y;
            DisplayUtil.addChildBelow(_movie, portraitButton, lockedOverlay);

            _portraitButtons.push(portraitButton);
            if (ClientCtx.isMpCustomizationUnlocked) {
                createPortraitClickListener(portraitButton, portraitName);
            }
        }

        _portraitSelectionIndicator = new Shape();
        g = _portraitSelectionIndicator.graphics;
        g.lineStyle(PORTRAIT_SELECTION_INDICATOR_SIZE, 0x000000);
        g.drawRect(0, 0, positioner.width, positioner.height);
        _portraitSelectionIndicator.cacheAsBitmap = true;

        // fill in player colors
        for (ii = 0; ii < Constants.PLAYER_COLORS.length; ++ii) {
            positioner = _movie["color" + ii];
            var color :uint = Constants.PLAYER_COLORS[ii];
            var colorButton :Sprite;

            if (color == Constants.RANDOM_COLOR) {
                colorButton = positioner;
                colorButton.mouseEnabled = true;
            } else {
                var swatch :Shape = new Shape();
                g = swatch.graphics;
                g.beginFill(color);
                g.drawRect(0, 0, positioner.width, positioner.height);
                g.endFill();

                colorButton = new Sprite();
                colorButton.addChild(swatch);
                colorButton.x = positioner.x;
                colorButton.y = positioner.y;
                DisplayUtil.addChildBelow(_movie, colorButton, lockedOverlay);
            }

            _colorButtons.push(colorButton);

            if (ClientCtx.isMpCustomizationUnlocked) {
                createColorClickListener(colorButton, color);
            }
        }

        _colorSelectionIndicator = new Shape();
        g = _colorSelectionIndicator.graphics;
        g.lineStyle(COLOR_SELECTION_INDICATOR_SIZE, 0x000000);
        g.drawRect(0, 0, positioner.width, positioner.height);
        _colorSelectionIndicator.cacheAsBitmap = true;

        // Handicap checkbox
        var handicapCheckbox :MovieClip = _movie["handicap"];
        registerListener(handicapCheckbox, MouseEvent.CLICK,
            function (...ignored) :void {
                updateHandicap(!_handicapOn);
            });
        _handicapIcon = ClientCtx.instantiateMovieClip("multiplayer_lobby", "handicapped");
        _handicapIcon.x = handicapCheckbox.x;
        _handicapIcon.y = handicapCheckbox.y;
        _handicapIcon.mouseEnabled = false;
        _movie.addChild(_handicapIcon);

        // The OK button just hides the popup.
        var okButton :SimpleButton = UIBits.createButton("OK", 1.3, 53);
        okButton.x = 140;
        okButton.y = 107;
        _movie.addChild(okButton);
        registerListener(okButton, MouseEvent.CLICK,
            function (...ignored) :void {
                savePlayerOptions();
                thisPopup.visible = false;
            });
    }

    protected function createPortraitClickListener (portraitButton :Sprite, portraitName :String)
        :void
    {
        registerListener(portraitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                updatePortraitSelection(portraitName);
            });
    }

    protected function createColorClickListener (colorButton :Sprite, color :uint) :void
    {
        registerListener(colorButton, MouseEvent.CLICK,
            function (...ignored) :void {
                updateColorSelection(color);
            });
    }

    protected function initPlayerOptions () :void
    {
        updateHandicap(this.isHandicapOn);
        updatePortraitSelection(this.curFavoritePortrait);
        updateColorSelection(this.curFavoriteColor);
    }

    protected function savePlayerOptions () :void
    {
        var popup :PlayerOptionsPopup = this;

        ClientCtx.gameCtrl.net.doBatch(function () :void {
            var cookieChanged :Boolean;
            if (_handicapOn != popup.isHandicapOn) {
                ClientCtx.gameCtrl.net.sendMessage(
                    LobbyConfig.MSG_SET_HANDICAP,
                    _handicapOn,
                    NetSubControl.TO_SERVER_AGENT);
            }

            if (_selectedPortrait != popup.curFavoritePortrait) {
                ClientCtx.gameCtrl.net.sendMessage(
                    LobbyConfig.MSG_SET_PORTRAIT,
                    _selectedPortrait,
                    NetSubControl.TO_SERVER_AGENT);

                ClientCtx.savedPlayerBits.favoritePortrait = _selectedPortrait;
                cookieChanged = true;
            }

            if (_selectedColor != popup.curFavoriteColor) {
                ClientCtx.gameCtrl.net.sendMessage(
                    LobbyConfig.MSG_SET_COLOR,
                    _selectedColor,
                    NetSubControl.TO_SERVER_AGENT);

                ClientCtx.savedPlayerBits.favoriteColor = _selectedColor;
                cookieChanged = true;
            }

            if (cookieChanged) {
                ClientCtx.userCookieMgr.needsUpdate();
            }
        });
    }

    protected function updatePortraitSelection (portraitName :String) :void
    {
        var idx :int = ArrayUtil.indexOf(Constants.PLAYER_PORTRAIT_NAMES, portraitName);
        if (idx < 0) {
            idx = ArrayUtil.indexOf(Constants.PLAYER_PORTRAIT_NAMES, Constants.DEFAULT_PORTRAIT);
            if (idx < 0) {
                return;
            }
        }

        var button :Sprite = _portraitButtons[idx];
        button.addChild(_portraitSelectionIndicator);
        _selectedPortrait = portraitName;
    }

    protected function updateColorSelection (color :uint) :void
    {
        var idx :int = ArrayUtil.indexOf(Constants.PLAYER_COLORS, color);
        if (idx < 0) {
            idx = ArrayUtil.indexOf(Constants.PLAYER_COLORS, Constants.RANDOM_COLOR);
            if (idx < 0) {
                return;
            }
        }

        var button :Sprite = _colorButtons[idx];
        button.addChild(_colorSelectionIndicator);
        _selectedColor = color;
    }

    protected function updateHandicap (on :Boolean) :void
    {
        _handicapOn = on;
        _handicapIcon.visible = on;
    }

    protected function get isHandicapOn () :Boolean
    {
        return ClientCtx.lobbyConfig.isPlayerHandicapped(ClientCtx.seatingMgr.localPlayerSeat);
    }

    protected function get curFavoritePortrait () :String
    {
        return ClientCtx.savedPlayerBits.favoritePortrait;
    }

    protected function get curFavoriteColor () :uint
    {
        return ClientCtx.savedPlayerBits.favoriteColor;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;
    protected var _handicapOn :Boolean;
    protected var _handicapIcon :MovieClip;

    protected var _portraitButtons :Array = [];
    protected var _portraitSelectionIndicator :Shape;
    protected var _selectedPortrait :String;
    protected var _colorButtons :Array = [];
    protected var _colorSelectionIndicator :Shape;
    protected var _selectedColor :uint;

    protected static const PORTRAIT_SELECTION_INDICATOR_SIZE :Number = 5;
    protected static const COLOR_SELECTION_INDICATOR_SIZE :Number = 4;
    protected static const NAME :String = "PlayerOptionsPopup";
}

}
