/**
 * Author: Alexey
 * Date: 10/10/12
 * Time: 11:49 PM
 */
package utils
{
import starling.display.Image;
import starling.textures.Texture;

public class IndisposableImage extends Image
{
	public function IndisposableImage(texture:Texture)
	{
		super(texture);
	}

	override public function dispose():void
	{
		//do nothing. Can't dispose it
	}
}
}
