package vampire.combat.client
{

public class ModePlayerChooseActions extends ModeBase
{
    public function ModePlayerChooseActions(ctx :GameInstance)
    {
        super(ctx);
    }

    override public function pushed():void
    {
        super.pushed();
        _ctx.panel.attachActionChooser();
        _ctx.controller.handleUnitClicked(_ctx.friendlyUnits[0]);
    }
//
    override public function popped():void
    {
        super.popped();
        _ctx.panel.detachActionChooser();
    }
//
//    public function pushedOnto(mode:GameMode):void
//    {
//    }
//
//    public function poppedFrom(mode:GameMode):void
//    {
//    }

}
}