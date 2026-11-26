# Dictionnaire des données — ZakFit

## Utilisateur

| Champ | Type | Règle |
| --- | --- | --- |
| id | UUID | Identifiant unique du compte |
| nom | Texte | Nom affiché dans le profil |
| email | Texte | Obligatoire et unique |
| password_hash | Texte | Empreinte du mot de passe créée par l’API |
| created_at | Date et heure | Date de création du compte |

## Repas

| Champ | Type | Règle |
| --- | --- | --- |
| id | UUID | Identifiant unique du repas |
| user_id | UUID | Utilisateur propriétaire |
| nom | Texte | Libellé du repas |
| calories | Entier | Apport énergétique en kcal, supérieur ou égal à zéro |
| consumed_at | Date et heure | Moment où le repas a été pris |

## Activité

| Champ | Type | Règle |
| --- | --- | --- |
| id | UUID | Identifiant unique de l’activité |
| user_id | UUID | Utilisateur propriétaire |
| nom | Texte | Libellé de l’activité |
| duration_minutes | Entier | Durée en minutes, strictement positive |
| calories_burned | Entier | Dépense estimée en kcal, facultative |
| performed_at | Date et heure | Moment où l’activité a été réalisée |

## Objectif

| Champ | Type | Règle |
| --- | --- | --- |
| id | UUID | Identifiant unique de l’objectif |
| user_id | UUID | Utilisateur propriétaire |
| type | Texte | Apport calorique ou durée d’activité |
| target_value | Entier | Cible quotidienne positive, en kcal ou en minutes selon le type |

## Paramètres utilisateur

| Champ | Type | Règle |
| --- | --- | --- |
| user_id | UUID | Un seul jeu de paramètres par utilisateur |
| timezone | Texte | Fuseau horaire utilisé pour délimiter les journées du tableau de bord, par exemple Europe/Paris |

L’historique est construit à partir des dates des repas et des activités.
