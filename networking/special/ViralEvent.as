package networking.special
{
import flash.events.Event;
/**
 * ...
 * @author Alexey Kuznetsov
 */
public final class ViralEvent extends Event
{
	private var _stuff:Object;

	public static const PUBLISH_COMPLETE:String = "publishCompleet";
	public static const PURCHASE_SUCCESS:String = "purchaseSuccess";
	public static const PURCHASE_FAIL:String = "purchaseFail";

	public static const CONNECTED_TO_PLAYERIO:String = "connectedToPlayerio";
	public static const CONNECTED_TO_PLAYERIO_ROOM:String = "connectedToPlayerioRoom";
	public static const IN_APP_FRIENDS_LOADED:String = "inAppFriendsLoaded";
	public static const PLAYER_OBJECT_LOADED:String = "playerObjectLoaded";
	public static const START_DATA_LOADED:String = "startDataLoaded";
    public static const RECEIVED_AUTH_DATA:String = "receivedAuthData";

	public function ViralEvent(type:String, stuff:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
	{
		super(type, bubbles, cancelable);
		_stuff = stuff;
	}

	public function get stuff():Object {return _stuff;}
}
}