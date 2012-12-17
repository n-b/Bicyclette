# Reference

* [The Bike-sharing World Map](https://maps.google.com/maps/ms?ie=UTF8&oe=UTF8&msa=0&msid=214135271590990954041.00043d80f9456b3416ced)
* [List of bicycle sharing systems](http://en.wikipedia.org/wiki/List_of_bicycle_sharing_systems)
* [Liste des systèmes de vélos en libre-service en France](http://fr.wikipedia.org/wiki/Liste_des_systèmes_de_vélos_en_libre-service_en_France)


# Single Request for Stations List and Status

## Licenced Webservices

* Wien : http://dynamisch.citybikewien.at/citybike_xml.php / http://www.citybikewien.at/cms/dynimages/mb/files/Terms_of_Use_XML.pdf

## Real Webservices

* Bixi
    * Toronto: https://toronto.bixi.com/maps/statajax, https://toronto.bixi.com/data/bikeStations.xml
    * Montréal : https://montreal.bixi.com/maps/statajax, https://montreal.bixi.com/data/bikeStations.xml
    * Ottawa : https://capitale.bixi.com/data/bikeStations.xml
    * Washington : https://capitale.bixi.com/data/bikeStations.xml
    * London : http://www.tfl.gov.uk/tfl/syndication/feeds/cycle-hire/livecyclehireupdates.xml
    * Minneapolis : https://secure.niceridemn.org/data2/bikeStations.xml 
* Nextbike
    * 75 cities worldwide, mostly Germany and Eastern europe : http://www.nextbike.de/maps/nextbike-official.xml?city={uid}
* Veloway (Veolia)
    * Calais : http://www.vel-in.fr/cartoV2/libProxyCarto.asp
    * Nice : http://www.velobleu.org/cartoV2/libProxyCarto.asp
    * Vannes : http://www.velocea.fr/cartoV2/libProxyCarto.asp
* OYBike
    * Reading & Cardiff : http://www.oybike.com/oybike/stands.nsf/getSite?openagent&site=reading&format=json&cache=no&extended=yes&key=7A407C7C8DD673BD9A635ECFAB612C95
* [TO]bike
    * Torino : service.tobike.it (WSDL spec)
    * velopass (CH) : service.tobike.it
* BCycle
    * A dozen of US cities, with relatively small coverage. http://api.bcycle.com/services/mobile.svc/ListKiosks (Unfortunately, both the data and the ws suck. See http://api.bcycle.com/services/mobile.svc?wsdl)
* Melbourne : http://www.melbournebikeshare.com.au/stationmap/data
* Miami beach : Decobike : http://www.decobike.com/playmoves.xml
* Montpellier : http://cli-velo-montpellier.gir.fr/vcstations.xml
* Barcelona : https://www.bicing.cat/localizaciones/getJsonObject.php
* Chattanooga : http://www.bikechattanooga.com/stations/json

## HTML parsing
* Custom
    * La Rochelle : http://www.rtcr.fr/ct_93_297__Carte_du_libre_service_velos.html
    * Torino : http://www.tobike.it/frmLeStazioni.aspx
    * Laval : http://www.tul-laval.fr/velitul-disponibilites.asp, http://www.tul-laval.fr/velitul-stations.asp
* Smoove
    * Saint Etienne : http://www.velivert.fr/sag_vls_stations.html
    * Avignon : http://www.velopop.fr/stations.html
    * Strasbourg (pas les dispos de bornes) : http://www.velhop.strasbourg.eu/sag_vls_stations.html
    * Valence : http://www.velo-libelo.fr/sag_stations_vls.html
    * Grenoble : http://vms.metrovelo.fr/sag_location_carte.html
* CityBike (aka Clear Channel), dirty KML in HTML :
    * Caen : https://www.veol.caen.fr/localizaciones/localizaciones.php
    * Dijon : https://www.velodi.net/localizaciones/localizaciones.php
    * Perpignan : https://www.bip-perpignan.fr/localizaciones/localizaciones.php
    * Milano : http://www.bikemi.com/localizaciones/localizaciones.php
    * Drammen : http://drammen.clearchannel.com/stationsmap
* Drupal Dirty HTML
    * Bordeaux : http://www.vcub.fr/stations/plan
    * Pau : http://www.idecycle.com/stations/plan
    * Lille : http://vlille.fr/stations/les-stations-vlille.aspx
* Mobilicidata
    * Sao Paulo : http://ww2.mobilicidade.com.br/bikesampa/mapaestacao.asp
    * Rio : http://ww2.mobilicidade.com.br/sambarjpt/mapaestacao.asp
* Call-a-bike (DE)
    * (Géré par la DB, système à l'ancienne)

# Separate requests for Station Details
* CityBike (aka Clear Channel) With "BusinessStatus"
    * Mexico City : 
        * https://www.ecobici.df.gob.mx/localizaciones/localizaciones.php
        * curl -F "idStation=27" https://www.ecobici.df.gob.mx/CallWebService/StationBussinesStatus.php
    * Zaragoza
        * https://www.bizizaragoza.com/localizaciones/station_map.php
        * curl -F "idStation=27" https://www.bizizaragoza.com/CallWebService/StationBussinesStatus.php
* Oslo
    * http://www.adshel.no/js/
    * http://www.adshel.no/js/getracknr.php?id=34
* NYC (tentative)
    * http://a841-tfpweb.nyc.gov/bikeshare/get_tentative_bikeshare_points
    * http://a841-tfpweb.nyc.gov/bikeshare/get_point_info?point=13897

# Data unavailable on the web
* Chalon (Reflex)
* Angers - Vélocité+
