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
*JCDecaux/Cyclocity is readying its own opendata platform, for spring 2013.*

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

## nextbike

*Unknown Terms of Use*

**75 cities worldwide, mostly Germany and Eastern europe.**

- List+Details (Template): `http://www.nextbike.de/maps/nextbike-official.xml?city={uid}`
- `http://www.nextbike.de/maps/nextbike-official.xml` returns data for all the cities, but Bicyclette currently only includes a portion of these cities. Typically, smaller cities, or cities which seemed to actually have zero bikes where ignored.

* **Nextbike** : 10vorWien, Auckland, Augsburg, Baku, Berlin, Bielefeld, Bregenzerwald, Burghausen, Christchurch, Coburg, Dresden, Dubai, Düsseldorf, Erfurt, Flensburg, Frankfurt, Gütersloh, Haag, Hamburg, Hannover, Konya, Krems, Laa, Leipzig, Limassol, Luzern, Magdeburg, Marchfeld, Mistelbach, Mödling, München, Neunkirchen, NeusiedlerSee,. Norderstedt, Nürnberg, Oberes, Offenburg, Opole, Piestingtal, Potsdam, Poznan, Salzburg, St.Pölten, Südheide, Thermenregion, Traisen-Gölsental, Triestingtal, Tulln, Tübingen, Unteres, Wachau, Waldviertel, Wieselburg, Wr.Neustadt, Wrocław, İzmir.
* **BalticBike** : Riga, Jurmala.
* **Metropolradruhr** : Duisburg, Dortmund, Hamm, Oberhausen, Bottrop, Gelsenkirche, Mülheim, Bochum, Essen, Herne.
* **Veturilo** : Warszawa

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

## Vélopass (Swiss)

*Credentials from Vélopass are needed to use this webservice.*

Velopass is being merged with Publibike, and some new services may be available in summer of 2013.

* **Vélopass** :  La&nbsp;Côte, Fribourg, Bulle, Les Lacs&nbsp;-&nbsp;Romont, Chablais, Valais Central, Yverdon-les-Bains, Lausanne&nbsp;-&nbsp;Morges & Campus, Vevey-Riviera, Lugano - Paradiso.

The Velopass app actually uses the SOAP webservice `service.tobike.it` as its backend. ([WSDL documentation](service.tobike.it))
Request:
	
	POST http://service.tobike.it/service.asmx
	Content-Type: application/soap+xml; charset=UTF-8
	
    <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
    	<soap12:Body>
    		<ElencoStazioniPerComune xmlns="c://inetub/wwwroot/webservice/Service.asmx">
    			<UsernameRivenditore>{pass}</UsernameRivenditore>
    			<PasswordRivenditore>{pass}</PasswordRivenditore>
    			<CodiceComune>{ID_VILLE}</CodiceComune>
    		</ElencoStazioniPerComune>
    	</soap12:Body>
    </soap12:Envelope>

---
# Not included in Bicyclette yet


## New York (Temporary)
"Temporary" data for the expected stations locations. Of course, no status info is available yet.

- List: `http://a841-tfpweb.nyc.gov/bikeshare/get_tentative_bikeshare_points`
- Details: `http://a841-tfpweb.nyc.gov/bikeshare/get_point_info?point=13897``

## Bicincitta / TOBike

The Torino and Bicincitta networks, used in many cities in Italy. Various versions of the services. The service.tobike.it backend is actually also used for Velopass in Swiss.

List of cities : http://www.bicincitta.com/comuni.asp

- List 1 (~20 cities) : Dirty HTML/javascript.http://bicincitta.tobike.it/frmLeStazioni.aspx?ID={city_id}
- List 2 (Torino+Region) : Dirty HTML/javascript.http://www.tobike.it/frmLeStazioni.aspx?ID={city_id}
- List 3 (Brescia) : Dirty HTML/javascript.http://service.bicimia.it/frmComuniAderentiInfo.aspx
- List 4 (http://www.bicincittabip.com/frmLeStazioni.aspx?ID=112
- Roma (older? similar to Pamplona) : http://www.bicincitta.com/citta_v3.asp?id=18&pag=2

Webservices (also used for Swiss VeloPass) :
http://service.tobike.it



## BCycle


Networks for a dozen of US cities, with relatively small coverage. Unfortunately, the data for all cities are all in the same list, and there's no clean way to separate them. No word on wether it can be used in 3rd party apps.

*Official webservice:*
*BCycle is currently updating its webservices to a new, 2.0 version.*

- `http://api.bcycle.com/services/mobile.svc/ListKiosks` (See specs at `http://api.bcycle.com/services/mobile.svc?wsdl`)

- Boulder, Colorado;
- Broward County, Florida;
- Charlotte, North Carolina
* Chicago, Illinois; (dead)
- Denver, Colorado;
- Des Moines, Iowa;
- Fort Worth (Coming Soon);
- Greenville;
- Houston, Texas;
- Kailua (Honolulu County), Hawaii;
- Kansas City, Kansas;
- Louisville,
- Madison, Wisconsin;
- Nashville; 
- Omaha, Nebraska;
- San Antonio, Texas;
- Salt Lake City ("greenbike")
- Spartanburg, South Carolina.

