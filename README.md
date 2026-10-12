# SofEng2025

[![CI](https://github.com/francoisbonneau/SofEng2025/actions/workflows/ci.yml/badge.svg)](https://github.com/francoisbonneau/SofEng2025/actions/workflows/ci.yml)

Petit projet C++ pour apprendre **CMake**, **Docker** et la **CI/CD** avec GitHub Actions.

## Organisation

```
include/basic/   en-tetes de la bibliotheque "basic"
src/basic/       code de la bibliotheque "basic"
mains/           programme HelloWorld
tests/           tests (un test = un programme qui renvoie 0 si OK)
cmake/           fichiers de configuration generes par CMake
.github/workflows/
    ci.yml       compile + teste a chaque push / Pull Request
    cd.yml       publie une Release + une image Docker a chaque tag v*
cours/cicd/      les workflows construits etape par etape (voir son README)
```

## Compiler et tester (CMake)

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release   # configurer
cmake --build build --config Release             # compiler
ctest --test-dir build -C Release                # tester
./build/mains/HelloWorld                         # lancer
```

Creer l'archive a distribuer (CPack) :

```bash
cmake --build build --target package
```

## Docker

```bash
docker build -t hello .   # construire l'image (compile ET teste le projet)
docker run --rm hello     # lancer le programme
```

## CI : Integration Continue

> Pour construire la CI/CD pas a pas en cours : [cours/cicd/README.md](cours/cicd/README.md).

A chaque `push` sur `master` et a chaque Pull Request, GitHub Actions
(`.github/workflows/ci.yml`) :

1. compile et teste sur **Linux** et **Windows** ;
2. construit et lance l'**image Docker**.

Resultat visible dans l'onglet **Actions** et sur chaque commit / PR (coche verte ou croix rouge).

> Exercice : changez `"Hello World!"` dans `src/basic/message.cpp`, poussez sur une branche,
> ouvrez une Pull Request... et regardez la CI echouer.

## CD : Deploiement Continu

Pour publier une version :

```bash
git tag v1.0
git push origin v1.0
```

GitHub Actions (`.github/workflows/cd.yml`) cree alors :

- une **Release** (onglet *Releases*) avec l'archive `.tar.gz` du programme ;
- une **image Docker** sur `ghcr.io` (onglet *Packages*) :

```bash
docker run --rm ghcr.io/francoisbonneau/sofeng2025:v1.0
```
