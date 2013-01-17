# Reference

- [The Bike-sharing World Map](https://maps.google.com/maps/ms?ie=UTF8&oe=UTF8&msa=0&msid=214135271590990954041.00043d80f9456b3416ced)
- [List of bicycle sharing systems](http://en.wikipedia.org/wiki/List_of_bicycle_sharing_systems)
- [Liste des systèmes de vélos en libre-service en France](http://fr.wikipedia.org/wiki/Liste_des_systèmes_de_vélos_en_libre-service_en_France)


# "Official" Webservices

## Rennes
A Keolis/EFFIA network, with its own **Official** open-data webservice.
- http://data.keolis-rennes.com/{xml,json}/?version=1.0&key={APIKEY}&cmd=getstation
 
## Bordeaux
A Keolis/EFFIA network, with its own **Official** open-data webservice.
- http://data.lacub.fr/wfs?key={APIKEY}&SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=CI_VCUB_P&SRSNAME=EPSG:4326

## Wien
A Cyclocity network, with its own **official** webservice. Terms of use : http://www.citybikewien.at/cms/dynimages/mb/files/Terms_of_Use_XML.pdf.
- List+Details: http://dynamisch.citybikewien.at/citybike_xml.php 

## Cyclocity
Although it's unofficial, use of those services is "tolerated" by JCDecaux. At least for Paris, official apps use [another service](http://blog.velib.paris.fr/blog/2012/12/17/des-stations-jusqua-votre-ecran-le-circuit-des-donnees-velib-2/).
The data are relatively clean, and easily parsed, but the geolocation of stations is sometimes very wrong. It appears all those services are actually hosted on the same servers.
- Model :
	- List http://{servicewebsite}/service/carto
	- Details : http://{servicewebsite}/service/stationdetails/{city_name}/{station_id}
- Amiens : www.velam.amiens.fr
- Besancon : www.velocite.besancon.fr
- Brisbane : www.citycycle.com.au
- Bruxelles : www.villo.be
- CergyPointoise : www.velo2.cergypontoise.fr
- Creteil : www.cristolib.fr (The CristoLib list also contains stations of the CergyPointoise service.)
- DublinBikes : www.dublinbikes.ie
- Goteborg : www.goteborgbikes.se
- Ljubljana : www.bicikelj.si
- Luxembourg : www.veloh.lu
- Marseille : www.levelo-mpm.fr
- Mulhouse : www.velocite.mulhouse.fr
- Nancy : www.velostanlib.fr
- Nantes : www.bicloo.nantesmetropole.fr
- Paris : www.velib.paris.fr
- Rouen : cyclic.rouen.fr
- Santander : www.tusbic.es
- Sevilla : www.sevici.es
- Toulouse : www.velo.toulouse.fr
- Toyama : www.cyclocity.jp
- Valencia : www.valenbisi.es

## Lyon
Althought it's very similar to other services by Cyclocity, webservices are different. The structure of the Station Details data is the same.
- List : http://www.velov.grandlyon.com/velovmap/zhp/inc/StationsParArrondissement.php?arrondissement={69381,69382,69383,69384,69385,69386,69387,69388,69389}
- Details : http://www.velov.grandlyon.com/velovmap/zhp/inc/DispoStationsParId.php?id={station_id}



# Other Webservices

Either reverse-engineered, or publicly available but without terms of use in a 3rd Party app.

## Orléans
A Keolis/EFFIA network, with its own webservices.
- List : https://www.agglo-veloplus.fr/component/data_1.xml
- Details : https://www.agglo-veloplus.fr/getStatusBorne?idBorne={station_id}

## BIXI
The data contains both the List of stations and the Status Details.
- Canada
	- (hosted on the same servers)
	- Model : https://{city}.bixi.com/data/bikeStations.xml
	- Toronto : toronto.bixi.com
	- Montréal : montreal.bixi.com
	- Ottawa : capitale.bixi.com
* London : http://www.tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml
* Washington : http://capitalbikeshare.com/data/stations/bikeStations.xml
* Boston : http://www.thehubway.com/data/stations/bikeStations.xml
	* http://hubwaydatachallenge.org/api/v1/stationstatus/?format=json&username=n-b&api_key=10f6a298f1155b29a13648d66fac42ef7af4487e&station=33&update__lte=2011-08-27T1:10&order_by=-update
	* http://hubwaydatachallenge.org/api/v1/station/?format=json&username=n-b&api_key=10f6a298f1155b29a13648d66fac42ef7af4487e
* Minneapolis : https://secure.niceridemn.org/data2/bikeStations.xml 

## Melbourne
A BIXI network, but uses its own webservice.
 * List+Details : http://www.melbournebikeshare.com.au/stationmap/data

## Chattanooga
A BIXI network, but uses its own webservice.
* List+Details : http://www.bikechattanooga.com/stations/json

## Nextbike
No details yet on whether these services can be legally used in 3rd party apps.
The data contains both the List of stations and the Status Details.
**75 cities** worldwide, mostly Germany and Eastern europe : 
* Model (http://www.nextbike.de/maps/nextbike-official.xml?city={uid}

## Veloway (Veolia)
No details yet on whether these services can be legally used in 3rd party apps.
The data contains both the List of stations and the Status Details. It appears all those services are actually hosted on the same servers.
Model : http://{servicewebsite}/cartoV2/libProxyCarto.asp
- Calais : http://www.vel-in.fr
- Nice : http://www.velobleu.org
- Vannes : http://www.velocea.fr

## OYBike
No details yet on whether these services can be legally used in 3rd party apps. The API key used is used in the "official" website.
The data contains both the List of stations and the Status Details. 
- Reading & Cardiff : http://www.oybike.com/oybike/stands.nsf/getSite?openagent&site={city}&format=json&cache=no&extended=yes&key=7A407C7C8DD673BD9A635ECFAB612C95

## TOBike
Originally the "Torino" service, also used in Switzerland (as "Velopass"). A WSDL documentation is available at service.tobike.it. No word on wether it can be used in 3rd party apps.
* service.tobike.it (See WSDL spec)

## BCycle
Networks for a dozen of US cities, with relatively small coverage. Unfortunately, the data for all cities are all in the same list, and there's no clean way to separate them. No word on wether it can be used in 3rd party apps.
	* http://api.bcycle.com/services/mobile.svc/ListKiosks (See specs at http://api.bcycle.com/services/mobile.svc?wsdl)

## Miami beach
No Licence information.
* List+Details: http://www.decobike.com/playmoves.xml

## Smoove
No Licence information.
* Montpellier : http://cli-velo-montpellier.gir.fr/vcstations.xml
* Avignon : http://www.velopop.fr/vcstations.xml
* Valence : http://www.velo-libelo.fr/vcstations.xml
* Strasbourg : http://www.velhop.strasbourg.eu/vcstations.xml
* Saint-Etienne : http://www.velivert.fr/vcstations.xml
* Grenoble : http://vms.metrovelo.fr/vcstations.xml

## Barcelona
A Citybike network, with its own webservice. No Licence Info.
* List+Details : https://www.bicing.cat/localizaciones/getJsonObject.php

# New York (tentative)
"Temporary" data for the expected stations locations. Of course, no status info is available.
* List: http://a841-tfpweb.nyc.gov/bikeshare/get_tentative_bikeshare_points
* Details: http://a841-tfpweb.nyc.gov/bikeshare/get_point_info?point=13897


# HTML parsing
No real webservice available for those networks : data has to be extracted from the html source.
Of course, no terms of use are available.

## La Rochelle
- List+Details : http://www.rtcr.fr/ct_93_297__Carte_du_libre_service_velos.html
- http://flexbike.l-rd.fr/yelo-stations.php  ???

## Keolis (Effia)
- Pau (List+Details) : http://www.idecycle.com/stations/plan
- Lille (List+Details) :
	* http://vlille.fr/stations/xml-stations.aspx
	* http://vlille.fr/stations/xml-station.aspx?borne=<ID>
- Laval
	- List : http://www.tul-laval.fr/velitul-stations.asp
	- Details of all stations : http://www.tul-laval.fr/velitul-disponibilites.asp

## Mobilicidata
* Sao Paulo (List+Details) : http://ww2.mobilicidade.com.br/bikesampa/mapaestacao.asp
* Rio (List+Details) : http://ww2.mobilicidade.com.br/sambarjpt/mapaestacao.asp

# Oslo
    * List (HTML parsing required) : http://www.adshel.no/js/
    * Details (real webservice) : http://www.adshel.no/js/getracknr.php?id=34

## CityBike (aka Clear Channel)

## Modèle 1 
The stations listing is only available on the webpage, which is not easy to scrape. Maybe later.
The "official" webservices are basically useless because they won't give you the list of stations or the geolocation, so you have to rely on the webpage anyway.
- Caen
	* site web carto: https://www.veol.caen.fr/localizaciones/localizaciones.php 
	* Webservice "autorisé" (Seulement les status des statiosn, pas de liste, pas de geoloc) : http://213.139.124.75/V1_DispoStationCaen/DispoStation.asmx
- Dijon
	* site web carto: https://www.velodi.net/localizaciones/localizaciones.php
	* Webservice "autorisé" (Seulement les status des statiosn, pas de liste, pas de geoloc) : http://213.139.124.75/V1_DispoStationDijon/DispoStation.asmx
- Perpignan
	* site web carto: https://www.bip-perpignan.fr/localizaciones/localizaciones.php
	* pas de Webservice "autorisé"
* Milano
	* site web carto: http://www.bikemi.com/localizaciones/localizaciones.php
	* pas de Webservice "autorisé"

## Modèle 2
Way too dirty to scrape.
* Drammen (List+Details) : http://drammen.clearchannel.com/stationsmap
 appelle en xmlhttprequest  : curl -X POST -H "Cache-Control: max-age=0" -H "Content-Length: 0" -H "Cookie: ASP.NET_SessionId=55i5wltwt2nj5llwwqxowj4t" -H "Content-Type: application/json; charset=UTF-8" http://drammen.clearchannel.com/WS/GService.asmx/GetGoogleObject
  fermé pour l'hiver de toute façon.
## Modèle 3
Way too dirty to scrape. Similar to Drammen, with an added step to get the station status.
* Mexico City : 
	* List : https://www.ecobici.df.gob.mx/localizaciones/localizaciones.php
	* Details : curl -F "idStation=27" https://www.ecobici.df.gob.mx/CallWebService/StationBussinesStatus.php
* Zaragoza
	* List : https://www.bizizaragoza.com/localizaciones/station_map.php
	* Details : curl -F "idStation=27" https://www.bizizaragoza.com/CallWebService/StationBussinesStatus.php

# Data unavailable

* Chalon (Reflex)
* Angers (only 1 station)
* Montélimar (only 1 station)
