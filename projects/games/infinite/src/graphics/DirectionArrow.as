package graphics
{
    import arithmetic.Vector;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sprites.SpriteUtil;
    
    public class DirectionArrow extends Sprite
    {
        public function DirectionArrow(direction:Vector)
        {
            super();
            draw(graphics);
            rotation = direction.rotation;
        }
        
        protected function draw (gr:Graphics) :void
        {
            gr.beginFill(SpriteUtil.BLACK, 1);
            moveTo(gr, a);
            lineTo(gr, b);
            lineTo(gr, c);
            lineTo(gr, d);
            lineTo(gr, e);
            lineTo(gr, f);
            lineTo(gr, g);
            lineTo(gr, a); 
            gr.endFill();
        }
        
        protected function moveTo(gr:Graphics, v:Vector) :void
        {
            const scaled:Vector = v.by(scale);
            gr.moveTo(scaled.dx, scaled.dy);
        }
        
        protected function lineTo(gr:Graphics, v:Vector): void
        {
            const scaled:Vector = v.by(scale);
            gr.lineTo(scaled.dx, scaled.dy);
        }

        protected const scale:Number = 3;
        
        protected static const a:Vector = Vector.W;
        protected static const b:Vector = Vector.W.by(2);
        protected static const c:Vector = Vector.N.by(3);
        protected static const d:Vector = Vector.E.by(2);
        protected static const e:Vector = Vector.E;
        protected static const f:Vector = Vector.E.add(Vector.S.by(3));
        protected static const g:Vector = Vector.W.add(Vector.S.by(3));
    }
}