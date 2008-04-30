package spades.sound {

import flash.system.ApplicationDomain;
import flash.media.Sound;
import spades.Model;
import spades.Debug;
import com.whirled.contrib.card.HandEvent;
import com.whirled.contrib.card.trick.TrickEvent;
import com.whirled.contrib.card.TurnTimerEvent;
import com.threerings.util.MultiLoader;
import spades.graphics.Structure;
import flash.display.MovieClip;
import com.whirled.game.StateChangedEvent;

/** Embeds card sounds and plays them when game events occur. 
 *  TODO: consider breaking into Loader and Player, if more flexibility is needed */
public class SoundPlayer
{
    /** Creates sounds and attaches event listeners to play them. */
    public function SoundPlayer (model :Model)
    {
        _myId = model.table.getLocalId();
        MultiLoader.getLoaders(SOUNDS, gotSounds, false, _soundDomain);

        if (model.hand != null) {
            model.hand.addEventListener(
                HandEvent.DEALT, dealtListener);
        }
        model.trick.addEventListener(
            TrickEvent.CARD_PLAYED, cardPlayedListener);
        model.trick.addEventListener(
            TrickEvent.COMPLETED, completedListener);
        model.timer.addEventListener(
            TurnTimerEvent.EXPIRED, expiredListener);
        model.gameCtrl.game.addEventListener(
            StateChangedEvent.ROUND_STARTED, 
            roundStartedListener);

        function gotSounds (obj :*) :void {
            Debug.debug("Sounds loaded object " + obj);

            _deal = getSound("card_deal");
            _play = getSound("play_card");
            _takeTrick = getSound("take_trick");
            _turnWarning = getSound("turn_end_warning");
            _shuffle = getSound("shuffling");

        }
    }

    protected function dealtListener (event :HandEvent) :void
    {
        play(_deal);
    }

    protected function cardPlayedListener (event :TrickEvent) :void
    {
        play(_play);
    }

    protected function completedListener (event :TrickEvent) :void
    {
        play(_takeTrick);
    }

    protected function expiredListener (event :TurnTimerEvent) :void
    {
        if (event.player == _myId) {
            play(_turnWarning);
        }
    }

    protected function roundStartedListener (event :StateChangedEvent) :void
    {
        play(_shuffle);
    }

    protected function play (sound :Sound) :void
    {
        if (sound != null) {
            sound.play();
        }
    }

    protected function getSound (name :String) :Sound
    {
        if (!_soundDomain.hasDefinition(name)) {
            Debug.debug("Sound " + name + " not found in domain");
            return null;
        }
        var symbolClass :Class = _soundDomain.getDefinition(name) as Class;
        var sound :Sound = new symbolClass() as Sound;

        Debug.debug("Loaded sound " + name);
        return sound;
    }

    [Embed(source="../../../rsrc/sounds.swf", mimeType="application/octet-stream")]
    protected static var SOUNDS :Class;

    protected var _soundDomain :ApplicationDomain = new ApplicationDomain(null);
    protected var _myId :int;

    protected var _deal :Sound;
    protected var _play :Sound;
    protected var _takeTrick :Sound;
    protected var _turnWarning :Sound;
    protected var _shuffle :Sound;
}

}
