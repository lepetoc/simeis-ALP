# Simeis

Jeu à la Spacetrader API

Serveur web avec endpoints API (sans DB dans un premier temps)

Les joueurs doivent:
- créer un profil
- hire du personnel (pilote, trader, équipage, diplomate)
- acheter du matériel (vaisseau, transporteur personnel, extracteur, améliorations)
- commander un vaisseau (voyager vers telle destination, attaquer tel vaisseau, extraire, etc...)

Aucun client, ils doivent le programmer eux-même

### Station spatiale

Là où l'achat et la vente se produisent

Base opérationnelle de notre agent

On peut capturer la base des autres:
- Soit si ils ont perdu (et donc leur base est inoccupée)
- Soit on rachète leurs parts (coût très élevé si la personne est bien dans le jeu en face)

On peut attaquer les vaisseaux adverses:
- En fonction de notre équipement & équipage, on a une probabilité de le toucher
- Si on le touche, le vaisseau d'en face va s'user (beaucoup)
- On a un cooldown avant de ré-attaquer

### Vaisseaux

Vitesse de déplacement en fonction du personnel à bord

Plus un vaisseau voyage, plus il s'use

Plus il est usé, moins il va vite (usé à 70%, vitesse réduite de 35%)

Si son usure atteint 100%, le vaisseau se détruit en plein vol,
avec tout l'équipage, l'équipement, le fret à son bord

Coûte de l'argent de le réparer à une station spaciale

On peut acheter des améliorations
- Vitesse de déplacement
- Puissance d'attaque
- Cargo
- Resistance à l'usure
- Extraction d'autres resources
- Scanner à vaisseaux

### Personnel

Chacun a un niveau
- Pilote rang I va plus lentement que pilote rang X
- Trader rang I a plus de frais de courtage que trader rang X
- Équipage rang I va extraire moins de ressources que équipage rang X
- Diplomate rang I va avoir un coût de rachat beaucoup plus élevé que le rang X

Augmenter d'un niveau coûte de l'argent, et augmente leurs salaires

### Argent

Si on tombe à 0, on a perdu
Chaque joueur a un "coût par seconde" en fonction de ses équipements et équipage

### Marché

Variation de prix pseudo-aléatoire des matériaux

Créer des "indicateurs d'experts" pour commenter la tendance du marché

Quand on vend,   le prix baisse
Quand on achète, le prix augmente
