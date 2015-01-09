package networking.networkers
{
    import networking.special.SocialPerson;
    import networking.special.ViralEvent;

    import utils.Misc;

    /**
     * ...
     * @author Alexey Kuznetsov
     */
    public final class DummyNetworker extends Networker implements INetworker
    {
        private var _coreLink:String = "https://www.facebook.external.com/"; //link that is used to navigate to profile pages after clicking on avatar

        public function DummyNetworker(flashVars:Object)
        {
            _uid = flashVars.uid;
		    //_uid = Misc.randomNumber(99999).toString();
        }

        public function init(flashVars:Object, appID:String = ""):void
        {
            _appID = appID;
        }

        public function getUserData():void
        {
        }

        public function getUserFriends():void
        {
            var all:Array = [];

            var friend1:SocialPerson = new SocialPerson()
            friend1.firstName = "Peter";
            friend1.uid = "54";
            friend1.photoURL = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/48985_100000462592304_8211_n.jpg";
            friend1.level = 55;
            friend1.inAppFriend = true;
            all.push(friend1);

            var friend2:SocialPerson = new SocialPerson()
            friend2.uid = "1456663208";
            friend2.firstName = "Patrick";
            friend2.inAppFriend = true;
            friend2.photoURL = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/372314_548075494_722296450_n.jpg";
            friend2.level = 12;
            all.push(friend2);

            var friend3:SocialPerson = new SocialPerson()
            friend3.firstName = "Susy";
            friend3.inAppFriend = true;
            friend3.photoURL = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/48985_100000462592304_8211_n.jpg";
            friend3.level = 33;
            all.push(friend3);

            var friend4:SocialPerson = new SocialPerson()
            friend4.firstName = "Paranchita";
            friend4.inAppFriend = true;
            friend4.photoURL = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/174448_100001731476934_6304158_n.jpg";
            friend4.level = 68;
            all.push(friend4);

            finishFriends(all);
        }

        private function finishFriends(allFriends:Array):void
        {
            _dispatcher.dispatchEvent(new ViralEvent(ViralEvent.IN_APP_FRIENDS_LOADED, allFriends));
        }

        public function getUsersNamesAndPhotos(usersIDS:Array):void
        {
        }

        public function getAvatarLinks(uidArray:Array):void
        {
        }

        public function getPhotoAndSexAndName(userID:String):void
        {
        }

        public function getPhotoAndName(userID:String):void
        {
        }

        public function showFriendInvite(uid:String):void
        {
        }

        public function showCoinAdder():void
        {
        }

        public function requestOfferData(offerID:int):void
        {
        }

        public function getRoomLink():String
        {
            return "http://link";
        }

        public function showSocialInvitePopup():void
        {
            trace("showing popup");
        }

        public function getUserAlbums():void
        {
            trace("getUserAlbums");
        }

        public function get coreLink():String
        {
            return _coreLink;
        }
    }
}