/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	
	import org.papervision3d.core.layers.*;
	

	public class BitmapConvolutionEffect extends AbstractEffect{
		
		private var layer:BitmapEffectLayer;
		public var filter:ConvolutionFilter;
		public var convolutionMatrix:Array;
		public var divisor:Number;
		
		public function BitmapConvolutionEffect(convolutionMatrix:Array, divisor:Number = 9){
			
			this.convolutionMatrix = convolutionMatrix;
			this.divisor = divisor;
			filter = new ConvolutionFilter(3, 3, convolutionMatrix, this.divisor);
		}
		
		public function updateEffect(convolutionMatrix:Array):void{

			this.convolutionMatrix = convolutionMatrix;
			filter = new ConvolutionFilter(3, 3, convolutionMatrix, this.divisor);
		}
		public override function attachEffect(layer:EffectLayer):void{
			
			this.layer = BitmapEffectLayer(layer);
			
		}
		public override function postRender():void{
			
			layer.canvas.applyFilter(layer.canvas, layer.canvas.rect, new Point(), filter);
			
		}
	}
	
}
