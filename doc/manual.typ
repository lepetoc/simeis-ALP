#let col-pink = rgb("#e34967")
#let col-blue = rgb("#6A82FB")

#set page(
  margin: (y: 40pt, left: 40pt, right: 20pt),
  numbering: "1 /1",
  number-align: right,
)
#set text(14pt)

#show raw: it => box(
    fill: rgb("#F0F0F0"),
    radius: 3pt,
    inset: 3pt,
    baseline: 3pt,
    text(fill: col-blue, size: 10pt, smallcaps(it))
  )
#show link: it => underline(text(weight: "medium", fill: col-pink, size: 13pt, it))
#show ref: it => {
  let el = it.element
  link(el.location())[#it]
}

#set heading(numbering: "1.")
#show heading.where(level: 1): it => block(width: 100%)[
  #v(20pt)
  #set align(left)
  #set text(25pt, fill: col-pink, weight: "bold")
  #h(-15pt)
  #smallcaps[#counter(heading).display() #it.body]
]
#show heading.where(level: 2): it => block(width: 100%)[
  #set align(left)
  #set text(18pt, weight: "bold")
  #h(-10pt)
  #smallcaps[#counter(heading).display() #it.body]
  #v(5pt)
]
// #show selector(heading.where(level: 1)) : set heading(numbering: none)

#show ref: it => underline(text(fill: col-pink, it))

#let descr(title, lbl, url, api, descr, errcond, footer: none) = block(breakable: false)[
  == #title
  #label(lbl)

  #descr

  #grid(columns: (80pt, 1fr), row-gutter: 8pt,
    [ - Endpoint:], [ #raw(url) ],
    [ - Client:], [ #raw("ApiClient::" + api) ],
  )

  #if errcond != none {
    [ Retournera une erreur si #errcond ]
  }
  #v(10pt)
  #if footer != none {
    footer
    v(10pt)
  }
]

#align(center, text(50pt, weight: "regular", smallcaps("Simeis")))

Simeis est un jeu par API (inspiré de #link("https://spacetraders.io/")[SpaceTraders]),
dont le but est de faire fructifier votre empire économique dans toute la galaxie.

Dans ce manuel, vous trouverez les mécaniques de base du jeu, c'est à vous de porter
ces mécaniques de bases vers l'excellence intergalactique !

#v(20pt)

Ce manuel contient les URL de l'API brute (en query GET standard), mais aussi la fonction
associée dans le fichier `api.rs` si vous travaillez en Rust.

#v(20pt)

Dans les descriptions des appels à l'API, il est admis que vous avez utilisé l'ID
attendu dans les arguments de la query GET, ainsi ce manuel ne couvrira pas les cas
d'erreurs où l'ID attendu n'est pas le bon

#pagebreak()
= Le Joueur <player>

#v(30pt)
== La structure de donnée `Player`

- `id`: L'ID du joueur
- `key`: La clé *privée* d'authentification du joueur sur le jeu
- `lost`: Si le joueur a déjà perdu
- `name`: Le nom de ce joueur
- `money`: Argent du joueur
- `costs`: Frais que le joueur perdra par secondes (salaires de l'équipage, voir @crew)
- `stations`: Coordonnées et ID de chacune des stations qu'un joueur possède
- `ships`: ID et données des vaisseaux qu'un joueur possède (voir @shipdata)

#v(20pt)
#descr("Créer un joueur", "creer_joueur", "/player/new/{name}", "new_player", [
    La création d'un joueur requiert un _nom unique_, qui vous donnera accès à un *ID* de
    joueur, ainsi qu'à une *clé* d'authentification unique.

    Pour intéragir avec ce joueur, tous les appels à l'API devront comporter un paramètre
    `key=<votre clé>` dans l'URL de votre query GET.
  ], "le nom du joueur existe déjà", footer: [
    À sa création, le joueur n'aura aucun vaisseau, et sera doté d'un montant fixe d'argent.

    Il sera propriétaire d'une station (@stations)
  ]
)

