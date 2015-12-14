/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.effects {
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import org.papervision3d.core.layers.*;

	public class LayerEffect extends AbstractEffect{
		
		private var layer:EffectLayer;
		private var filter:BitmapFilter;
		
		public function LayerEffect(filter:BitmapFilter){
			this.filter = filter;
		}
		
		
		public override function attachEffect(layer:EffectLayer):void{
			
			this.layer = layer;
			var filters:Array = layer.filters;
			filters.push(filter);
			layer.filters = filters;
			
		}
		public override function getEffect():BitmapFilter{
			return filter;
		}

	}
	
}