- Also, Austin is in the works. (2013/01)

## Laval
(Keolis)

- List (HTML) : `http://www.tul-laval.fr/velitul-stations.asp`
- Status of stations (HTML) : `http://www.tul-laval.fr/velitul-disponibilites.asp`

## Pau
(Keolis)

- List+Details (HTML) : `http://www.idecycle.com/stations/plan`

## Domoblue

*Unknown Terms of Use*

Call http://clientes.domoblue.es/onroll/generaMapa.php?cliente={city_id} to get the list of cities, it returns html to parse to get a token; then call 
http://clientes.domoblue.es/onroll/generaXml.php?token=806182692&cliente={id}, which returns the List+Details xml.

Use "todos" as the city id to get individual city ids instead of stations.

- A Rua
- Albacete
- Alhama de Murcia
- Almuñecar
- Antequera
- Aranda de Duero
- Aranjuez
- Badajoz
- Baeza
- Benidorm
- Blanca
- Cieza
- Ciudad Real
- Don Benito - Villanueva
- El Campello
- Elche
- Guadalajara
- Jaen
- JavierPruebas
- Lalin
- Las Palmas
- Montilla
- Mula
- Novelda
- O Barco
- Paiporta
- Palencia
- Pinto
- Priego de Cordoba
- Puerto Lumbreras
- Puertollano
- Redondela
- Salamanca
- San Javier
- San Pedro
- Sant Joan
- Segovia
- Soria
- Talavera
- Ubeda
- Universidad de Granada
- Via Verde
- Vigo
- Villaquilambre
- Villarreal
- Vinaros
 
## Bysykkel (Norway) (Clear Channel)

*Unknown Terms of Use*

- Oslo,
- Drammen,
- Trondheim.

Operated by Clear Channel. 
- Website : http://www.bysykler.no
- List : http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRacks, 
- Details : http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack (via POST. see wsdl spec at http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx)

This service also contains station info for Drammen. Trondheim seems to be missing as of 2013-03-18.

## Palma de Mallorca

*Unknown Terms of Use*

- Website : http://bicipalma.palmademallorca.es
- List+Details. http://83.36.51.60:8080/eTraffic3/Control?act=mp for the cookie, then http://83.36.51.60:8080/eTraffic3/DataServer?ele=equ&type=401&li=2.6265907287598&ld=2.6799774169922&ln=39.590768389513&ls=39.558367304613&zoom=15&adm=N&mapId=1&lang=es for the JSON.

## Stockholm City Bikes