#descr("Obtenir des informations d'un joueur", "get_info_player", "/player/{id}", "get_player", [
  Les informations obtenues seront complètes s'il s'agit de votre joueur, ou partielles
  s'il s'agit d'un autre joueur.
], "le joueur avec l'ID correspondant n'existe pas", footer: [
  Les données retournées comprendront:
  - `id`: L'ID du joueur
  - `name`: Le nom du joueur
  - `stations`: Liste des coordonnées de toutes les stations que possède le joueur, mappées par leur IDs,

  Si la clé passée dans la query correspond à la clé du joueur, les données retournées comprendront aussi:
  - `ships`: Une liste des vaisseaux du joueur et leurs métadonnées
  - `money`: Combien d'argent a ce joueur
  - `costs`: Combien d'argent par second ce joueur perds en frais
])


#pagebreak()
= Les vaisseaux <ship>

== La structure de données `Ship` <shipdata>

- `id`: ID du vaisseau
- `position`: Coordonnées du vaisseau dans l'espace

*Caractéristiques du vaisseau*
- `reactor_power`: Puissance du moteur, détermine la vitesse du vaisseau
- `fuel_tank_capacity`: Contenance du réservoir de carburant
- `hull_decay_capacity`: Quantité d'usure que la coque peut subir avant destruction
- `modules`: Tous les modules du vaisseau et leur ID

*Cargo*
- `cargo.usage`: Volume utilisé par les resources à bord
- `cargo.capacity`: Volume total que peut contenir le cargo
- `cargo.resources`: Pour chaque resource contenue, quelle quantité est en stock

*État*
- `state`: Commande actuelle du vaisseau (en vol, extraction, inactif...)
- `fuel_tank`: Niveau de carburant restant, à `0` le vaisseau s'immobilisera
- `hull_decay`: Usure de la coque, à `hull_decay_capacity`, le vaisseau se détruira
- `stats`: Performances du vaisseau, calculées à partir des caractéristiques du vaisseau

*Équipage*
- `crew`: Équipage de ce vaisseau (voir @crew)
- `pilot`: ID du membre d'équipage assigné en tant que pilote de ce vaisseau

#descr("Obtenir de informations sur un vaisseau", "ship_status",
  "/ship/{ship_id}", "get_ship", [
    Récupère toutes les données d'un vaisseau (voir @shipdata)
  ], none
)

#descr("Lister les vaisseaux à l'achat", "list_ship_buy", "/station/{station_id}/shipyard/list", "list_shipyard_ships", [
  Retourne la liste de tous les vaisseaux pouvant être achetés dans une station, ainsi
  que leurs caractéristiques (voir @shipdata)
], none, footer: [
  Les données reçues, en plus des caractéristiques du vaisseau en question, contient le prix à
  payer pour ce vaisseau (clé `price`).
])


#descr("Acheter un vaisseau", "buy_ship", "/station/{station_id}/shipyard/buy/{ship_id}", "buy_ship", [
  Achète le vaisseau d'ID `ship_id` sur la station `station_id`
], "le prix est au dessus de vos moyens financiers",
  footer: [
    Le nouveau vaisseau aura pour position celle de la station, avec un plein de carburant
    et une coque toute neuve.

    *Attention*: Sans équipage, le vaisseau ne peut pas fonctionner (voir @crew)
  ]
)

#descr("Lister les modules de vaisseau à l'achat", "list_shop_ship_module",
  "/station/{station_id}/shop/modules", "list_shop_ship_module",
  [ Liste tous les modules de vaisseaux disponibles à l'achat dans cette station,
  ainsi que leur prix ], none
)

#descr("Acheter un module de vaisseau", "buy_ship_module",
  "/station/{station_id}/shop/modules/{ship_id}/buy/{module}", "buy_ship_module", [
    Achète un module de type `module` et l'installe sur le vaisseau `ship_id`

    Types de module possible:
    - `Miner`: Permet d'extraire des resources depuis les planètes solides
    - `GasSucker`: Permet d'extraire du gaz depuis les planète gaseuses
  ],
  "le type de module n'est pas reconnu, si le vaisseau n'est pas à la station, le prix est trop élevé"
)

