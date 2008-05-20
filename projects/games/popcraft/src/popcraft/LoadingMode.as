package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

public class LoadingMode extends AppMode
{
    override protected function setup () :void
    {
        // data
        ResourceManager.instance.pendResourceLoad("gameData", "defaultGameData", { embeddedClass: Resources.DEFAULT_GAME_DATA });

        // gfx
        ResourceManager.instance.pendResourceLoad("image", "colossus_icon",  { embeddedClass: Resources.IMAGE_COLOSSUSICON });
        ResourceManager.instance.pendResourceLoad("image", "courier_icon", { embeddedClass: Resources.IMAGE_COURIERICON });

        ResourceManager.instance.pendResourceLoad("image", "base",      { embeddedClass: Resources.IMAGE_BASE });
        ResourceManager.instance.pendResourceLoad("image", "targetBaseBadge", { embeddedClass: Resources.IMAGE_TARGETBASEBADGE });
        ResourceManager.instance.pendResourceLoad("image", "friendlyBaseBadge", { embeddedClass: Resources.IMAGE_FRIENDLYBASEBADGE });
        ResourceManager.instance.pendResourceLoad("image", "sun", { embeddedClass: Resources.IMAGE_SUN });
        ResourceManager.instance.pendResourceLoad("image", "moon", { embeddedClass: Resources.IMAGE_MOON });
        ResourceManager.instance.pendResourceLoad("image", "battle_bg", { embeddedClass: Resources.IMAGE_BATTLE_BG });
        ResourceManager.instance.pendResourceLoad("image", "battle_fg", { embeddedClass: Resources.IMAGE_BATTLE_FG });
        ResourceManager.instance.pendResourceLoad("image", "bloodlust_icon", { embeddedClass: Resources.IMAGE_BLOODLUSTICON });
        ResourceManager.instance.pendResourceLoad("image", "rigormortis_icon", { embeddedClass: Resources.IMAGE_RIGORMORTISICON });
        ResourceManager.instance.pendResourceLoad("image", "mult_15", { embeddedClass: Resources.IMAGE_MULT15 });
        ResourceManager.instance.pendResourceLoad("image", "mult_20", { embeddedClass: Resources.IMAGE_MULT20 });
        ResourceManager.instance.pendResourceLoad("image", "mult_25", { embeddedClass: Resources.IMAGE_MULT25 });

        ResourceManager.instance.pendResourceLoad("swf", "grunt", { embeddedClass: Resources.SWF_GRUNT });
        ResourceManager.instance.pendResourceLoad("swf", "sapper", { embeddedClass: Resources.SWF_SAPPER });
        ResourceManager.instance.pendResourceLoad("swf", "heavy", { embeddedClass: Resources.SWF_HEAVY });

        ResourceManager.instance.pendResourceLoad("swf", "puzzlePieces", { embeddedClass: Resources.SWF_PIECES });
        ResourceManager.instance.pendResourceLoad("swf", "dashboard", { embeddedClass: Resources.SWF_DASHBOARD });

        // sfx
        ResourceManager.instance.pendResourceLoad("sound", "sfx_create_grunt", { embeddedClass: Resources.SOUND_GRUNT });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_create_heavy", { embeddedClass: Resources.SOUND_HEAVY });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_create_sapper", { embeddedClass: Resources.SOUND_SAPPER });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_create_colossus", { embeddedClass: Resources.SOUND_COLOSSUS });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_create_courier", { embeddedClass: Resources.SOUND_COURIER });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_death_sapper", { embeddedClass: Resources.SOUND_EXPLOSION });

        ResourceManager.instance.pendResourceLoad("sound", "sfx_rsrc_white", { embeddedClass: Resources.SOUND_FLESH });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_rsrc_red", { embeddedClass: Resources.SOUND_BLOOD });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_rsrc_blue", { embeddedClass: Resources.SOUND_ENERGY });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_rsrc_yellow", { embeddedClass: Resources.SOUND_ARTIFICE });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_rsrc_lost", { embeddedClass: Resources.SOUND_LOSTRESOURCES });

        ResourceManager.instance.pendResourceLoad("sound", "sfx_day", { embeddedClass: Resources.SOUND_ROOSTER });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_night", { embeddedClass: Resources.SOUND_WOLF });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_dawn", { embeddedClass: Resources.SOUND_CHIMES });

        ResourceManager.instance.pendResourceLoad("sound", "sfx_hit1", { embeddedClass: Resources.SOUND_HIT1 });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_hit2", { embeddedClass: Resources.SOUND_HIT2 });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_hit3", { embeddedClass: Resources.SOUND_HIT3 });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_basehit1", { embeddedClass: Resources.SOUND_BASEHIT1 });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_basehit2", { embeddedClass: Resources.SOUND_BASEHIT2 });
        ResourceManager.instance.pendResourceLoad("sound", "sfx_basehit3", { embeddedClass: Resources.SOUND_BASEHIT3 });

        ResourceManager.instance.pendResourceLoad("sound", "sfx_spelldrop", { embeddedClass: Resources.SOUND_SPELLDROP });

        // load!
        ResourceManager.instance.load(handleResourcesLoaded, handleResourceLoadErr);
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
