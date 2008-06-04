package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

public class LoadingMode extends AppMode
{
    override protected function setup () :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        // data
        rm.pendResourceLoad("gameData", "defaultGameData", { embeddedClass: Resources.DEFAULT_GAME_DATA });

        // gfx
        rm.pendResourceLoad("swf", "bg",  { embeddedClass: Resources.SWF_BG });

        rm.pendResourceLoad("image", "base",      { embeddedClass: Resources.IMAGE_BASE });
        rm.pendResourceLoad("image", "targetBaseBadge", { embeddedClass: Resources.IMAGE_TARGETBASEBADGE });
        rm.pendResourceLoad("image", "friendlyBaseBadge", { embeddedClass: Resources.IMAGE_FRIENDLYBASEBADGE });
        rm.pendResourceLoad("image", "bloodlust_icon", { embeddedClass: Resources.IMAGE_BLOODLUSTICON });
        rm.pendResourceLoad("image", "rigormortis_icon", { embeddedClass: Resources.IMAGE_RIGORMORTISICON });
        rm.pendResourceLoad("image", "puzzlereset_icon", { embeddedClass: Resources.IMAGE_PUZZLERESETICON });

        rm.pendResourceLoad("swf", "grunt", { embeddedClass: Resources.SWF_GRUNT });
        rm.pendResourceLoad("swf", "sapper", { embeddedClass: Resources.SWF_SAPPER });
        rm.pendResourceLoad("swf", "heavy", { embeddedClass: Resources.SWF_HEAVY });
        rm.pendResourceLoad("swf", "colossus", { embeddedClass: Resources.SWF_COLOSSUS });
        rm.pendResourceLoad("swf", "courier", { embeddedClass: Resources.SWF_COURIER });
        rm.pendResourceLoad("swf", "missile", { embeddedClass: Resources.SWF_MISSILE });
        rm.pendResourceLoad("swf", "blood", { embeddedClass: Resources.SWF_BLOOD });

        rm.pendResourceLoad("swf", "puzzlePieces", { embeddedClass: Resources.SWF_PIECES });
        rm.pendResourceLoad("swf", "dashboard", { embeddedClass: Resources.SWF_DASHBOARD });

        // sfx
        rm.pendResourceLoad("sound", "mus_night", { embeddedClass: Resources.MUSIC_NIGHT, type: "music", volume: 0.7, priority: 10 });
        rm.pendResourceLoad("sound", "mus_day", { embeddedClass: Resources.MUSIC_DAY, type: "music", volume: 0.7, priority: 10 });

        rm.pendResourceLoad("sound", "sfx_create_grunt", { embeddedClass: Resources.SOUND_GRUNT, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_heavy", { embeddedClass: Resources.SOUND_HEAVY, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_sapper", { embeddedClass: Resources.SOUND_SAPPER, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_colossus", { embeddedClass: Resources.SOUND_COLOSSUS, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_create_courier", { embeddedClass: Resources.SOUND_COURIER, priority: 2 });
        rm.pendResourceLoad("sound", "sfx_death_grunt", { embeddedClass: Resources.SOUND_GRUNTDEATH });
        rm.pendResourceLoad("sound", "sfx_death_heavy", { embeddedClass: Resources.SOUND_HEAVYDEATH });
        rm.pendResourceLoad("sound", "sfx_death_sapper", { embeddedClass: Resources.SOUND_EXPLOSION });
        rm.pendResourceLoad("sound", "sfx_death_courier", { embeddedClass: Resources.SOUND_COURIERDEATH, volume: 0.7 });
        rm.pendResourceLoad("sound", "sfx_death_colossus", { embeddedClass: Resources.SOUND_COLOSSUSDEATH });
        rm.pendResourceLoad("sound", "sfx_death_base", { embeddedClass: Resources.SOUND_BASEDESTROY, priority: 7 });

        rm.pendResourceLoad("sound", "sfx_rigormortis", { embeddedClass: Resources.SOUND_RIGORMORTIS, priority: 5 });
        rm.pendResourceLoad("sound", "sfx_bloodlust", { embeddedClass: Resources.SOUND_BLOODLUST, priority: 5 });
        rm.pendResourceLoad("sound", "sfx_puzzlereset", { embeddedClass: Resources.SOUND_PUZZLERESET, priority: 5 });

        rm.pendResourceLoad("sound", "sfx_losegame", { embeddedClass: Resources.SOUND_LOSEGAME });
        rm.pendResourceLoad("sound", "sfx_wingame", { embeddedClass: Resources.SOUND_WINGAME });

        rm.pendResourceLoad("sound", "sfx_rsrc_white", { embeddedClass: Resources.SOUND_FLESH });
        rm.pendResourceLoad("sound", "sfx_rsrc_red", { embeddedClass: Resources.SOUND_BLOOD });
        rm.pendResourceLoad("sound", "sfx_rsrc_blue", { embeddedClass: Resources.SOUND_ENERGY });
        rm.pendResourceLoad("sound", "sfx_rsrc_yellow", { embeddedClass: Resources.SOUND_SCRAP });
        rm.pendResourceLoad("sound", "sfx_rsrc_lost", { embeddedClass: Resources.SOUND_LOSTRESOURCES });

        rm.pendResourceLoad("sound", "sfx_day", { embeddedClass: Resources.SOUND_ROOSTER, priority: 9 });
        rm.pendResourceLoad("sound", "sfx_night", { embeddedClass: Resources.SOUND_WOLF, priority: 9 });
        rm.pendResourceLoad("sound", "sfx_dawn", { embeddedClass: Resources.SOUND_CHIMES, priority: 9 });

        rm.pendResourceLoad("sound", "sfx_hit1", { embeddedClass: Resources.SOUND_HIT1});
        rm.pendResourceLoad("sound", "sfx_hit2", { embeddedClass: Resources.SOUND_HIT2 });
        rm.pendResourceLoad("sound", "sfx_hit3", { embeddedClass: Resources.SOUND_HIT3 });
        rm.pendResourceLoad("sound", "sfx_basehit1", { embeddedClass: Resources.SOUND_BASEHIT1, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit2", { embeddedClass: Resources.SOUND_BASEHIT2, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit3", { embeddedClass: Resources.SOUND_BASEHIT3, volume: 0.5 });

        rm.pendResourceLoad("sound", "sfx_spelldrop", { embeddedClass: Resources.SOUND_SPELLDROP, priority: 4 });

        // load!
        rm.load(handleResourcesLoaded, handleResourceLoadErr);
    }

    protected function handleResourcesLoaded () :void
    {
        //trace(AppContext.defaultGameData.generateUnitReport());

        MainLoop.instance.popMode();
    }

    protected function handleResourceLoadErr (err :String) :void
    {
        AppContext.mainLoop.unwindToMode(new ResourceLoadErrorMode(err));
    }
}

}

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

class ResourceLoadErrorMode extends AppMode
{
    public function ResourceLoadErrorMode (err :String)
    {
        _err = err;
    }

    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xFF7272);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.multiline = true;
        tf.wordWrap = true;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = 1.5;
        tf.scaleY = 1.5;
        tf.width = 400;
        tf.x = 50;
        tf.y = 50;
        tf.text = _err;

        this.modeSprite.addChild(tf);
    }

    protected var _err :String;
}