#descr("Lister les améliorations de modules", "list_ship_module_upgrades",
  "/station/{station_id}/shop/modules/{ship_id}/upgrade", "list_ship_module_upgrade", [
    Retourne la liste de tous les modules installés sur le vaisseau et leur ID, type et
    le prix à payer pour augmenter leur rang.

    Chaque rang de module booste son efficacité, et permet d'extraire des resources
    nécessitant un rang élevé
  ], "le vaisseau n'est pas à la station"
)

#descr("Acheter une amélioration de module", "buy_ship_module_upgrade",
  "/station/{station_id}/shop/modules/{ship_id}/upgrade/{module}",
  "buy_ship_module_upgrade", [
    Achète une amélioration de l'un des modules installés sur le vaisseau
  ], "le prix est élevé pour vos moyens, ou le vaisseau n'est pas à la station"
)

#descr("Extraire des resources", "start_extraction",
  "/ship/{ship_id}/extraction/start", "start_extraction", [
    *Attention*: Votre vaisseau doit être positionné à la même coordonée qu'une planète
    pour lancer une extraction de resources.

    En fonction des resources disponibles sur la planète (solide ou gazeuse), utilisera
    les modules du vaisseau installé pour extraire des resources.

    Le montant de resources obtenues dépendent de:
    - La richesse de cette planète en cette resource
    - La difficulté d'extraction de cette resource
    - Le rang de votre opérateur
    - Le rang de votre module d'extraction

    Le vaisseau extraiera des resources jusqu'à ce que son cargo soit totalement plein. \
    Une fois le cargo plein, le vaisseau retrouvera un `state` inactif (`Idle`)

    L'appel à cet endpoint retournera, pour chacune des resources extraites,
    la quantité extraite par seconde.

    *Attention*: Un module n'ayant pas d'opérateur assigné ne produira rien.
], "le vaisseau est déjà occupé ou n'est pas positionné sur une planète", footer: [
  Les planètes *solides*, nécessitant un module `Miner` possèdent les resources:
  - `Stone`, de la pierre, peu chère mais facile à extraire
  - `Iron`, du fer, plus cher mais plus rare et difficile à extraire

  Les planètes *gazeuses*, nécessitant un module `GasSucker` possèdent les resources:
  - `Helium`, peu cher et simple à extraire
  - `Ozone`, plus cher mais plus rare et difficile à extraire
])

#descr("Arrêter l'extraction", "stop_extraction",
  "/ship/{ship_id}/extraction/stop", "stop_extraction", [
    Arrête l'extraction en cours, restaure l'état du vaisseau à `Idle` (inactif)
  ], "le vaisseau n'était pas en train d'extraire"
)

#pagebreak()
= Stations <stations>

  == La structure de données `Station` <stationdata>

  - `id`: L'ID de la station
  - `position`: Coordonnées de la station dans l'espace
  - `shipyard`: Liste des vaisseaux à l'achat sur cette station

  *Cargo*
  - `cargo.usage`: Volume utilisé par les resources à bord
  - `cargo.capacity`: Volume total que peut contenir le cargo
  - `cargo.resources`: Pour chaque resource contenue, quelle quantité est en stock

  *Équipage*
  - `idle_crew`: Équipage inactif de cette station (voir @crew)
  - `crew`: Équipage de cette station (voir @crew)
  - `trader`: ID du membre d'équipage assigné en tant que Trader

#descr("Obtenir le status de la station", "station_status",
  "/station/{station_id}", "get_station_status", [
    Retourne les données de la station (voir @stationdata pour le détail)
    - `id`
    - `position`
    - `crew`
    - `idle_crew`
    - `cargo`
    - `trader`
], none)

#descr("Faire le plein de carburant", "refuel", "/station/{station_id}/refuel/{ship_id}",
  "refuel_ship", [
    Transfert du carburant (`Resource::Fuel`) depuis le *cargo de la station* vers le
    réservoir de carburant du vaisseau.

    *Attention*: Cette opération nécessite d'avoir du carburant de stocké dans le cargo
    de la station. Voir @buy_resources pour savoir comment acheter du carburant
  ], "il n'y a pas de carburant dans le cargo de la station", footer: [
    Ce endpoint retourne quelle quantité de carburant a été ajoutée au réservoir du
    vaisseau.
  ]
)

