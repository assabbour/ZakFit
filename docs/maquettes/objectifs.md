# Écran Objectifs — ZakFit

## Liste des objectifs

- Afficher chaque objectif avec son type, sa cible et la progression du jour.
- Prévoir deux types : calories consommées (kcal/jour) et durée d’activité (min/jour).
- Afficher un bouton « Ajouter un objectif ».
- Ouvrir le formulaire en touchant un objectif existant.

## Formulaire

- Sélecteur « Type d’objectif » et champ « Cible quotidienne ».
- Afficher l’unité correspondant au type sélectionné.
- La cible doit être un entier strictement positif.
- Boutons « Enregistrer » et « Annuler ».
- En modification, proposer « Supprimer l’objectif » avec confirmation.

## États à maqueter

- Liste vide avec le message « Aucun objectif défini ».
- Liste remplie avec les valeurs du jeu de test : 1 050 / 2 000 kcal et 30 / 45 min.
- Formulaire avec une cible invalide ou un échec d’enregistrement.

Après un ajout, une modification ou une suppression, la liste et le tableau
de bord actualisent leurs données depuis l’API.