Operated by Clear Channel Sverige	.
The [official website](http://www.citybikes.se/en/Here-are-our-cycle-stands/) uses data from https://bikemap.appified.net, who also made the iphone app.

*Unknown Terms of Use*, however there's a very aggressive refresh limit on the webservice. (it returns a 403 after 10 reloads.)

- List : https://bikemap.appified.net/a/grs/
- Details : https://bikemap.appified.net/a/gr/0c59508f792a57b5cee3231940890270/{station_id}

## ViaCycle (USA)

*Unknown Terms of Use*

HTML, but with clean JSON in it.
- Atlanta / Georgia Tech : https://gt.viacycle.com
- Patriot Bike Share (George Mason University) : https://gmu.viacycle.com
- Las Vegas : https://downtownproject.viacycle.com

## Forever Bicycle/China RMB

*Unknown Terms of Use*

1000+ stations in :

- Shangai and region
- Chengdu and region
- Shenyang
- Nanshan (near Shenzhen)

HTML, clean enough.
- List : http://self.chinarmb.com/FormStations.aspx
- Details : http://self.chinarmb.com/stationinfo.aspx?snumber=001001009027
- Webpage : http://www.chinarmb.com/page.aspx?id=713307143965

## Kyoto Machikado Minaport

*Unknown Terms of Use*

- Webpage : http://minaport.ubweb.jp/station.html
- List+Details : http://minaport.ubweb.jp/stations.php


## Yokohama Baybike
(Docomo Cycle)

*Unknown Terms of Use*

- List+Details (JSON) : http://docomo-cycle.jp/yokohama/map/getports/

## Daejeon (South Korea) Ta-Shu

*Unknown Terms of Use. Contact email actually invalid.*

- List+Details (json) : http://www.tashu.or.kr/mapAction.do?process=statusMapView

## Kaohsiung (Taiwan) C-Bike

*Unknown Terms of Use, no contact email found.*

List+Details (HTML, but relatively clean) : http://www.c-bike.com.tw/english/MapStation1.aspx
iPhone app available, https://itunes.apple.com/app/id492069747?mt=8

URLs from iPhone app : 
- http://www.c-bike.com.tw/xml/TutorialVideo.xml
- http://www.c-bike.com.tw/xml/MRT.xml
- http://www.c-bike.com.tw/xml/Bus.xml
- http://www.c-bike.com.tw/xml/InspectionStation.xml
- http://www.c-bike.com.tw/xml/ChargingStation.xml
- http://www.c-bike.com.tw/xml/viewslist.aspx?tid=1
- http://www.c-bike.com.tw/xml/viewslist.aspx?tid=2
- http://www.c-bike.com.tw/xml/viewslist.aspx?tid=3
- http://www.c-bike.com.tw/xml/viewslist.aspx?tid=4
- http://www.c-bike.com.tw/xml/iosstationlist.aspx

## TaiPen (Taiwan) YouBike

*Unknown Terms of Use*

- List+Details(XML) : http://www.youbike.com.tw/genxml.php

## Nicosia (Cyprus) (Smoove)

*Unknown Terms of Use*

HTML Scraping, reasonable.
- List+Details,  : http://www.podilatoendrasi.com.cy/frontoffice/bike_routes.html

## Bucharest (Cicloteque)

*Unknown Terms of Use*

HTML parsing, reasonable.

- List+Details : http://www.cicloteque.ro/retea/

---
# No plans to include in Bicyclette

(Because the HTML is way too dirty to scrape.)

## BikeNation (USA)

*Unknown Terms of Use*

Bikenation seems to be working on networks in Los Angeles and Long Beach (California) as well.

- Anaheim: List (no details) http://www.bikenationusa.com/services/API/Maps.asmx/GetLocations (POST {"locationId":"Anaheim"})

## Mobilicidata
HTML Scraping needed. Also try to reverse engineer the iphone app.

- **Sao Paulo** (List+Details) : http://ww2.mobilicidade.com.br/bikesampa/mapaestacao.asp
- **Rio** (List+Details) : http://ww2.mobilicidade.com.br/sambarjpt/mapaestacao.asp
- **Soracaba** (List+Details) : http://ww2.mobilicidade.com.br/sorocaba/mapaestacao.asp
- **Porto Alegre** (List+Details) : http://ww2.mobilicidade.com.br/bikepoa/mapaestacao.asp
- **Recife** (List+Details) : http://www.portoleve.org
- **Santos** (List+Details) : http://ww2.mobilicidade.com.br/bikesantos/mapaestacao.asp


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
Way too dirty to scrape. A new webservice is being created with the other Bysykkel networks. (see above)

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
* **Antwerpen**
	* List : https://www.velo-antwerpen.be/localizaciones/station_map.php
	* Details : curl -F "idStation=37" https://www.velo-antwerpen.be/CallWebService/StationBussinesStatus.php
	
## Bicileon

HTML Scraping needed, and no lat/long info.

* List and status : http://bicileon.com/estado/EstadoActual.asp

## Guadalajara, Mexico (Bikla)

HTML, dirty.

* List and status : http://www.bikla.net/index.php?Op=mapa

## Girona, Spain (Girocleta)

HTML/javascript. Hard to parse.

* list and stations : http://www.girocleta.cat/Mapadestacions.aspx

## Buenos Aires (bicicletapublica)

HTML/javascript
* List+Details : http://www.bicicletapublica.com.ar/mapa.aspx

## Tel-Aviv (Tel-O-Fun)

HTML both in list and details.

* List : https://www.tel-o-fun.co.il/en/TelOFunLocations.aspx
* Details : (separate request)

## Changwon (South Korea) NUBIJA

(Dirty HTML,javascript scraping needed)

* List+Details : http://nubija.changwon.go.kr/stn/stationState.do

## Fremantle (Australia) 

Planned.

* http://www.cyclefreo.com/the-plan/locations/

## OV-Velos (Netherlands)

* http://www.ov-fiets.nl/ovfiets
Map available, but could not find availability info. Not sure it makes sense.

## Newcastle (Scratchbike)

* List+Details (html) http://www.scratchbikes.co.uk/ (dirtiest pseudo-json ever.)

## Pamplona

Urgh.

* Flash map available at : http://195.88.6.82/08b_nbici/citta.asp?id=1000&pag=2
* Data (List and details) requested from : http://195.88.6.82/08b_nbici/citta.asp?id=1000&pag=2

Station coordinates are in pixels.

---
# Data unavailable on the web

- Chalon (Reflex)
* Angers (only 1 station)
* Montélimar (only 1 station)

* Medellin (Colombia) : http://www.encicla.gov.co/index.php/en/maps-en


## Broken websites

* Toopedalando (Toledo, Brazil) http://www.toopedalando.com.br/. Down 2013-03-18.
* Hangzhou. webservices? at http://www.hzzxc.com.cn/map/data-xml.php. Down 2013-03-18.
* Hourbike (UK). Dumfries, Blackpool, Southport. Maps available at http://www.hourbike.com/mysitecaddy/site3/index.htm, but live feed looks broken (?)
