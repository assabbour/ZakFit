# Écran Historique — ZakFit

## Éléments à afficher

- Titre « Historique » et sélecteur de date.
- Total des calories consommées et des minutes d’activité pour la date choisie.
- Section « Repas » avec le nom, l’heure et les calories de chaque repas.
- Section « Activités » avec le nom, l’heure et la durée de chaque activité.
- Dans chaque section, afficher les saisies de la plus récente à la plus ancienne.

## États à maqueter

- Journée avec des repas et des activités.
- Journée vide avec le message « Aucune saisie pour cette date ».
- Chargement après un changement de date.
- Erreur réseau avec un bouton « Réessayer ».

Au changement de date, l’écran recharge les repas et les activités depuis
l’API. La journée est délimitée selon le fuseau horaire du compte.
