# Reference

- [The Bike-sharing World Map](https://maps.google.com/maps/ms?ie=UTF8&oe=UTF8&msa=0&msid=214135271590990954041.00043d80f9456b3416ced)
- [List of bicycle sharing systems](http://en.wikipedia.org/wiki/List_of_bicycle_sharing_systems)
- [Liste des systèmes de vélos en libre-service en France](http://fr.wikipedia.org/wiki/Liste_des_systèmes_de_vélos_en_libre-service_en_France)

---

# Already available in Bicyclette

## Rennes
(Keolis)

*Official open-data webservice*

- List+Details: `http://data.keolis-rennes.com/{xml,json}/?version=1.0&key={APIKEY}&cmd=getstation`
 
## Bordeaux
(Keolis)

*Official open-data webservice*

- List+Details: `http://data.lacub.fr/wfs?key={APIKEY}&SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=CI_VCUB_P&SRSNAME=EPSG:4326`

## Wien
(Cyclocity)

*Official webservice. See [Terms of use](http://www.citybikewien.at/cms/dynimages/mb/files/Terms_of_Use_XML.pdf)*.

- List+Details: `http://dynamisch.citybikewien.at/citybike_xml.php `

## Cyclocity
*Use of those services is tolerated by Cyclocity.*
> Note :
>  At least for Paris, official apps use [another service](http://blog.velib.paris.fr/blog/2012/12/17/des-stations-jusqua-votre-ecran-le-circuit-des-donnees-velib-2/).

The geolocation of the stations is sometimes very wrong.

(Hosted on the same servers.)

- Template :
	- List : `http://{servicewebsite}/service/carto`
	- Details : `http://{servicewebsite}/service/stationdetails/{city_name}/{station_id}`
- **Amiens** : www.velam.amiens.fr
- **Besancon** : www.velocite.besancon.fr
- **Brisbane** : www.citycycle.com.au
- **Bruxelles** : www.villo.be
- **CergyPointoise** : www.velo2.cergypontoise.fr
- **Creteil** : www.cristolib.fr (The CristoLib list also contains stations of the CergyPointoise service. That's an error.)
- **DublinBikes** : www.dublinbikes.ie
- **Goteborg** : www.goteborgbikes.se
- **Ljubljana** : www.bicikelj.si
- **Luxembourg** : www.veloh.lu
- **Marseille** : www.levelo-mpm.fr
- **Mulhouse** : www.velocite.mulhouse.fr
- **Nancy** : www.velostanlib.fr
- **Nantes** : www.bicloo.nantesmetropole.fr
- **Paris** : www.velib.paris.fr
- **Rouen** : cyclic.rouen.fr
- **Santander** : www.tusbic.es
- **Sevilla** : www.sevici.es
- **Toulouse** : www.velo.toulouse.fr
- **Toyama** : www.cyclocity.jp
- **Valencia** : www.valenbisi.es

## Lyon
(Cyclocity)

*No official opendata policy, but usage of the webservice is tolerated.*

Although it's very similar to other services by Cyclocity, webservices are different. The structure of the Station Details data is the same.

- List : `http://www.velov.grandlyon.com/velovmap/zhp/inc/StationsParArrondissement.php?arrondissement={69381,69382,69383,69384,69385,69386,69387,69388,69389}`
- Villeurbanne : 69266
- Caluire : 69034 (2 stations) 
- Vaulx-en-Velin : 69256 (1 station)
- Details : `http://www.velov.grandlyon.com/velovmap/zhp/inc/DispoStationsParId.php?id={station_id}`

## Lille
(Keolis)

*No official opendata policy, but usage of the webservice is tolerated.*

- List : `http://vlille.fr/stations/xml-stations.aspx``
- Details : `http://vlille.fr/stations/xml-station.aspx?borne={station_id}`

## Orléans
(Keolis)

*Unknown Terms of Use*

- List : `https://www.agglo-veloplus.fr/component/data_1.xml`
- Details : `https://www.agglo-veloplus.fr/getStatusBorne?idBorne={station_id}`

## BIXI
The data contains both the List of stations and the Status Details.

*Unknown Terms of Use*

- Canada (Hosted on the same servers.)
	- List+Details (Template) : `https://{servicewebsite.bixi.com}/data/bikeStations.xml`
	- **Toronto** : toronto.bixi.com
	- **Montréal** : montreal.bixi.com
	- **Ottawa** : capitale.bixi.com
- **London**
	- List+Details : `http://www.tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml`
- **Washington**
	- List+Details : `http://capitalbikeshare.com/data/stations/bikeStations.xml`
- **Minneapolis**
	- List+Details : `https://secure.niceridemn.org/data2/bikeStations.xml`
* **Boston**
	* List+Details : : `http://www.thehubway.com/data/stations/bikeStations.xml`
	* Boston also has an official opendata webservice (http://hubwaydatachallenge.org), but it's not as simple to use as the Bixi service.

## Melbourne
A BIXI network, but uses its own webservice.

*Unknown Terms of Use*

- List+Details : http://www.melbournebikeshare.com.au/stationmap/data

## Chattanooga
A BIXI network, but uses its own webservice.

*Unknown Terms of Use*

- List+Details : http://www.bikechattanooga.com/stations/json

## Nextbike

*Unknown Terms of Use*

**75 cities worldwide, mostly Germany and Eastern europe.**

- List+Details (Template): `http://www.nextbike.de/maps/nextbike-official.xml?city={uid}`
- `http://www.nextbike.de/maps/nextbike-official.xml` returns data for all the cities, but Bicyclette currently only includes a portion of these cities. Typically, smaller cities, or cities which seemed to actually have zero bikes where ignored.
	
## Nice
(Veloway-Veolia)

(Hosted on the same servers as Calais and Vannes.)

*No official opendata policy, but usage of the webservice is tolerated.*

- List+Details : `http://www.velobleu.org/cartoV2/libProxyCarto.asp`

## Veloway (Veolia)

*Unknown Terms of Use*

(Hosted on the same servers as Nice)

- **Calais**
	- List+Details : `http://www.vel-in.fr/cartoV2/libProxyCarto.asp`
- **Vannes**
	- List+Details : `http://www.velocea.fr/cartoV2/libProxyCarto.asp``

## Miami beach

*Unknown Terms of Use*

Same system runs in Surfside FL. The webservice returns the whole data.

- List+Details: `http://www.decobike.com/playmoves.xml`

## Long beach NY

*Unknown Terms of Use*

- List+Details: `http://decobikelbny.com/playmoves.xml`

## Smoove

*Unknown Terms of Use*

- **Montpellier**
	- List+Details : `http://cli-velo-montpellier.gir.fr/vcstations.xml`
- **Avignon**
	- List+Details : `http://www.velopop.fr/vcstations.xml`
- **Valence**
	- List+Details : `http://www.velo-libelo.fr/vcstations.xml`
- **Strasbourg**
	- List+Details : `http://www.velhop.strasbourg.eu/vcstations.xml`
- **Saint-Étienne**
	- List+Details : `http://www.velivert.fr/vcstations.xml`
- **Grenoble**
	- List+Details : `http://vms.metrovelo.fr/vcstations.xml`

## Barcelona
(Citybike)

*Unknown Terms of Use*

- List+Details : `https://www.bicing.cat/localizaciones/getJsonObject.php`

## La Rochelle

*No Known Webservice : HTML Scraping required.*

- List+Details: `http://www.rtcr.fr/ct_93_297__Carte_du_libre_service_velos.html`

---
# Not included in Bicyclette yet


## New York (Temporary)
"Temporary" data for the expected stations locations. Of course, no status info is available yet.

* List: `http://a841-tfpweb.nyc.gov/bikeshare/get_tentative_bikeshare_points`
* Details: `http://a841-tfpweb.nyc.gov/bikeshare/get_point_info?point=13897``

## TOBike

Originally the "Torino" service, also used in Switzerland (as "Velopass"). A WSDL documentation is available at service.tobike.it. No word on wether it can be used in 3rd party apps.

- `service.tobike.it` (See WSDL spec)

## BCycle

Networks for a dozen of US cities, with relatively small coverage. Unfortunately, the data for all cities are all in the same list, and there's no clean way to separate them. No word on wether it can be used in 3rd party apps.

- `http://api.bcycle.com/services/mobile.svc/ListKiosks` (See specs at `http://api.bcycle.com/services/mobile.svc?wsdl`)

## Laval
(Keolis)

- List (HTML) : `http://www.tul-laval.fr/velitul-stations.asp`
- Status of stations (HTML) : `http://www.tul-laval.fr/velitul-disponibilites.asp`

## Pau
(Keolis)

- List+Details (HTML) : `http://www.idecycle.com/stations/plan`

---
# No plans to include in Bicyclette

(Because the HTML is way too dirty to scrape.)

## Oslo

* List (HTML) : http://www.adshel.no/js/
* Details : http://www.adshel.no/js/getracknr.php?id=34

## Mobilicidata
HTML Scraping needed.

* **Sao Paulo** (List+Details) : http://ww2.mobilicidade.com.br/bikesampa/mapaestacao.asp
* **Rio** (List+Details) : http://ww2.mobilicidade.com.br/sambarjpt/mapaestacao.asp

## CityBike (aka Clear Channel) 1
The stations listing is only available on the webpage.
The "official" webservices are less useful because they won't give you the list of stations or the geolocation, so you have to rely on the webpage anyway.

- **Caen**
	* maps website: https://www.veol.caen.fr/localizaciones/localizaciones.php 
	* Webservice "autorisé" (Seulement les status des stations, pas de liste, pas de geoloc) : http://213.139.124.75/V1_DispoStationCaen/DispoStation.asmx
- **Dijon**
	* maps website: https://www.velodi.net/localizaciones/localizaciones.php
	* official webservice (Only stations status: no listing, no geoloc info) : http://213.139.124.75/V1_DispoStationDijon/DispoStation.asmx
- **Perpignan** :https://www.bip-perpignan.fr/localizaciones/localizaciones.php (no official webservice)
* **Milano** : http://www.bikemi.com/localizaciones/localizaciones.php (no official webservice)

## CityBike (aka Clear Channel) 2
Way too dirty to scrape.

* **Drammen** (List+Details) : `http://drammen.clearchannel.com/stationsmap`

* calls through an xmlhttprequest : 
 
    curl -X POST -H "Cache-Control: max-age=0" -H "Content-Length: 0" -H "Cookie: ASP.NET_SessionId=55i5wltwt2nj5llwwqxowj4t" -H "Content-Type: application/json; charset=UTF-8" http://drammen.clearchannel.com/WS/GService.asmx/GetGoogleObject

## CityBike (aka Clear Channel) 3
Way too dirty to scrape. Similar to Drammen, with an added step to get the station status.

* **Mexico City** :
	* List : https://www.ecobici.df.gob.mx/localizaciones/localizaciones.php
	* Details : curl -F "idStation=27" https://www.ecobici.df.gob.mx/CallWebService/StationBussinesStatus.php
* **Zaragoza**
	* List : https://www.bizizaragoza.com/localizaciones/station_map.php
	* Details : curl -F "idStation=27" https://www.bizizaragoza.com/CallWebService/StationBussinesStatus.php

---
# Data unavailable on the web

- Chalon (Reflex)
* Angers (only 1 station)
* Montélimar (only 1 station)
