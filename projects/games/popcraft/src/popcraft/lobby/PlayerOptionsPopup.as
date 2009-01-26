package popcraft.lobby {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.ui.UIBits;

public class PlayerOptionsPopup extends SceneObject
{
    public static function show (parentSprite :Sprite) :void
    {
        var topMode :AppMode = ClientCtx.mainLoop.topMode;
        var popup :PlayerOptionsPopup = topMode.getObjectNamed(NAME) as PlayerOptionsPopup;
        if (popup == null) {
            popup = new PlayerOptionsPopup();
            topMode.addObject(popup, parentSprite);
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

        var ii :int;
        var frame :MovieClip;

        // fill in the player portraits
        for (ii = 0; ii < Constants.PLAYER_PORTRAIT_NAMES.length; ++ii) {
            frame = _movie["portrait" + ii];
            var portraitName :String = Constants.PLAYER_PORTRAIT_NAMES[ii];
            var portrait :Bitmap = ClientCtx.instantiateBitmap(portraitName);
            portrait.width = frame.width;
            portrait.height = frame.height;
            frame.addChild(portrait);
        }

        // fill in player colors
        for (ii = 0; ii < Constants.PLAYER_COLORS.length; ++ii) {
            frame = _movie["color" + ii];
            var color :uint = Constants.PLAYER_COLORS[ii];
            var swatch :Shape = new Shape();
            g = swatch.graphics;
            g.beginFill(color);
            g.drawRect(-frame.width * 0.5, -frame.height * 0.5, frame.width, frame.height);
            g.endFill();
            frame.addChild(swatch);
        }

        // The OK button just hides the popup.
        //var okButton :SimpleButton = _movie["OK_button"];
        var okButton :SimpleButton = UIBits.createButton("OK", 1.2);
        okButton.x = 169;
        okButton.y = 122;
        _movie.addChild(okButton);
        var thisPopup :PlayerOptionsPopup = this;
        registerListener(okButton, MouseEvent.CLICK,
            function (...ignored) :void {
                thisPopup.visible = false;
            });
    }

    protected function initPlayerOptions () :void
    {

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

    protected static const NAME :String = "PlayerOptionsPopup";
}

}
