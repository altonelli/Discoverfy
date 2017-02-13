# Discoverfy

Discoverfy uses the "Tinder Swipes" user interface to display 30-second music previews and help users find new music. Music is curated based off of the users Spotify music history. Swiping right will save a song to a Spotify playlist called "Discoverfy App". Swiping left will store the song in a database, not to be shown again.

## Motivation

I am always listening to the same songs and artists. The Discover Weekly playlist on Spotify is one of my favorite features, but I wanted more than 30 songs per week. So I built an app for that.

## Contributing

I am still cleaning a lot of the code, but suggestions are always welcome.

### Cloning

To clone this project for yourself you will need to become a Spotify Developer [here](https://developer.spotify.com/). You will need to add your client ID and Callback URL in the Config.h

```
#define kClientId "YOUR_SPOTIFY_CLIENT_ID"

#define kCallbackURL "YOUR_CALLBACK_URL"
```

I also recommend checking out the repository for the Discoverfy back-end [here](https://github.com/altonelli/DiscoverfyServer).

### Issues

Issues are tracked and can be added [here](https://github.com/altonelli/Discoverfy/issues).


## Built With

* [Spotify iOS SDK](https://developer.spotify.com/technologies/spotify-ios-sdk/)

## Author

**Arthur Tonelli** - Feel free to check out more about me [here](http://arthurtonelli.me) or check out my GitHub [here](https://github.com/altonelli).

## Acknowledgements

* *[Rob Mayoff](https://github.com/mayoff)* - Repo on creating catagory to create a UIImage out of a GIF. Repository is [here](https://github.com/mayoff/uiimage-from-animated-gif).
* *[Tony Million](https://github.com/tonymillion)* - Reachability framework for testing if the device has signal. Repository is [here](https://github.com/tonymillion/Reachability).
