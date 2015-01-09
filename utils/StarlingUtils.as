/**
 * Author: Alexey
 * Date: 8/31/12
 * Time: 11:05 PM
 */
package utils
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;

	public class StarlingUtils
	{
		public static function copyStage3DBitmapData(displayObject:DisplayObject, transparentBackground:Boolean = false, backgroundColor:uint = 0xcccccc):BitmapData
		{
			var resultRect:Rectangle = new Rectangle();
			displayObject.getBounds(displayObject, resultRect);

			var result:BitmapData = new BitmapData(resultRect.width, resultRect.height, transparentBackground, backgroundColor);
			var context:Context3D = Starling.context;
			var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			support.setOrthographicProjection(Config.APP_WIDTH, Config.APP_HEIGHT);
			support.applyBlendMode(true);
			support.translateMatrix(-resultRect.x, -resultRect.y);
			support.pushMatrix();
			support.blendMode = displayObject.blendMode;
			displayObject.render(support, 1.0);
			support.popMatrix();
			support.finishQuadBatch();
			context.drawToBitmapData(result);
			return result;
		}
	}
}
