# Déploiement de LaSuite sur Kubernetes

## Prérequis

### Installation de age et sops

Installer `age` et `sops` pour chiffrer les secrets dans les fichiers de configuration Helm.

```bash
brew install age
brew install sops
```

### Génération de la clé age

```bash
# Linux
age-keygen > ~/.config/sops/age/keys.txt
# MacOS
age-keygen > /Users/$(whoami)/Library/Application\ Support/sops/age/keys.txt

```

Copier la clé publique dans le fichier `manifests/.sops.yaml`.

### Chiffrement des secrets

Créer le fichier `manifests/dev/secrets.yml` et indiquer les secrets à chiffrer dans ce fichier sous le même format que le fichier `values.yaml`.
Par exemple, pour le fichier `values.yaml` suivant :

```yaml
huggingface:
  token: "YOUR_HF_API_KEY"
```

Ensuite, utiliser la commande suivante pour chiffrer le fichier `secret.enc.yaml` depuis le dossier `manifests` :

```bash
sops -d dev/secrets.yaml > dev/secrets.enc.yaml
```

Ensuite, pour valider le chart Helm, vous pouvez utiliser la commande suivante :

```bash
#MacOS
docker run --rm -v "${PWD}:/wd" -v /Users/<user>/Library/Application\ Support/sops/:/helm/.config/sops --workdir /wd ghcr.io/helmfile/helmfile:v0.169.0 helmfile -e dev template
```