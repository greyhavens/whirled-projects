package org.papervision3d.core.render.command
{
	import flash.display.Graphics;
	
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.special.FogMaterial;
	import org.papervision3d.view.Viewport3D;
	
	public class RenderFog extends RenderableListItem
	{

		public var alpha:Number;
		public var material:FogMaterial;
		
		public function RenderFog(material:FogMaterial, alpha:Number = 0.5, depth:Number=0)
		{
			super();
			this.alpha= alpha;
			this.screenDepth = depth;
			this.material = material;
			
			
		}
		
		public override function render(renderSessionData:RenderSessionData, graphics:Graphics):void{
			
			material.draw(renderSessionData, graphics, alpha);
			
		}
		
	}
}