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
        rm.pendResourceLoad("image", "mult_15", { embeddedClass: Resources.IMAGE_MULT15 });
        rm.pendResourceLoad("image", "mult_20", { embeddedClass: Resources.IMAGE_MULT20 });
        rm.pendResourceLoad("image", "mult_25", { embeddedClass: Resources.IMAGE_MULT25 });

        rm.pendResourceLoad("swf", "grunt", { embeddedClass: Resources.SWF_GRUNT });
        rm.pendResourceLoad("swf", "sapper", { embeddedClass: Resources.SWF_SAPPER });
        rm.pendResourceLoad("swf", "heavy", { embeddedClass: Resources.SWF_HEAVY });
        rm.pendResourceLoad("swf", "colossus", { embeddedClass: Resources.SWF_COLOSSUS });
        rm.pendResourceLoad("swf", "courier", { embeddedClass: Resources.SWF_COURIER });

        rm.pendResourceLoad("swf", "puzzlePieces", { embeddedClass: Resources.SWF_PIECES });
        rm.pendResourceLoad("swf", "dashboard", { embeddedClass: Resources.SWF_DASHBOARD });

        // sfx
        rm.pendResourceLoad("sound", "sfx_create_grunt", { embeddedClass: Resources.SOUND_GRUNT });
        rm.pendResourceLoad("sound", "sfx_create_heavy", { embeddedClass: Resources.SOUND_HEAVY });
        rm.pendResourceLoad("sound", "sfx_create_sapper", { embeddedClass: Resources.SOUND_SAPPER });
        rm.pendResourceLoad("sound", "sfx_create_colossus", { embeddedClass: Resources.SOUND_COLOSSUS });
        rm.pendResourceLoad("sound", "sfx_create_courier", { embeddedClass: Resources.SOUND_COURIER });
        rm.pendResourceLoad("sound", "sfx_death_sapper", { embeddedClass: Resources.SOUND_EXPLOSION });

        rm.pendResourceLoad("sound", "sfx_rsrc_white", { embeddedClass: Resources.SOUND_FLESH });
        rm.pendResourceLoad("sound", "sfx_rsrc_red", { embeddedClass: Resources.SOUND_BLOOD });
        rm.pendResourceLoad("sound", "sfx_rsrc_blue", { embeddedClass: Resources.SOUND_ENERGY });
        rm.pendResourceLoad("sound", "sfx_rsrc_yellow", { embeddedClass: Resources.SOUND_SCRAP });
        rm.pendResourceLoad("sound", "sfx_rsrc_lost", { embeddedClass: Resources.SOUND_LOSTRESOURCES });

        rm.pendResourceLoad("sound", "sfx_day", { embeddedClass: Resources.SOUND_ROOSTER });
        rm.pendResourceLoad("sound", "sfx_night", { embeddedClass: Resources.SOUND_WOLF });
        rm.pendResourceLoad("sound", "sfx_dawn", { embeddedClass: Resources.SOUND_CHIMES });

        rm.pendResourceLoad("sound", "sfx_hit1", { embeddedClass: Resources.SOUND_HIT1});
        rm.pendResourceLoad("sound", "sfx_hit2", { embeddedClass: Resources.SOUND_HIT2 });
        rm.pendResourceLoad("sound", "sfx_hit3", { embeddedClass: Resources.SOUND_HIT3 });
        rm.pendResourceLoad("sound", "sfx_basehit1", { embeddedClass: Resources.SOUND_BASEHIT1, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit2", { embeddedClass: Resources.SOUND_BASEHIT2, volume: 0.5 });
        rm.pendResourceLoad("sound", "sfx_basehit3", { embeddedClass: Resources.SOUND_BASEHIT3, volume: 0.5 });

        rm.pendResourceLoad("sound", "sfx_spelldrop", { embeddedClass: Resources.SOUND_SPELLDROP });

        // load!
        rm.load(handleResourcesLoaded, handleResourceLoadErr);
    }

    protected function handleResourcesLoaded () :void
    {
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
