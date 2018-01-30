Bicyclette is the **best** iOS app for Bike-Sharing systems. It’s ultra-fast and ultra-simple. It works in more than 50 cities in the world.

Just a map. With stations. Nothing else.

You don’t even have to launch the app : Bicyclette automatically fetches the number of bikes available when you approach your favorite station and shows a notification on the Lock Screen.

See [bicyclette-app.com](http://bicyclette-app.com) for details.

# Development Notes

## DataGrabber

For some cities, Bicyclette embeds the list of stations of the network. The point is that at first launch, you don’t have to wait for the station to load anything. The tool responsible for this is *DataGrabber*. It fetches the data for every system, and saves the database for a few dozens of these. This data is then copied as resources of the app.

Although it’s a mac tol, *DataGrabber* uses the same backend code as the app. It must be run at least once before compiling Bicyclette.

DataGrabber can be run with several options, controlled by userdefaults/command line arguments. Look into the *DataGrabber* scheme run options for details.

## Accounts

Some webservices (namely, Bordeaux, Rennes, Velopass, and TOBike) require an API key info to connect to their webservices. This information (the _Accounts.json file) is *not* included in the Bicyclette repository. You'll have to get your own API keys.

## Mapping

The single most important file in the app is [BicycletteCities.json](Files/Cities/BicycletteCities.json). It contains Keys-Mapping definitions, urls, general info, and other specific tidbits for every city of Bicyclette.

Also important is [Cities.md](Cities.md) where I listed implementation notes for each system.

Bicyclette uses another of my projects, [KVCMapping](https://github.com/n-b/KVCMapping) to make importing into the DB very easy.

## Screenshots

There’s another run scheme that tries to make easier the whole process of making screenshots for the appstore (and for the Default.png). Again, look for the options in the Run Arguments of the *Screenshots* scheme.

## Contributions

are most welcome. Just [contact me](mailto:nico@bou.io) before you start something big, I may have some idea about it.

## Reusing code and compontents

The code is BSD-licensed. However : 

* If you want to adapt it to another platform, tell me about it.
* Don’t publish a clone on the iOS appstore. Hell, it’s a free and open-source app, what would be the point ?
