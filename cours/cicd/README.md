# CI/CD pas a pas

Ce dossier contient les workflows GitHub Actions **etape par etape**.
Chaque fichier ajoute une seule nouveaute par rapport au precedent
(les lignes changees sont marquees `# NOUVEAU` ou `# MODIFIE`).

Ces fichiers **ne sont pas executes** ici : GitHub ne lit que le dossier
`.github/workflows/`. Pour une etape, copiez le fichier au bon endroit :

```bash
mkdir -p .github/workflows
cp cours/cicd/01-ci-minimal.yml .github/workflows/ci.yml
git add .github/workflows/ci.yml
git commit -m "ci: add minimal CI"
git push
```

Puis ouvrez l'onglet **Actions** du depot sur GitHub.

| Etape | Fichier | Copier vers | Nouveaute |
|---|---|---|---|
| 1 | `01-ci-minimal.yml` | `.github/workflows/ci.yml` | compiler + tester a chaque push |
| 2 | `02-ci-pull-request.yml` | `.github/workflows/ci.yml` | CI sur les Pull Requests |
| 3 | `03-ci-matrix.yml` | `.github/workflows/ci.yml` | Linux **et** Windows |
| 4 | `04-ci-docker.yml` | `.github/workflows/ci.yml` | construire l'image Docker |
| 5 | `05-cd-release.yml` | `.github/workflows/cd.yml` | Release sur un tag `v*` |
| 6 | `06-cd-docker.yml` | `.github/workflows/cd.yml` | publier l'image sur ghcr.io |
| 7 | `07-bonus-format.yml` | `.github/workflows/format.yml` | verifier le formatage |

Les etapes 1 a 4 remplacent toutes le **meme** fichier `ci.yml`.
Les etapes 5-6 creent un **deuxieme** fichier `cd.yml`, et l'etape 7 un troisieme.

---

## Etape 1 : CI minimale

**But :** comprendre qu'une CI n'est qu'une machine qui tape vos commandes.

1. Copiez `01-ci-minimal.yml` vers `.github/workflows/ci.yml`, commit, push.
2. Dans **Actions**, ouvrez le run et depliez chaque etape : vous retrouvez
   la sortie de `cmake`, du compilateur et de `ctest`.

**A observer :** la coche verte a cote du commit sur la page d'accueil du depot.

## Etape 2 : Pull Requests et "casser la CI"

**But :** voir la CI bloquer une erreur avant qu'elle n'arrive sur `master`.

1. Copiez `02-ci-pull-request.yml` vers `.github/workflows/ci.yml`, commit, push.
2. Protegez `master` : *Settings > Branches > Add branch protection rule*
   (ou *Rulesets*), branche `master`, cochez
   **Require status checks to pass before merging** et choisissez `build-and-test`.
3. Creez une branche et cassez le code :
   ```bash
   git switch -c casse-tout
   # dans src/basic/message.cpp : remplacez "Hello World!" par "Hello Wrld!"
   git commit -am "fix: typo"
   git push -u origin casse-tout
   ```
4. Ouvrez une Pull Request vers `master`.

**A observer :** la croix rouge, le message `Wrong message: got "Hello Wrld!"`
dans les logs de `ctest`, et le bouton *Merge* bloque.
Corrigez, poussez a nouveau : la PR redevient verte.

## Etape 3 : plusieurs systemes

**But :** CMake rend le projet portable, la CI le prouve.

Copiez `03-ci-matrix.yml` vers `.github/workflows/ci.yml`.

**A observer :** deux jobs `build-and-test (ubuntu-latest)` et
`build-and-test (windows-latest)`. Comparez les logs : `make`/`ninja` d'un
cote, Visual Studio (MSBuild) de l'autre, pour le **meme** `CMakeLists.txt`.

## Etape 4 : Docker dans la CI

**But :** verifier a chaque changement que l'image Docker fonctionne.

Copiez `04-ci-docker.yml` vers `.github/workflows/ci.yml`.

**A observer :** le job `docker` attend la fin de `build-and-test` (`needs`).
Si un test echoue, l'image n'est pas construite.

## Etape 5 : premiere Release (CD)

**But :** livrer automatiquement une version a partir d'un tag.

1. Copiez `05-cd-release.yml` vers `.github/workflows/cd.yml`, commit, push.
2. Creez et poussez un tag :
   ```bash
   git tag v1.0
   git push origin v1.0
   ```

**A observer :** un run `CD` dans **Actions**, puis l'onglet **Releases**
avec l'archive `HelloProj-1.0-Linux.tar.gz` (creee par CPack).

## Etape 6 : publier l'image Docker

**But :** n'importe qui peut lancer le programme sans le compiler.

1. Copiez `06-cd-docker.yml` vers `.github/workflows/cd.yml`, commit, push.
2. Poussez un nouveau tag (`v1.1`).
3. Sur n'importe quelle machine avec Docker :
   ```bash
   docker run --rm ghcr.io/<votre-compte>/<votre-depot>:v1.1
   ```

**A observer :** l'image dans l'onglet **Packages** du depot.
Si `docker run` refuse l'acces, rendez le package public
(*Package settings > Change visibility*).

## Etape 7 (bonus) : formatage

**But :** automatiser les regles de style du projet (`.clang-format`).

Copiez `07-bonus-format.yml` vers `.github/workflows/format.yml`.

**A observer :** le job echoue sur `mains/hello.cpp`, qui n'est pas formate
(`#include<...>` sans espace). Corrigez en local :

```bash
clang-format -i mains/*.cpp src/basic/*.cpp include/basic/*.h tests/*.cpp
```

puis commit, push : le job passe au vert.