#descr("Réparer la coque du vaisseau", "repair", "/station/{station_id}/repair/{ship_id}",
  "repair_ship", [
    Utilise des plaques de réparation (`Resource::HullPlate`) depuis le *cargo de la station*
    pour diminuer l'usure de la coque du vaisseau (Voir `hull_decay` à @ship)
  ], "il n'y a pas de plaques de réparations dans le cargo de la station", footer: [
    Ce endpoint retourne de combien d'unités l'usure du vaisseau a été restaurée
  ]
)

#descr("Décharger un vaisseau", "unload",
  "/ship/{ship_id}/unload/{resource}/{amnt}", "unload_cargo", [
    Retire du cargo du vaisseau une quantité `amnt` de la resource `resource`, et la
    place dans le cargo de la station où le vaisseau est stationné.

    Si le vaisseau n'a pas autant de quantité, déchargera le maximum

    Si la station n'a pas assez de place pour accueillir les resources,
    en chargera un maximum et replacera le reste dans le cargo du vaisseau

    L'appel à cet endpoint retournera la quantité de resource qui a été déchargée
], "le vaisseau n'est pas dans une station")

#descr("Lister le prix des améliorations de vaisseau", "upgr_ship_price", "/station/{station_id}/shipyard/upgrade", "list_ship_upgrades", [
  Retourne la liste de toutes les améliorations possibles sur les vaisseaux sur cette
  station, ainsi que leur prix.
], none, footer: [
  Chacune des amélioration aura son prix (clé `price`) et une description (clé `description`)
])

#descr("Améliorer le vaisseau", "ship_upgr", "/station/{station_id}/shipyard/upgrade/{ship_id}/{upgrade_type}", "buy_ship_upgrade", [
  Achète une amélioration de type `upgrade_type` sur le vaisseau `ship_id` s'il est stationné sur la station `station_id`
], "le type  d'upgrade n'est pas reconnu, le vaisseau n'est pas sur la station, ou le joueur n'a pas assez d'argent pour acheter cet upgrade")

#descr("Lister les améliorations de la station", "station_upgr",
  "/station/{station_id}/upgrades", "get_station_upgrade_price", [

    Retourne le prix à payer pour chaque amélioration de la station:
    - `cargo-expansion`: Prix par extension de cargo (voir @buy_cargo_exp)
    - `trader-upgrade`: Prix pour augmenter le rang du trader (voir @upgrade_trader)

    *Attention* La fonction de `ApiClient` nécessite de passer un paramètre `key`
    correspondant au type d'amélioration à avoir
  ], none,
)

#descr("Acheter une extension de cargo à la station", "buy_cargo_exp",
  "/station/{station_id}/shop/cargo/buy/{amount}", "buy_station_cargo", [
    Améliore le cargo de la station en y ajoutant une quantité `amount` de capacité
    de cargo.

    Le prix augmentera à chaque extension achetée
  ], "vous n'avez pas assez d'argent",
)

#descr("Scanner les planètes aux alentours", "station_scan", "/station/{station_id}/scan", "station_scan", [
  Scanne tous les objets dans ce secteur de la galaxie, et retourne leur liste:
  - Planètes
  - Stations

  Peut être utilisé pour obtenir la position d'une planète à aller exploiter, ses
  caractéristiques (si elle est _solide_ ou _gazeuse_, voir @start_extraction)
], none)

#pagebreak()
= Équipage <crew>

== La structure de donnée `CrewMember`

- `rank`: Rang de l'équipier, ses performances dépenderont de ce niveau (voir @upgrade_crew)
- `member_type`: Quel type d'équipage ce membre fait partie
  - `CrewMemberType::Pilot`: Pilote de vaisseau (voir @assign_pilot et @shipdata)
  - `CrewMemberType::Operator`: Opérateur de module (voir @assign_operator et @shipdata)
  - `CrewMemberType::Trader`: Trader sur la station (voir @assign_trader et @stationdata)
  - `CrewMemberType::Soldier`: Soldat (développement en cours)

