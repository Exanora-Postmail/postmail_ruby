# PostmailRuby

PostmailRuby est une gem Ruby qui fournit un mécanisme flexible d’envoi d’e‑mails pour Ruby on Rails ou tout projet utilisant Action Mailer.  La gem propose deux méthodes d’expédition : soit par **SMTP**, soit par une **API HTTP**.  Tous les paramètres de connexion et le choix de la méthode d’envoi se pilotent via des variables d’environnement afin de simplifier la configuration lors du déploiement.

## Installation

Dans votre `Gemfile`, ajoutez :

```ruby
gem "postmail_ruby", '~> 0.1.3'
```

Puis exécutez `bundle install` pour installer la gem.

## Utilisation dans Rails

PostmailRuby enregistre deux méthodes de livraison personnalisées pour Action Mailer : `:postmail_smtp` et `:postmail_api`.  La gem est livrée avec un **Railtie** qui détecte Rails et configure automatiquement Action Mailer en fonction des variables d’environnement ci‑dessous.  En pratique, il suffit de définir vos variables d’environnement et de vous assurer que la gem est chargée.

Si vous souhaitez configurer explicitement la gem (par exemple hors de Rails), vous pouvez appeler :

```ruby
require "postmail_ruby"
PostmailRuby.configure
```

Cette méthode lit les variables d’environnement, enregistre les méthodes de livraison et définit la méthode d’envoi par défaut (`delivery_method`) sur Action Mailer.

### Variables d’environnement

Toutes les options de configuration se font via des variables d’environnement, ce qui permet de modifier le comportement sans changer le code.  Voici les variables reconnues :

| Variable | Description | Valeur par défaut |
|---------|-------------|------------------|
| `POSTMAIL_DELIVERY_METHOD` | Choix de la méthode d’envoi : `smtp` (envoi via serveur SMTP) ou `api` (envoi via appel HTTP). | `smtp` |
| `POSTMAIL_DISABLE_RAILS_SMTP` | Lorsque défini à `true`, PostmailRuby désactive les paramètres SMTP par défaut de Rails (`ActionMailer::Base.smtp_settings`) pour éviter des retours en arrière accidentels. Utiliser cette option est recommandé si vous envoyez exclusivement via l’API. | `false` |
| `POSTMAIL_API_ENDPOINT` | URL complète de l’endpoint HTTP pour l’envoi par API (par exemple `https://postal.exanora.com/api/v1/send/message`). Obligatoire si `POSTMAIL_DELIVERY_METHOD=api`. | – |
| `POSTMAIL_API_KEY` | Clé d’API utilisée pour authentifier les requêtes HTTP (envoyée dans l’en‑tête `X-Server-API-Key`). | – |
| `POSTMAIL_API_TIMEOUT` | Temps d’attente maximum en secondes lors de l’appel HTTP. | `10` |
| `POSTMAIL_SMTP_HOST` | Nom d’hôte du serveur SMTP (ex : `smtp.exemple.com`). Obligatoire si `POSTMAIL_DELIVERY_METHOD=smtp`. | – |
| `POSTMAIL_SMTP_PORT` | Port du serveur SMTP. | `587` |
| `POSTMAIL_SMTP_USERNAME` | Nom d’utilisateur pour l’authentification SMTP. Laisser vide pour une connexion sans authentification. | `nil` |
| `POSTMAIL_SMTP_PASSWORD` | Mot de passe pour l’authentification SMTP. | `nil` |
| `POSTMAIL_SMTP_AUTHENTICATION` | Type d’authentification SMTP : `plain`, `login` ou `cram_md5`. | `plain` |
| `POSTMAIL_SMTP_ENABLE_STARTTLS_AUTO` | Active STARTTLS. Mettre `false` pour désactiver. | `true` |
| `POSTMAIL_SMTP_SSL` | Lorsque défini à `true`, PostmailRuby établit une connexion SSL/TLS implicite (comme un port 465). | `false` |
| `POSTMAIL_SMTP_OPEN_TIMEOUT` | Durée maximale (en secondes) pour établir la connexion SMTP. | `30` |
| `POSTMAIL_SMTP_READ_TIMEOUT` | Durée maximale (en secondes) pour la lecture des réponses SMTP. | `30` |

### Désactiver le SMTP par défaut de Rails

Rails utilise un mécanisme SMTP par défaut si aucune méthode d’envoi n’est explicitement configurée.  Pour éviter toute utilisation accidentelle du SMTP intégré lorsque vous utilisez Postmail, définissez :

```sh
POSTMAIL_DISABLE_RAILS_SMTP=true
```

Lorsque cette variable est à `true`, PostmailRuby réinitialise `ActionMailer::Base.smtp_settings` à un hash vide et définit `ActionMailer::Base.delivery_method` sur `:postmail_api` ou `:postmail_smtp` en fonction de `POSTMAIL_DELIVERY_METHOD`.

### Exemple de configuration

Pour envoyer via l’API HTTP :

```sh
POSTMAIL_DELIVERY_METHOD=api
POSTMAIL_API_ENDPOINT=https://postal.exanora.com/api/v1/send/message
POSTMAIL_API_KEY=your_api_key
POSTMAIL_DISABLE_RAILS_SMTP=true
```

Pour envoyer via SMTP :

```sh
POSTMAIL_DELIVERY_METHOD=smtp
POSTMAIL_SMTP_HOST=smtp.exemple.com
POSTMAIL_SMTP_PORT=2587
POSTMAIL_SMTP_USERNAME=user
POSTMAIL_SMTP_PASSWORD=secret
POSTMAIL_SMTP_AUTHENTICATION=login
POSTMAIL_SMTP_ENABLE_STARTTLS_AUTO=true
POSTMAIL_DISABLE_RAILS_SMTP=false
```

## Fonctionnement

Lorsque la méthode d’envoi est `api`, PostmailRuby sérialise votre message et l’envoie en `POST` vers l’endpoint HTTP.  Le corps de la requête est JSON et inclut les adresses, le sujet, les corps texte/HTML et les pièces jointes (encodées en Base64).  La clé API est transmise via l’en‑tête `X-Server-API-Key`.

Lorsque la méthode d’envoi est `smtp`, PostmailRuby utilise les paramètres SMTP renseignés pour établir la connexion avec le serveur de messagerie via la gem `mail`.  Les options SSL/TLS, timeouts et authentification sont héritées des variables d’environnement.

## Contribuer

Les demandes d’amélioration et les rapports de bogue sont les bienvenus !  Ouvrez une issue ou une pull request sur GitHub à l’adresse <https://github.com/votrecompte/postmail>.

## Licence

Ce projet est distribué sous licence MIT.  Voir le fichier `LICENSE` pour plus de détails.