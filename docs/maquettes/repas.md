# Écran Repas — ZakFit

## Liste des repas

- Afficher les repas du jour, du plus récent au plus ancien.
- Pour chaque repas, afficher le nom, l’heure et les calories en kcal.
- Afficher le total du jour et un bouton « Ajouter un repas ».
- Ouvrir le formulaire en touchant un repas existant.

## Formulaire

- Champs « Nom du repas », « Calories (kcal) » et « Date et heure ».
- Boutons « Enregistrer » et « Annuler ».
- En modification, proposer « Supprimer le repas » avec confirmation.
- Le nom est obligatoire et les calories doivent être un entier positif ou nul.

## États à maqueter

- Liste remplie et liste vide avec le message « Aucun repas aujourd’hui ».
- Formulaire d’ajout et formulaire de modification.
- Message d’erreur sous un champ invalide ou si l’enregistrement échoue.

Après un ajout, une modification ou une suppression, la liste et le
tableau de bord actualisent leurs données depuis l’API.
