# Écran Activités — ZakFit

## Liste des activités

- Afficher les activités du jour, de la plus récente à la plus ancienne.
- Pour chaque activité, afficher le nom, l’heure et la durée en minutes.
- Afficher les calories dépensées lorsqu’elles sont renseignées.
- Afficher la durée totale du jour et un bouton « Ajouter une activité ».
- Ouvrir le formulaire en touchant une activité existante.

## Formulaire

- Champs « Nom de l’activité », « Durée (min) » et « Date et heure ».
- Champ facultatif « Calories dépensées (kcal) ».
- Boutons « Enregistrer » et « Annuler ».
- En modification, proposer « Supprimer l’activité » avec confirmation.
- La durée doit être un entier supérieur à zéro. Si les calories sont
  renseignées, elles doivent être un entier positif ou nul.

## États à maqueter

- Liste remplie et liste vide avec le message « Aucune activité aujourd’hui ».
- Formulaire d’ajout et formulaire de modification.
- Message d’erreur sous un champ invalide ou si l’enregistrement échoue.

Après un ajout, une modification ou une suppression, la liste et le
tableau de bord actualisent leurs données depuis l’API.