#descr("Engager un membre d'équipage", "hire_crew", "/station/{station_id}/crew/hire/{crew_type}",  "hire_crew", [
  Engager un nouveau member d'équipage, qui rejoindra la station en status *inactif* (voir @station_status)

  Les types de membres incluent:
  - `pilot`: Permet de déplacer un vaisseau à travers la galaxie
  - `operator`: Permet d'utiliser un module d'extraction de resource sur un vaisseau
  - `trader`: Permet d'acheter ou vendre des resources dans une station (voir @sell_resources)

  Chaque membre d'équipage pourra ensuite être améliorer (voir @upgrade_crew)
], "le type de member n'est pas reconnu", footer: [
  L'ID du membre de l'équipage sera retourné.
])

#descr("Assigner un trader", "assign_trader", "/station/{station_id}/crew/assign/{crew_id}/trading", "assign_trader", [
  Assigne un trader à une station, permet alors d'utiliser les fonctionalités d'achat
  et de vente de resources (voir @sell_resources et @buy_resources)

  Les frais appliqués à chaque transaction dépenderont du rang du trader
], "un trader est déjà assigné, le membre d'équipage n'est pas inactif ou n'est pas un trader")

#descr("Assigner un pilote", "assign_pilot", "/station/{station_id}/crew/assign/{crew_id}/{ship_id}/pilot", "assign_pilot", [
  Assigne un membre d'équipage (de type pilote) inactif en tant que pilote (voir @shipdata).

  La vitesse du vaisseau, ainsi que la consommation de carburant dépenderont du rang du
  pilote
], "le vaisseau n'est pas sur la station, un pilote est déjà assigné, le membre d'équipage n'est pas inactif ou n'est pas un pilote")

#descr("Assigner un opérateur", "assign_operator", "/station/{station_id}/crew/assign/{crew_id}/{ship_id}/{mod_id}", "assign_operator", [
  Assigne un opérateur sur l'un des modules d'un vaisseau.

  Ce module pourra alors fonctionner lorsqu'il sera activé, et ses performances dépenderont
  du rang de l'opérateur
], "le vaisseau n'est pas sur la station, un opérateur est déjà assigné à ce module, le membre d'équipage n'est pas inactif ou n'est pas un opérateur")

#descr("Lister les améliorations de l'équipage", "list_crew_upgr",
  "/station/{station_id}/crew/upgrade/ship/{ship_id}", "get_crew_upgrades", [
    L'appel à cet endpoint retourne, pour chaque membre d'équipage du vaisseau, le rang
    suivant et le prix pour l'atteindre
], "le vaisseau n'est pas à une station")

#descr("Augmenter le rang d'un membre d'équipage", "upgrade_crew",
  "/station/{station_id}/crew/upgrade/ship/{ship_id}/{crew_id}", "buy_crew_upgrade", [
    Améliore le rang du membre `crew_id` de l'équipage. \
    Ses performances, mais aussi son salaire, seront beaucoup augmentés.

    Selon le type de membre, cela aura différents effets:
    - `Pilot`: Réduis la consommation de carburant, augmente la vitesse
    - `Opérator`: Augmente la quantité de resources extraites, débloque certaines resources
    - `Trader`: Réduis les frais de trading (voir @upgrade_trader)
  ], "le vaisseau n'est pas dans une station ou vous n'avez pas assez d'argent"
)

#descr("Augmenter le rang du trader d'une station", "upgrade_trader",
  "/station/{station_id}/crew/upgrade/trader", "upgrade_trader", [
    Améliore le rang du `trader` assigné à une station. \
    Voir @upgrade_crew pour comprendre les effets
  ], "aucun trader n'est assigné à cette station ou vous n'avez pas assez d'argent"
)

#pagebreak()
= Navigation <nav>

#descr("Calculer les coût d'un voyage", "travel_cost",
  "/ship/{ship_id}/travelcost/{x}/{y}/{z}", "travel_cost", [
    Calcule le coût d'un voyage vers les coordonnées `(x, y, z)` depuis la position du
    vaisseau

    Les données retournées du calcul comprendront:
    - `direction`: Vecteur de direction du vaisseau dans l'espace
    - `distance`: Distance totale du voyage
    - `duration`: Temps (en secondes) du voyage
    - `fuel_consumption`: Consommation de carburant qu'un tel voyage nécessite
    - `hull_usage`: Usure de la coque d'un tel voyage
  ], "aucun pilote n'est assigné au vaisseau ou la distance est nulle", footer: [
    *Attention*: Toujours penser au retour lorsque vous prévoyez un voyage
  ]
)

