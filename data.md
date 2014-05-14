---
layout: data
---

# Bike Sharing Services in Bicyclette.app

These are the various webservices [Bicyclette](http://www.bicyclette-app.com) uses to fetch its data.  
For more general information, you can also take a look at [the Bike-sharing World Map](https://maps.google.com/maps/ms?ie=UTF8&oe=UTF8&msa=0&msid=214135271590990954041.00043d80f9456b3416ced), the wikipedia [List of bicycle sharing systems](http://en.wikipedia.org/wiki/List_of_bicycle_sharing_systems) in the world, or the (french) [Liste des systèmes de vélos en libre-service en France](http://fr.wikipedia.org/wiki/Liste_des_systèmes_de_vélos_en_libre-service_en_France).

---

## Systems already available in Bicyclette

### JCDecaux/Cyclocity
Registration and documentation at `developer.jcdecaux.com`.
Opendata platform available at `developer.jcdecaux.com.` for the following services.

> Amiens (Velam), Besançon (Velocite), Bruxelles (Villo), Cergy-Pointoise (Velo2), Créteil (Cristolib), Göteborg (Goteborgbikes), Kazan (Veli'k), Lillestrøm (Bysykkel), Ljubljana (Bicikelj), Luxembourg (Veloh), Lyon (Vélo’V), Marseille (Levélo), Mulhouse (Velocite), Nancy (Velostanlib), Nantes (Bicloo), Paris (Vélib), Rouen (Cyclic), Santander (Tusbic), Sevilla (Sevici), Stockholm (Cyclocity), Toulouse (Vélô), Toyama (Cyclocity), Valencia (Valenbisi), Vilnius (Cyclocity)

Notes:

- Use of the old “ webservices ” was ulimately tolerated by Cyclocity. Dublinbikes and Brisbane aren't available through the official API.
- AFAIK, all the services are still available on the old pseudo-API, which actually are hosted on the same servers for all the services.
- At least for Paris, official apps use [yet another service](http://blog.velib.paris.fr/blog/2012/12/17/des-stations-jusqua-votre-ecran-le-circuit-des-donnees-velib-2/).

These other services operated by Cyclocity are *not* available on developer.jcdecaux.com.

> - DublinBikes
>     - List: `http://www.dublinbikes.ie/service/carto`
>     - Details: `http://www.dublinbikes.ie/service/stationdetails/{city_name}/{station_id}`
> - Brisbane
>     - List: `http://www.citycycle.com.au/service/carto`
>     - Details: `http://www.citycycle.com.au/service/stationdetails/{city_name}/{station_id}`
> - Wien ([Terms of use](http://www.citybikewien.at/cms/dynimages/mb/files/Terms_of_Use_XML.pdf))
>     - `http://dynamisch.citybikewien.at/citybike_xml.php`

### Rennes
Operated by Keolis. Official opendata platform:

> `http://data.keolis-rennes.com/{xml,json}/?version=1.0&key={APIKEY}&cmd=getstation`
 
### Bordeaux
Operated by Keolis. Official opendata platform:

> -  `http://data.lacub.fr/wfs?key={APIKEY}&SERVICE=WFS&VERSION=1.1.0&REQUEST=GetFeature&TYPENAME=CI_VCUB_P&SRSNAME=EPSG:4326`

### Lille
Operated by Keolis. No official opendata policy, but usage of the webservice is tolerated.

> - List: `http://vlille.fr/stations/xml-stations.aspx`
> - Details: `http://vlille.fr/stations/xml-station.aspx?borne={station_id}`

### Orléans
Operated by Keolis. No official opendata policy.
 
> - List: `https://www.agglo-veloplus.fr/component/data_1.xml`
> - Details: `https://www.agglo-veloplus.fr/getStatusBorne?idBorne={station_id}`

### Veloway Systems (Veolia) 
No official opendata policy, but usage of the webservices is tolerated.

> - Calais (Vel-in) `http://www.vel-in.fr/cartoV2/libProxyCarto.asp`
> - Vannes (Vélocéa) `http://www.velocea.fr/cartoV2/libProxyCarto.asp``
> - Nice (Vélobleu) `http://www.velobleu.org/cartoV2/libProxyCarto.asp`

### Smoove Systems
No official Open Data Policy, but use of the webservices is explicitely tolerated by the operator.

> - Avignon: `http://www.velopop.fr/vcstations.xml`
> - Belfort: `http://cli-velo-belfort.gir.fr/vcstations.xml`
> - Chalon-sur-Saône: `http://www.reflex-grandchalon.fr/vcstations.xml`
> - Clermont-Ferrand: `http://www.c-velo.fr/vcstations.xml`
> - Grenoble: `http://vms.metrovelo.fr/vcstations.xml`
> - Lorient: `http://www.lorient-velo.fr/vcstations.xml`
> - Montpellier  `http://cli-velo-montpellier.gir.fr/vcstations.xml`
> - Saint-Étienne: `http://www.velivert.fr/vcstations.xml`
> - Strasbourg: `http://www.velhop.strasbourg.eu/vcstations.xml`
> - Valence: `http://www.velo-libelo.fr/vcstations.xml`

### La Rochelle
No Webservice: HTML Scraping.

> - `http://yelo.agglo-larochelle.fr/stations?address=&velos=true`

### Barcelona Citybike
Official opendata webservice. (http://opendata.bcn.cat/opendata/cataleg/TRANSPORT/bicing/#)
> - `http://wservice.viabicing.cat/getstations.php?v=1

### Swiss - PubliBike Systems
Acquired Vélopass in 2013. No official OpenData policy, but use of the webservices is tolerated by the operator.

> Agglo Fribourg, Basel, Bern, Brig, Bulle, Chablais, Delémont, Frauenfeld, Kreuzlingen, La Côte, Lausanne, Les Lacs - Romont, Lugano, Luzern, Rapperswil, Sion, Solothurn, Vevey-Riviera, Yverdon-les-Bains, Zürich

> - `http://customers2011.ssmservice.ch/publibike/getterminals_v2.php`

### NextBike
Official webservices available upon request to it@nextbike.net

75 cities worldwide, mostly Germany and Eastern europe.:
> **NextBike** : 10vorWien, Auckland, Augsburg, Baku, Berlin, Bielefeld, Bregenzerwald, Burghausen, Christchurch, Coburg, Dresden, Dubai, Düsseldorf, Erfurt, Flensburg, Frankfurt, Gütersloh, Haag, Hamburg, Hannover, Konya, Krems, Laa, Leipzig, Limassol, Luzern, Magdeburg, Marchfeld, Mistelbach, Mödling, München, Neunkirchen, NeusiedlerSee,. Norderstedt, Nürnberg, Oberes, Offenburg, Opole, Piestingtal, Potsdam, Poznan, Salzburg, St.Pölten, Südheide, Thermenregion, Traisen-Gölsental, Triestingtal, Tulln, Tübingen, Unteres, Wachau, Waldviertel, Wieselburg, Wr.Neustadt, Wrocław, İzmir.
> **BalticBike** : Riga, Jurmala.
> **Metropolradruhr** : Duisburg, Dortmund, Hamm, Oberhausen, Bottrop, Gelsenkirche, Mülheim, Bochum, Essen, Herne.
> **Veturilo** : Warszawa

### London Boris bikes
Based on BIXI. Official webservices.

> -`http://www.tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml`

### BIXI Canada
Official Opendata webservices. (All the services are hosted on the same servers.)
> - Toronto: `https://toronto.bixi.com/data/bikeStations.xml`
> - Montréal: `https://montreal.bixi.com/data/bikeStations.xml`
> - Ottawa: `https://capitale.bixi.com/data/bikeStations.xml`

### Boston (Hubway)
Official opendata webservice (http://hubwaydatachallenge.org)
> - `http://www.thehubway.com/data/stations/bikeStations.xml`

### Chattanooga (Bike Chattanooga)
Based on BIXI. Unknown Terms of Use.
> - `http://www.bikechattanooga.com/stations/json`

### Chicago (Divvy Bikes)
Official opendata webservice.
> - `http://divvybikes.com/stations/json`

### Columbus (COGO)
Unknown Terms of Use.

> - `http://cogobikeshare.com/stations/json`

### DECOBIKE Systems
Unknown Terms of Use.

> - Miami/Surfside `http://www.decobike.com/playmoves.xml`
> - Long beach New York `http://decobikelbny.com/playmoves.xml`

### Minneapolis (Nice Ride)
Based on BIXI. Unknown Terms of Use.

> - `https://secure.niceridemn.org/data2/bikeStations.xml`

### New York City (Citibike)
Based on BIXI. Official opendata webservice (http://www.citibikenyc.com/system-data)
> - `http://citibikenyc.com/stations/json`

### San Francisco Bay Area (Bay Area Bike Share)
Official opendata webservice.
> - `http://www.bayareabikeshare.com/stations/json`

### Washington (Capital Bike Share)
Based on BIXI. Authorized webservices.

> - `http://capitalbikeshare.com/data/stations/bikeStations.xml`

### Melbourne
Based on BIXI. Official opendata webservice.
> - `http://www.melbournebikeshare.com.au/stationmap/data`

---

## Services Not Availables in Bicyclette

(yet)

I managed to grab info of these other services some time ago, so this may not be accurate or up-to-date. [Get in touch](mailto:contact@bicyclette-app.com) if you have more info.

### Bicincitta / TOBike

The Torino and Bicincitta networks, used in many cities in Italy. Various versions of the services. The service.tobike.it backend is actually also used for Velopass in Swiss.

List of cities : http://www.bicincitta.com/comuni.asp

- List 1 (~20 cities) : Dirty HTML/javascript.http://bicincitta.tobike.it/frmLeStazioni.aspx?ID={city_id}
- List 2 (Torino+Region) : Dirty HTML/javascript.http://www.tobike.it/frmLeStazioni.aspx?ID={city_id}
- List 3 (Brescia) : Dirty HTML/javascript.http://service.bicimia.it/frmComuniAderentiInfo.aspx
- List 4 (http://www.bicincittabip.com/frmLeStazioni.aspx?ID=112
- Roma (older? similar to Pamplona) : http://www.bicincitta.com/citta_v3.asp?id=18&pag=2

Webservices
http://service.tobike.it


### Keolis
Managed by Keolis. No webservices.

> - List (HTML) : `http://www.tul-laval.fr/velitul-stations.asp`
> - Status of stations (HTML) : `http://www.tul-laval.fr/velitul-disponibilites.asp`

### Pau
Managed by Keolis. No webservices.

> - List+Details (HTML) : `http://www.idecycle.com/stations/plan`

### Domoblue (Spain)

Call http://clientes.domoblue.es/onroll/generaMapa.php?cliente={city_id} to get the list of cities, it returns html to parse to get a token; then call 
http://clientes.domoblue.es/onroll/generaXml.php?token=806182692&cliente={id}, which returns the List+Details xml.

Use "todos" as the `city_id` to get individual city ids instead of stations.

> A Rua, Albacete, Alhama de Murcia, Almuñecar, Antequera, Aranda de Duero, Aranjuez, Badajoz, Baeza, Benidorm, Blanca, Cieza, Ciudad Real, Don Benito - Villanueva, El Campello, Elche, Guadalajara, Jaen, JavierPruebas, Lalin, Las Palmas, Montilla, Mula, Novelda, O Barco, Paiporta, Palencia, Pinto, Priego de Cordoba, Puerto Lumbreras, Puertollano, Redondela, Salamanca, San Javier, San Pedro, Sant Joan, Segovia, Soria, Talavera, Ubeda, Universidad de Granada, Via Verde, Vigo, Villaquilambre, Villarreal, Vinaros.
 
### Bysykkel (Norway)
Operated by Clear Channel. Unknown Terms of Use.

> Oslo, Drammen, Trondheim.

> - Website : http://www.bysykler.no
> - List : http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRacks, 
> - Details : http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack (via POST. see wsdl spec at http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx)

This service also contains station info for Drammen. Trondheim seems to be missing as of 2013-03-18.

### Palma de Mallorca
Unknown Terms of Use

> - Website : http://bicipalma.palmademallorca.es
> - List+Details. http://83.36.51.60:8080/eTraffic3/Control?act=mp for the cookie, then http://83.36.51.60:8080/eTraffic3/DataServer?ele=equ&type=401&li=2.6265907287598&ld=2.6799774169922&ln=39.590768389513&ls=39.558367304613&zoom=15&adm=N&mapId=1&lang=es for the JSON.

### Stockholm City Bikes
Operated by Clear Channel Sverige. Unknown Terms of Use.

The [official website](http://www.citybikes.se/en/Here-are-our-cycle-stands/) uses data from https://bikemap.appified.net, who also made the iphone app. There's a very aggressive refresh limit on the webservice. (it returns a 403 after 10 reloads.)

> - List : https://bikemap.appified.net/a/grs/
> - Details : https://bikemap.appified.net/a/gr/0c59508f792a57b5cee3231940890270/{station_id}

### Forever Bicycle/China RMB
1000+ stations in Shangai and region, Chengdu and region, Shenyang, Nanshan (near Shenzhen).

No webservices. HTML is relatively clean.
> - List : http://self.chinarmb.com/FormStations.aspx
> - Details : http://self.chinarmb.com/stationinfo.aspx?snumber=001001009027
> - Webpage : http://www.chinarmb.com/page.aspx?id=713307143965

### Kyoto Machikado Minaport
No webservices. HTML is relatively clean.

> - Webpage : http://minaport.ubweb.jp/station.html
> - List+Details : http://minaport.ubweb.jp/stations.php


### Yokohama Baybike
Operated by Docomo Cycle. Unknown Terms of Use
> - List+Details (json) : http://docomo-cycle.jp/yokohama/map/getports/

### Daejeon (South Korea) Ta-Shu
Unknown Terms of Use. Contact email actually invalid.
> - List+Details (json) : http://www.tashu.or.kr/mapAction.do?process=statusMapView

### Kaohsiung (Taiwan) C-Bike
Unknown Terms of Use, no contact email found.

> - List+Details (HTML, but relatively clean) : http://www.c-bike.com.tw/english/MapStation1.aspx
> - iPhone app available, https://itunes.apple.com/app/id492069747?mt=8
> - URLs from iPhone app : 
>  - `http://www.c-bike.com.tw/xml/TutorialVideo.xml`
>  - `http://www.c-bike.com.tw/xml/MRT.xml`
>  - `http://www.c-bike.com.tw/xml/Bus.xml`
>  - `http://www.c-bike.com.tw/xml/InspectionStation.xml`
>  - `http://www.c-bike.com.tw/xml/ChargingStation.xml`
>  - `http://www.c-bike.com.tw/xml/viewslist.aspx?tid=1`
>  - `http://www.c-bike.com.tw/xml/viewslist.aspx?tid=2`
>  - `http://www.c-bike.com.tw/xml/viewslist.aspx?tid=3`
>  - `http://www.c-bike.com.tw/xml/viewslist.aspx?tid=4`
>  - `http://www.c-bike.com.tw/xml/iosstationlist.aspx`

### TaiPen (Taiwan) YouBike
OpenData policy available at http://data.taipei.gov.tw/opendata/
> - List+Details (JSON) : `http://its.taipei.gov.tw/atis_index/data/youbike/youbike.json`

### Nicosia (Cyprus)
Unknown Terms of Use

> HTML Scraping, reasonable.
> - List+Details `http://www.podilatoendrasi.com.cy/frontoffice/bike_routes.html`

### Bucharest (Cicloteque)
Unknown Terms of Use

> HTML parsing, reasonable.
> - List+Details : http://www.cicloteque.ro/retea/

---

## No plans to include in Bicyclette

(Because the HTML is way too dirty to scrape.)

### BikeNation (USA)

*Unknown Terms of Use*

Bikenation seems to be working on networks in Los Angeles and Long Beach (California) as well.

- Anaheim: List (no details) http://www.bikenationusa.com/services/API/Maps.asmx/GetLocations (POST {"locationId":"Anaheim"})

### Mobilicidata
HTML Scraping needed. Also try to reverse engineer the iphone app.

- **Sao Paulo** (List+Details) : http://ww2.mobilicidade.com.br/bikesampa/mapaestacao.asp
- **Rio** (List+Details) : http://ww2.mobilicidade.com.br/sambarjpt/mapaestacao.asp
- **Soracaba** (List+Details) : http://ww2.mobilicidade.com.br/sorocaba/mapaestacao.asp
- **Porto Alegre** (List+Details) : http://ww2.mobilicidade.com.br/bikepoa/mapaestacao.asp
- **Recife** (List+Details) : http://www.portoleve.org
- **Santos** (List+Details) : http://ww2.mobilicidade.com.br/bikesantos/mapaestacao.asp


### CityBike (aka Clear Channel) 1
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

### CityBike (aka Clear Channel) 2
Way too dirty to scrape. A new webservice is being created with the other Bysykkel networks. (see above)

* **Drammen** (List+Details) : `http://drammen.clearchannel.com/stationsmap`

* calls through an xmlhttprequest : 
 
    curl -X POST -H "Cache-Control: max-age=0" -H "Content-Length: 0" -H "Cookie: ASP.NET_SessionId=55i5wltwt2nj5llwwqxowj4t" -H "Content-Type: application/json; charset=UTF-8" http://drammen.clearchannel.com/WS/GService.asmx/GetGoogleObject

### CityBike (aka Clear Channel) 3
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
	
### Bicileon

HTML Scraping needed, and no lat/long info.

* List and status : http://bicileon.com/estado/EstadoActual.asp

### Guadalajara, Mexico (Bikla)

HTML, dirty.

* List and status : http://www.bikla.net/index.php?Op=mapa

### Girona, Spain (Girocleta)

HTML/javascript. Hard to parse.

* list and stations : http://www.girocleta.cat/Mapadestacions.aspx

### Buenos Aires (bicicletapublica)

HTML/javascript
* List+Details : http://www.bicicletapublica.com.ar/mapa.aspx

### Tel-Aviv (Tel-O-Fun)

HTML both in list and details.

* List : https://www.tel-o-fun.co.il/en/TelOFunLocations.aspx
* Details : (separate request)

### Changwon (South Korea) NUBIJA

(Dirty HTML,javascript scraping needed)

* List+Details : http://nubija.changwon.go.kr/stn/stationState.do

### Fremantle (Australia) 

Planned.

* http://www.cyclefreo.com/the-plan/locations/

### OV-Velos (Netherlands)

* http://www.ov-fiets.nl/ovfiets
Map available, but could not find availability info. Not sure it makes sense.

### Newcastle (Scratchbike)

* List+Details (html) http://www.scratchbikes.co.uk/ (dirtiest pseudo-json ever.)

### Pamplona

* Flash map available at : http://195.88.6.82/08b_nbici/citta.asp?id=1000&pag=2
* Data (List and details) requested from : http://195.88.6.82/08b_nbici/citta.asp?id=1000&pag=2

Station coordinates are in pixels.

---

## Data unavailable on the web

* Angers (only 1 station)
* Montélimar (only 1 station)

* Medellin (Colombia) : http://www.encicla.gov.co/index.php/en/maps-en


### Broken websites

* Toopedalando (Toledo, Brazil) http://www.toopedalando.com.br/. Down 2013-03-18.
* Hangzhou. webservices? at http://www.hzzxc.com.cn/map/data-xml.php. Down 2013-03-18.
* Hourbike (UK). Dumfries, Blackpool, Southport. Maps available at http://www.hourbike.com/mysitecaddy/site3/index.htm, but live feed looks broken (?)
