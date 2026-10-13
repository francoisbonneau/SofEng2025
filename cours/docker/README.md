# Docker pas a pas

Deux versions du Dockerfile, a lancer depuis la **racine du projet**
(`-f` indique quel fichier utiliser, `.` est le dossier copie dans l'image) :

| Etape | Fichier | Idee |
|---|---|---|
| 1 | `01-simple.Dockerfile` | une instruction par idee, facile a lire (c'est le `Dockerfile` du projet) |
| 2 | `02-multistage.Dockerfile` | compiler dans une image, livrer dans une autre |

---

## Etape 1 : un Dockerfile simple

```bash
docker build -f cours/docker/01-simple.Dockerfile -t greeter-simple .
docker run --rm greeter-simple
```

Les instructions a connaitre :

| Instruction | Role |
|---|---|
| `FROM` | image de depart (ici Debian) |
| `RUN` | execute une commande pendant la construction |
| `COPY` | copie des fichiers de votre machine vers l'image |
| `CMD` | commande lancee par `docker run` |

**Pieges classiques :**

- `apt-get` sans `-y` : pendant `docker build`, personne ne peut repondre
  "Y" a la question, apt abandonne (`Do you want to continue? [Y/n] Abort.`).
- `sudo` : n'existe pas dans l'image, et on est deja root (`sudo: not found`).
- pas de `.dockerignore` : votre dossier `build/` local est copie dans l'image
  et `mkdir MyProject/build` echoue (`File exists`).

## Entre les deux : mesurer

```bash
docker images greeter-simple   # environ 500 MB !
docker history greeter-simple  # taille de chaque couche
```

Extrait de `docker history` :

```
404MB   RUN apt-get install -y cmake ninja-build build-essential
1.29MB  RUN rm -rf MyProject && apt-get purge -y cmake ninja-build
```

**Question :** le dernier `RUN` est commente "Clean to keep the image small".
Pourquoi l'image ne diminue-t-elle pas ?

**Reponse :** chaque `RUN` cree une **couche** qui s'empile sur les precedentes.
Les couches sont en lecture seule : supprimer un fichier dans une nouvelle couche
le cache, mais il reste stocke dans la couche ou il a ete cree.
Le "nettoyage" ajoute meme 1 MB.

## Etape 2 : multi-stage build

```bash
docker build -f cours/docker/02-multistage.Dockerfile -t greeter-multi .
docker run --rm greeter-multi
docker images greeter-multi    # environ 80 MB
```

Idee : deux `FROM` dans le meme fichier.

1. Etape `build` : on installe le compilateur, on compile, on **teste** (`ctest`)
   et on installe le programme dans `/install`.
   Si un test echoue, l'image n'est pas construite.
2. Image finale : on repart d'une Debian **vide** et on copie **seulement** le
   binaire avec `COPY --from=build`.
   Le compilateur et le code source ne sont pas dans l'image livree.

Autres bonnes pratiques visibles dans ce fichier :

- `apt-get update` et `apt-get install` dans le **meme** `RUN` (sinon Docker peut
  reutiliser un vieux `update` en cache) et `rm -rf /var/lib/apt/lists/*` dans ce
  meme `RUN` ;
- `--no-install-recommends` : n'installer que le necessaire ;
- `WORKDIR` au lieu de `cd` ;
- `CMD ["greet"]` (forme JSON) : le programme est lance directement,
  sans passer par un shell.

| | Etape 1 | Etape 2 |
|---|---|---|
| Taille de l'image | ~500 MB | ~80 MB |
| Compilateur dans l'image | oui | non |
| Code source dans l'image | non (supprime) mais present dans une couche | non |
| Tests lances | non | oui |
