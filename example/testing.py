PORT=9345
URL=f"http://127.0.0.1:{PORT}"

import os
import sys
import math
import time
import json
import string
import urllib.request
import random


class SimeisError(Exception):
    pass

USERNAME = "test-rich" + str(random.randint(0, 1000))

MOD_TYPE = "Miner"

MOD_TYPE2 = "GasSucker"

# Théorème de Pythagore pour récupérer la distance entre 2 points dans l'espace 3D
def get_dist(a, b):
    return math.sqrt(((a[0] - b[0]) ** 2) + ((a[1] - b[1]) ** 2) + ((a[2] - b[2]) ** 2))

class Test:

    def __init__(self):
        
        self.player = self.get(f"/player/new/{USERNAME}")
        
        if self.player:
            print(f"-- ✅ Joueur de Test créé : {USERNAME}")

        print("")
        print("Cas fonctionnel n°1 :")

        self.testN1()

        print("")
        print("Cas fonctionnel n°2:")

        self.testN2()
                
        print("")
        print("Cas fonctionnel n°3:")

        self.testN3()

    # - On créé un nouveau joueur
    # - Son argent de départ est X
    # - On achète un vaisseau
    # - La transaction doit réussir
    # - Notre argent doit avoir diminué
    # - On achète un module de Miner
    # - La transaction doit réussir
    # - Notre argent doit avoir encore diminué
    def testN1(self):
        playerStatut = self.updateStatut()

        assert playerStatut["name"] == USERNAME, "⛔ Le nom du Joueur créer n'est pas le bon"
        print(f"-- ✅ Argent de départ de {USERNAME} : {playerStatut["money"]}")
        
        initMoney = playerStatut["money"]
        
        stationId = next(iter(playerStatut["stations"]))

        available = self.get(f"/station/{stationId}/shipyard/list")["ships"]

        cheapest = sorted(available, key = lambda ship: ship["price"])[0]

        shipId = self.get(f"/station/{stationId}/shipyard/buy/" + str(cheapest["id"]))["shipId"]


        playerStatut = self.updateStatut()

        assert initMoney - cheapest["price"] == playerStatut["money"], "⛔ Le Joueur n'a pas donné le bon montant pour l'achat"
        print("-- ✅ Achat du vaisseaux effectué")

        assert len(playerStatut["ships"]) == 1, "⛔ Le Joueur ne possède pas le vaisseau nouvellement acheté"
        print(f"-- ✅ Argent diminué : {playerStatut["money"]}")
        
        initMoney = playerStatut["money"]

        all = self.get(f"/station/{stationId}/shop/modules")

        modPrice = all[MOD_TYPE]

        self.minerId = self.get(f"/station/{stationId}/shop/modules/{shipId}/buy/{MOD_TYPE}")["id"]

        playerStatut = self.updateStatut()

        assert initMoney - modPrice == playerStatut["money"], "⛔ Le Joueur n'a pas donné le bon montant pour l'achat"
        print("-- ✅ Achat du module Miner effectué")

        assert playerStatut["ships"][0]["modules"]["1"]["modtype"] == MOD_TYPE, "⛔ L'achat ne s'est pas produit correctement"
        print(f"-- ✅ Argent diminué : {playerStatut["money"]}")

    # - On achète un Pilote
    # - La transaction réussi
    # - Notre argent doit avoir diminué
    # - On affecte le Pilote au vaisseau
    # - On achète un Opérateur
    # - La transaction réussi
    # - Notre argent doit avoir diminué
    # - On achète l'amélioration du Pilote
    # - La transaction réussi
    # - Notre argent doit avoir diminué
    # - On effectue un scan
    # - On voyage a la planete la plus proche
    # - Le temps de voyage doit correspondre par rapport a la vitesse et la distance
    # - Le vaisseau doit avoir les meme coordonnée a l'arrivée que la planete
    def testN2(self):
        playerStatut = self.updateStatut()

        initMoney = playerStatut["money"]

        stationId = list(playerStatut["stations"].keys())[0]

        pilotId = self.get(f"/station/{stationId}/crew/hire/pilot")["id"]

        assert pilotId != None, "⛔ Le pilote n'a pas pu être recruter a bord du vaisseau"
        print("-- ✅ Pilote recruté avec succès")

        shipId = playerStatut["ships"][0]["id"]
        
        self.get(f"/station/{stationId}/crew/assign/{pilotId}/{shipId}/pilot")
        playerStatut = self.updateStatut()

        assert playerStatut["ships"][0]["crew"][str(pilotId)]["member_type"] == "Pilot", "⛔ Le pilote n'as pas été affecté correctement"
        print("-- ✅ Le Pilote a bien été affecté au bon vaisseau")

        self.operatorId = self.get(f"/station/{stationId}/crew/hire/operator")["id"]

        assert self.operatorId != None, "⛔ L'opérateur n'a pas pu être recruter a bord du vaisseau"
        print("-- ✅ Opérateur recruté avec succès")

        shipId = playerStatut["ships"][0]["id"]

        cost = self.get(f"/station/{stationId}/crew/upgrade/ship/{shipId}")[str(pilotId)]["price"]

        self.get(f"/station/{stationId}/crew/upgrade/ship/{shipId}/{pilotId}")
        
        playerStatut = self.updateStatut()
        
        assert playerStatut["ships"][0]["crew"][str(pilotId)]["rank"] == 2, "⛔ Le niveau du pilote ne s'est pas augmenté"
        print(f"-- ✅ Le pilote a monté en compétence")

        assert initMoney - cost == playerStatut["money"], "⛔ L'achat ne s'est pas produit correctement"
        print(f"-- ✅ Argent diminué : {playerStatut["money"]}")

        all = self.get(f"/station/{stationId}/shop/modules")

        modPrice = all[MOD_TYPE2]

        initMoney = playerStatut["money"]

        self.gasSuckerId = self.get(f"/station/{stationId}/shop/modules/{shipId}/buy/{MOD_TYPE2}")["id"]

        playerStatut = self.updateStatut()

        assert initMoney - modPrice == playerStatut["money"], "⛔ Le Joueur n'a pas donné le bon montant pour l'achat"
        print("-- ✅ Achat du module Miner effectué")

        assert playerStatut["ships"][0]["modules"]["1"]["modtype"] == MOD_TYPE, "⛔ L'achat ne s'est pas produit correctement"
        print(f"-- ✅ Argent diminué : {playerStatut["money"]}")

    # - On effectue un scan
    # - On voyage a la planete la plus proche
    # - Le temps de voyage doit correspondre par rapport a la vitesse et la distance
    # - Le vaisseau doit avoir les même coordonnée a l'arrivée que la planete
    # - On affecte l'operateur au bon module
    # - On commence le minage
    # - On regarde si le stockage s'est remplie
    def testN3(self):
        playerStatut = self.updateStatut()

        stationId = list(playerStatut["stations"].keys())[0]

        shipId = playerStatut["ships"][0]["id"]

        planets = self.get(f"/station/{stationId}/scan")["planets"]

        assert planets != None, "⛔ Aucune planètes détecté"
        print("-- ✅ La galaxie est a nous mon reuf")
        
        planet = sorted(
            planets, key=lambda pla: get_dist(playerStatut["ships"][0]["position"], pla["position"])
        )[0]

        if (planet["solid"]):
            self.get(f"/station/{stationId}/crew/assign/{self.operatorId}/{shipId}/{self.minerId}")
        else:
            self.get(f"/station/{stationId}/crew/assign/{self.operatorId}/{shipId}/{self.gasSuckerId}")


        self.get(f"/ship/{shipId}/navigate/{planet["position"][0]}/{planet["position"][1]}/{planet["position"][2]}")        

        assert "InFlight" in self.updateStatut()["ships"][0]["state"], "⛔ Le vaisseau a pété la batterie !"
        print("-- ✅ Le vaisseau est en vol")

        while "InFlight" in self.updateStatut()["ships"][0]["state"]:
            self.get("/tick")

        playerStatut = self.updateStatut()

        assert playerStatut["ships"][0]["position"] == planet["position"], "⛔ Le vaisseau s'est perdu"
        print("-- ✅ Le vaisseau est bien arrivé")

        self.get(f"/ship/{shipId}/extraction/start")

        assert "Extracting" in self.updateStatut()["ships"][0]["state"], "⛔ L'extraction n'a pas commencée"
        print("-- ✅ Extraction commencée")

        initUsage = self.updateStatut()["ships"][0]["cargo"]["usage"]
        
        self.get("/tick")

        assert initUsage < self.updateStatut()["ships"][0]["cargo"]["usage"], "⛔ Même le vaisseau broit du vide "
        print("-- ✅ Extraction remplie correctement le cargo")

        while "Extracting" in self.updateStatut()["ships"][0]["state"]:
            self.get("/tick")

        assert "Idle" in self.updateStatut()["ships"][0]["state"], "⛔ Le vaisseau toujours plus ce qu'il n'en faut"
        print("-- ✅ Extraction terminée")

        




    def updateStatut(self):
        return self.get("/player/{}".format(self.player["playerId"]))

    def get(self, path, **qry):
        if hasattr(self, "player"):
            qry["key"] = self.player["key"]

        tail = ""
        if len(qry) > 0:
            tail += "?"
            tail += "&".join(
                ["{}={}".format(k, urllib.parse.quote(v)) for k, v in qry.items()]
            )

        qry = f"{URL}{path}{tail}"
        reply = urllib.request.urlopen(qry, timeout=45)

        data = json.loads(reply.read().decode())
        err = data.pop("error")
        if err != "ok":
            raise SimeisError(err)

        return data

if __name__ == "__main__":
    Test()