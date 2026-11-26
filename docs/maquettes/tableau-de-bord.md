# Tableau de bord — ZakFit

## Éléments à afficher

- Titre « Tableau de bord » et date du jour.
- Carte « Repas » avec les calories consommées et l’objectif quotidien, s’il existe.
- Carte « Activité » avec les minutes d’activité et l’objectif quotidien, s’il existe.
- Graphique sur sept jours avec un sélecteur « Calories » ou « Minutes d’activité ».
- Boutons « Ajouter un repas » et « Ajouter une activité ».

## États à maqueter

- Avec données : afficher les totaux et la progression vers chaque objectif.
- Sans saisie aujourd’hui : afficher 0 kcal et 0 min, avec les boutons d’ajout.
- Sans objectif : afficher le total et un lien « Définir un objectif ».
- Chargement et erreur réseau avec une action « Réessayer ».

## Mise à jour

Après l’enregistrement d’un repas ou d’une activité, le tableau de bord
actualise les totaux et le graphique à partir de l’API. Les journées
sont calculées dans le fuseau horaire du compte.
