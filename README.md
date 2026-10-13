# SofEng2025

[![CI](https://github.com/francoisbonneau/SofEng2025/actions/workflows/ci.yml/badge.svg)](https://github.com/francoisbonneau/SofEng2025/actions/workflows/ci.yml)

Petit projet C++ pour apprendre **CMake**, **Docker** et la **CI/CD** avec GitHub Actions.

## Organisation

```
CMakeLists.txt     projet, options, installation, packaging
include/greeter/   en-tetes (.h) de la bibliotheque "greeter"
src/greeter/       code (.cpp) de la bibliotheque "greeter" + son CMakeLists.txt
apps/              programme greet (utilise "greeter")
tests/             tests : un test = un programme qui renvoie 0 si tout va bien
cmake/             modeles (.in) que CMake complete : greeter_config.h, find_package
Dockerfile         image Docker du programme
.github/workflows/
    ci.yml         CI/CD : compile, teste, puis publie une version apres chaque merge
.releaserc.json    configuration de semantic-release (calcul automatique des versions)
cours/             supports de cours (plan, Docker et CI/CD pas a pas)
```

Regle du projet : **la bibliotheque calcule, le programme affiche.**
Les fonctions de `greeter` renvoient des valeurs (faciles a tester),
seul `apps/greet.cpp` ecrit dans la console.

## Compiler, tester, lancer (CMake)

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release   # configurer
cmake --build build --config Release             # compiler
ctest --test-dir build -C Release                # tester
./build/apps/greet Alice                         # lancer
```

```
Hello Alice!
built on Linux with GNU 13.3.0
```

La deuxieme ligne vient de CMake : au moment de la configuration, CMake connait
le systeme (`CMAKE_SYSTEM_NAME`) et le compilateur (`CMAKE_CXX_COMPILER_ID`...).
`configure_file` recopie ces valeurs dans `greeter_config.h` (genere dans `build/`
a partir de `cmake/greeter_config.h.in`), que `src/greeter/build_info.cpp` inclut.
L'information est figee **a la compilation** : un programme compile dans Docker
dira toujours `built on Linux`, meme lance ailleurs.

Options (a passer a la configuration) :

| Option | Defaut | Role |
|---|---|---|
| `GREETER_BUILD_APPS` | `ON` | compiler `apps/` |
| `GREETER_BUILD_TESTS` | `ON` | compiler `tests/` |

```bash
cmake -S . -B build -DGREETER_BUILD_TESTS=OFF
```

Installer, puis creer l'archive a distribuer (CPack) :

```bash
cmake --install build --prefix install           # -> install/bin, lib, include, cmake
cmake --build build --target package             # -> build/Greeter-0.1.1-Linux.tar.gz
```

La version (`0.1.1` par defaut) est donnee par la CI au moment d'une Release :
`cmake -S . -B build -DCPACK_PACKAGE_VERSION=1.2.0`.

Une fois installe, un autre projet CMake peut utiliser la bibliotheque :

```cmake
find_package(Greeter REQUIRED)
target_link_libraries(mon_programme PRIVATE greeter)
```

(les tests le font : `cmake -S tests -B build-tests -DCMAKE_PREFIX_PATH=install`)

## Ajouter une fonctionnalite

Exemple : une fonction `greeter::get_goodbye(name)` qui renvoie `"Goodbye <name>!"`.

1. **Declarer** la fonction dans un en-tete : `include/greeter/goodbye.h`
   ```cpp
   #pragma once

   #include <string>

   namespace greeter
   {
       std::string get_goodbye( const std::string& name = "World" );
   } // namespace greeter
   ```
2. **Ecrire** la fonction : `src/greeter/goodbye.cpp`
   ```cpp
   #include <greeter/goodbye.h>

   namespace greeter
   {
       std::string get_goodbye( const std::string& name )
       {
           return "Goodbye " + name + "!";
       }
   } // namespace greeter
   ```
3. **Ajouter le .cpp a la bibliotheque** dans `src/greeter/CMakeLists.txt` :
   ```cmake
   add_library(greeter STATIC
       message.cpp
       build_info.cpp
       goodbye.cpp      # <- nouveau
   )
   ```
4. **Tester** : creer `tests/test-goodbye.cpp`
   ```cpp
   #include "check.h"

   #include <greeter/goodbye.h>

   int main()
   {
       int errors = 0;
       errors += check_equal( greeter::get_goodbye( "Alice" ), "Goodbye Alice!" );
       return errors;
   }
   ```
   et l'ajouter dans `tests/CMakeLists.txt` :
   ```cmake
   add_greeter_test(test-goodbye)
   ```
5. **Utiliser** la fonction dans `apps/greet.cpp` (si besoin).
6. Recompiler, `ctest`, puis commit sur une branche et Pull Request : la CI verifie tout.
   Message de commit (ou titre de la PR) : `feat: add get_goodbye`.
   Apres le merge, une nouvelle version mineure est publiee automatiquement (voir CD).

## Docker

```bash
docker build -t greeter .     # construire l'image (compile le projet)
docker run --rm greeter       # Hello World! / built on Linux with GNU ...
docker run --rm greeter greet Alice   # Hello Alice!
```

> Pour aller plus loin (image 6 fois plus petite) : [cours/docker/README.md](cours/docker/README.md).

## CI/CD : Integration et Deploiement Continus

> Pour construire la CI/CD pas a pas en cours : [cours/cicd/README.md](cours/cicd/README.md).

Tout est dans `.github/workflows/ci.yml`.

**A chaque Pull Request et a chaque push sur `master` (CI) :**

1. compile, teste et lance le programme sur **Linux** et **Windows** ;
2. construit et lance l'**image Docker**.

Resultat visible dans l'onglet **Actions** et sur chaque commit / PR (coche verte ou croix rouge).

> Exercice : dans `src/greeter/message.cpp`, remplacez `"Hello "` par `"Helo "`, poussez sur une
> branche, ouvrez une Pull Request... et regardez la CI echouer.

**Apres chaque merge sur `master`, si tout est vert (CD) :**

[semantic-release](https://semantic-release.gitbook.io/) lit les messages de commit
(format [Conventional Commits](https://www.conventionalcommits.org/fr/)) et decide de la version :

| Message de commit | Nouvelle version (depuis 1.2.3) |
|---|---|
| `fix(..): ...` | `1.2.4` |
| `feat(..): ...` | `1.3.0` |
| `BREAKING CHANGE: ...` dans le corps du commit | `2.0.0` |
| `docs: ...`, `ci: ...`, `test: ...`, `refactor: ...` | pas de nouvelle version |

La premiere version publiee est `1.0.0`. S'il y a une nouvelle version, la CI cree :

- le tag `vX.Y.Z` et une **Release** (onglet *Releases*) avec les notes de version
  et l'archive `Greeter-X.Y.Z-Linux.tar.gz` ;
- une **image Docker** sur `ghcr.io` (onglet *Packages*), avec les tags `X.Y.Z` et `latest` :

```bash
docker run --rm ghcr.io/francoisbonneau/sofeng2025:latest
```

Conseil : fusionner les Pull Requests avec **Squash and merge**, et donner a la PR
un titre au format `feat: ...` / `fix: ...`.
