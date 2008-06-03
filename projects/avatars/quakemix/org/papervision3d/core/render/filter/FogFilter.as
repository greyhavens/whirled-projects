package org.papervision3d.core.render.filter
{
	import org.papervision3d.core.render.command.RenderFog;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.materials.special.FogMaterial;
	
	public class FogFilter extends BasicRenderFilter
	{
		
		private var _maxDepth:Number;
		public function set maxDepth(value:Number):void{
			_maxDepth = value;
			if(_maxDepth < _minDepth)
				_minDepth = _maxDepth-1;
		}
		
		public function get maxDepth():Number{
			return _maxDepth;
		}
		
		private var _minDepth:Number;
		public function set minDepth(value:Number):void{
			_minDepth = value;
			if(_maxDepth < _minDepth)
				_maxDepth = minDepth+1;
		}
		
		public function get minDepth():Number{
			return _minDepth;
		}
		
		public var segments:Number;
		public var material:FogMaterial;
		
		public function FogFilter(material:FogMaterial, segments:uint=8, minDepth:Number=200, maxDepth:Number=4000)
		{
			super();
			this.material = material;
			this.segments = segments;
			this.minDepth = minDepth;
			this.maxDepth = maxDepth;
		}
			
		public override function filter(array:Array):int{
			
			var segOffset:Number = (_maxDepth-_minDepth)/segments;
			var segDepth:Number = _minDepth;
			var cSeg:Number = 0;
			var alpha:Number = 1-(segments/100);
			var alphaOffset:Number = alpha/segments; 
	
			
			for(var i:int=array.length-1;i>=0;i--){
				if(array[i].screenDepth >= maxDepth)
					removeRenderItem(array, i);
			} 		
				
			for(var ii:int=0;ii<segments;ii++){
				array.push(new RenderFog(material, ((alpha/segments)*ii+((ii)/100)), segDepth));
				segDepth += segOffset;			
			}
			
						
			return 0;
			
		}
		
		private function visibleDepth(element:RenderableListItem, index:int, arr:Array):Boolean {
            return (element.screenDepth < _maxDepth);
        }
		
		private function removeRenderItem(ar:Array, index:Number):void{
			ar = ar.splice(index, 1);
		}
		
		
	}
}