package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;

import flash.geom.Point;

public class NewPlayerIntroMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var infoView :InfoView = new InfoView(ClientCtx.mainLoop.popMode);
        infoView.x = LOC.x + (infoView.width * 0.5);
        infoView.y = LOC.y + (infoView.height * 0.5);
        addObject(infoView, _modeSprite);
    }

    override protected function destroy () :void
    {
        // When the intro mode is closed, let the server know we're ready
        // to start playing.
        ClientCtx.roundMgr.reportReadyForNextRound();
    }

    protected static const LOC :Point = new Point(10, 10);
}

}
