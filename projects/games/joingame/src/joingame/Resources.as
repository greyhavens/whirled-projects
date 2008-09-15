package joingame
{
    public class Resources
    {
        [Embed(source="../../rsrc/campaign_pieces.swf", mimeType="application/octet-stream")]
        public static const PIECES_DATA :Class;
        
        [Embed(source="../../rsrc/BG.png", mimeType="application/octet-stream")]
        public static const IMG_BG :Class;
        
        [Embed(source="../../rsrc/BG_watcher.png", mimeType="application/octet-stream")]
        public static const IMG_BG_WATCHER :Class;
        
        [Embed(source="../../rsrc/UI.swf", mimeType="application/octet-stream")]
        public static const UI_DATA :Class;

    }
}