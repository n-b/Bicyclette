Une carte, juste une carte. Pas de conseils, de vidéos, de trucs.

Ultra-réactive : Bicyclette rafraichit en permanence le nombre de places et de vélos disponibles dans vos stations.

Pas de liste ou de favoris : créez des Zones Radars pour automatiquement être prévenu à l'approche de vos stations préférées.
L'application utilise le "geofencing" pour être automatiquement redémarrée en tâche de fond par votre iPhone, et vous donner un résumé des stations environnantes.

Notes sur le projet
===================

DataGrab
--------

Bicyclette préembarque une base de données avec la liste des stations. L'idée est de fonctionner tout de suite au premier lancement. 
Cette base est créée sur le mac de développement, par un outil associé, **BicycletteDataGrab**. Il doit être executé au moins une fois avant de lancer Bicyclette.

BicycletteDataGrab télécharge la liste des stations et la sauvegarde dans `_DataGrabTempFolder/VelibModel.sqlite`. Ce fichier fait partie des ressources de Bicyclette.

BicycletteDataGrab utilise exactement le même backend que Bicyclette. En fait, le seul code spécifique est la fonction `main()`.

Une fois installée, Bicyclette peut mettre à jour sa base elle-même.

Screenshots
-----------

Deux schemes supplémentaires servent à mécaniser (un tant soit peu) la prise de screenshot pour les Default.png et les captures pour le site web et l'Appstore.

HardcodedFixes
--------------

Debug Flags
-----------

Reusable code
-------------

* CoreDataManager
* DataUpdater
* Store
* KVCMapping