#descr("Voyager", "navigate", "/ship/{ship_id}/navigate/{x}/{y}/{z}", "navigate", [
  Envoie le vaisseau voyager vers `(x, y, z)`.

  Son `state` devient alors `InFlight`, et vous ne pouvez plus le commander jusqu'à
  son arrivée.

  L'appel à cet endpoint retourne les coûts du voyage (voir @travel_cost)
], "aucun pilote n'est assigné au vaisseau, la distance est nulle ou les coûts trop élevés (pas assez de carburant...)")

#pagebreak()
= Le marché <market>

Chaque resource a un prix de base, qui évolue au fil du temps.

L'évolution s'effectue de manière aléatoire, mais est conçue pour être légèrement biaisée
pour finalement retourner vers le prix de base.

En revanche le joueur _vends_, le prix baisse, lorsque le joueur _achète_, le prix augmente

Ces variations de prix peuvent être exploitées pour engendrer des bénéfices, mais
*chaque opérations sur le marché engendrera des frais*.

Le montant de ces frais dépenderont du rang de votre trader assigné.

Chaque transaction retourne une donnée `MarketTx` comprenant:
- `added_cargo`: Quelle quantité de quelle resource a été ajoutée au cargo de la station
- `removed_cargo`: Quelle quantité de quelle resource a été retirée du cargo de la station
- `added_money`: Combien d'argent a été ajouté au joueur
- `removed_money`: Combien d'argent a été retiré au joueur
- `fees`: Combien d'argent a été soustrait lors de la transaction

#descr("Lister les prix des resources", "market_price",
  "/market/prices", "resource_prices", [
    Retourne, pour chacune des resources, le prix actuel de cette resource sur le marché
  ], none
)

#descr("Obtenir le pourcentage de frais", "fee_rate",
  "/market/{station_id}/fee_rate", "get_fee_rate", [
    En fonction du rang du trader assigné à cette station, retourne le montant de frais
    (en pourcentage) qui sera appliqué à chacune des transactions.
  ], "aucun trader n'est assigné à cette station"
)

#descr("Acheter des resources", "buy_resources",
  "/market/{station_id}/buy/{resource}/{amnt}", "buy_resource", [
    Achète une quantité `amnt` de resources sur le marché, et les place dans le cargo
    de la station où la transaction est effectuée.
], "aucun trader n'est assigné à la station ou la quantité demandée est nulle")

#descr("Vendre des resources", "sell_resources",
  "/market/{station_id}/sell/{resource}/{amnt}", "sell_resource", [
    Décharge une quantité `amnt` de resources depuis le cargo de la station où la
    transaction est effectuée, et les vends sur le marché.

    Vends une quantité `amnt` de resources sur le marché, et les place dans le cargo
    de la station où la transaction est effectuée.
], "aucun trader n'est assigné à la station, la quantité demandée est nulle ou la quantité de cette resource dans le cargo est nulle")

#pagebreak()
= Système <system>

#descr("Tester la connectivité", "ping", "/ping", "ping", [
  Permet de tester que la connection avec le serveur distant fonctionne bien.

  Ne nécessite pas de clé de joueur pour être appelée.

  En cas de succès, retournera `{"ping": "pong"}`
], none)

#descr("Récupérer les logs du système", "syslog", "/syslogs", "get_syslogs", [
  Lorsque le jeu réalise une action automatiquement, ou si une alerte est lancée,
  cela sera visible dans les logs associés au joueur.

  Ainsi, les logs montreront lorsque:
  - Le jeu a commencé pour ce joueur
  - Le joueur a perdu
  - Un vaisseau a atteint sa destination
  - Un vaisseau a arrêté d'extraire des resources car son cargo est plein
  - Un vaisseau a été détruit

  Et produiront des alertes lorsque:
  - Le déchargement des resources d'un vaisseau n'est pas possible (voir @unload)
  - Il ne reste que 60 secondes avant que les frais n'épuisent les réserves d'argent
], none)

// TODO IMPORTANT  Add the /resources endpoint
