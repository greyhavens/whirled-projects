package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

public class LoadingMode extends AppMode
{
    override protected function setup () :void
    {
        PopCraft.resourceManager.pendResourceLoad("image", "heavy_icon",     { embeddedClass: IMAGE_HEAVYICON });
        PopCraft.resourceManager.pendResourceLoad("image", "colossus_icon",  { embeddedClass: IMAGE_COLOSSUSICON });

        PopCraft.resourceManager.pendResourceLoad("image", "base",      { embeddedClass: IMAGE_BASE });
        PopCraft.resourceManager.pendResourceLoad("image", "targetBaseBadge", { embeddedClass: IMAGE_TARGETBASEBADGE });
        PopCraft.resourceManager.pendResourceLoad("image", "friendlyBaseBadge", { embeddedClass: IMAGE_FRIENDLYBASEBADGE });
        PopCraft.resourceManager.pendResourceLoad("image", "sun", { embeddedClass: IMAGE_SUN });
        PopCraft.resourceManager.pendResourceLoad("image", "moon", { embeddedClass: IMAGE_MOON });
        PopCraft.resourceManager.pendResourceLoad("image", "battle_bg", { embeddedClass: IMAGE_BATTLE_BG });
        PopCraft.resourceManager.pendResourceLoad("image", "battle_fg", { embeddedClass: IMAGE_BATTLE_FG });
        PopCraft.resourceManager.pendResourceLoad("image", "bloodlust_icon", { embeddedClass: IMAGE_BLOODLUSTICON });
        PopCraft.resourceManager.pendResourceLoad("image", "rigormortis_icon", { embeddedClass: IMAGE_RIGORMORTISICON });

        PopCraft.resourceManager.pendResourceLoad("swf", "grunt", { embeddedClass: SWF_GRUNT });
        PopCraft.resourceManager.pendResourceLoad("swf", "sapper", { embeddedClass: SWF_SAPPER });

        PopCraft.resourceManager.pendResourceLoad("swf", "puzzlePieces", { embeddedClass: SWF_PUZZLEPIECES });

        PopCraft.resourceManager.addEventListener(ResourceLoadEvent.LOADED, handleResourcesLoaded);

        PopCraft.resourceManager.load();
    }

    override protected function destroy () :void
    {
        PopCraft.resourceManager.removeEventListener(ResourceLoadEvent.LOADED, handleResourcesLoaded);
    }

    protected function handleResourcesLoaded (...ignored) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }

    [Embed(source="../../rsrc/char_heavy.png", mimeType="application/octet-stream")]
    protected static const IMAGE_HEAVYICON :Class;

    [Embed(source="../../rsrc/char_colossus.png", mimeType="application/octet-stream")]
    protected static const IMAGE_COLOSSUSICON :Class;

    [Embed(source="../../rsrc/base.png", mimeType="application/octet-stream")]
    protected static const IMAGE_BASE :Class;

    [Embed(source="../../rsrc/skull_and_crossbones.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TARGETBASEBADGE :Class;

    [Embed(source="../../rsrc/smiley.png", mimeType="application/octet-stream")]
    protected static const IMAGE_FRIENDLYBASEBADGE :Class;

    [Embed(source="../../rsrc/sun.png", mimeType="application/octet-stream")]
    protected static const IMAGE_SUN :Class;

    [Embed(source="../../rsrc/moon.png", mimeType="application/octet-stream")]
    protected static const IMAGE_MOON :Class;

    [Embed(source="../../rsrc/city_bg.png", mimeType="application/octet-stream")]
    protected static const IMAGE_BATTLE_BG :Class;

    [Embed(source="../../rsrc/city_forefront.png", mimeType="application/octet-stream")]
    protected static const IMAGE_BATTLE_FG :Class;

    [Embed(source="../../rsrc/bloodlust_icon.png", mimeType="application/octet-stream")]
    protected static const IMAGE_BLOODLUSTICON :Class;

    [Embed(source="../../rsrc/rigormortis_icon.png", mimeType="application/octet-stream")]
    protected static const IMAGE_RIGORMORTISICON :Class;

    [Embed(source="../../rsrc/streetwalker.swf", mimeType="application/octet-stream")]
    protected static const SWF_GRUNT :Class;

    [Embed(source="../../rsrc/runt.swf", mimeType="application/octet-stream")]
    protected static const SWF_SAPPER :Class;

    [Embed(source="../../rsrc/pieces.swf", mimeType="application/octet-stream")]
    protected static const SWF_PUZZLEPIECES :Class;

}

}
