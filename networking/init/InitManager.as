/**
 * Author: Alexey
 * Date: 7/22/12
 * Time: 12:27 AM
 */
package networking.init
{
    import model.userData.UserData;

    import networking.Networking;
    import networking.special.ViralEvent;

    /**
     * Basic initer.
     * More complicated inits are possible (e.g. when needed to get levels of friends)
     * Used for connecting to services & loading necessary data
     * Disatches success event in the end.
     */
    public class InitManager
    {
        private static var friendsLoaded:Boolean = false;

        public static function init():void
        {
            Networking.addEventListener(ViralEvent.IN_APP_FRIENDS_LOADED, onFriendsLoaded);
            Networking.getUserFriends();
        }

        protected static function onFriendsLoaded(event:ViralEvent):void
        {
            friendsLoaded = true;
            UserData.friends = event.stuff as Array;
            tryDispatchInitComplete();
        }

        private static function tryDispatchInitComplete():void
        {
            if (friendsLoaded)
            {
                dispatchComplete();
            }
        }

        private static function dispatchComplete():void
        {
            Networking.dispatchEvent(new ViralEvent(ViralEvent.START_DATA_LOADED));
        }
    }
}
