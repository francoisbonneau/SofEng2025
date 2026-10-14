# Plan du cours (24 h)

Objectif : a la fin, chaque etudiant a **son propre depot GitHub** avec un projet
C++ compile par CMake, teste, empaquete dans une image Docker, verifie par une CI
et publie automatiquement (Release + image) a chaque version.

Le projet est construit **petit a petit** : chaque seance ajoute une couche,
et le projet compile a la fin de chaque seance.

| Seance | Theme | Ce qui est ajoute au projet | Support |
|---|---|---|---|
| 1 (3 h) | Git, GitHub, compiler a la main | depot GitHub, `greet.cpp` compile avec `g++`, messages de commit `feat:` / `fix:` | |
| 2 (3 h) | CMake : premiers pas | `CMakeLists.txt`, `add_executable`, `cmake -S -B`, `cmake --build`, `configure_file` (systeme et compilateur dans le code) | [cmake/ etape 1](cmake/README.md) |
| 3 (3 h) | CMake : bibliotheque | `include/greeter/`, `src/greeter/`, `add_library`, `target_link_libraries`, `target_include_directories`, `option()` | [cmake/ etape 2](cmake/README.md) |
| 4 (3 h) | Tests et configuration | `tests/`, `check.h`, `ctest`, exercice `configure_file` | [cmake/ etape 3](cmake/README.md), [exercice](#seance-4--exercice-configure_file) |
| 5 (3 h) | Installer et distribuer | `install()`, `find_package`, CPack | [cmake/ etape 4](cmake/README.md) |
| 6 (3 h) | Docker | `Dockerfile` simple, couches, puis multi-stage | [docker/](docker/README.md) |
| 7 (3 h) | CI | etapes 1 a 4 : CI minimale, Pull Requests, matrice, Docker | [cicd/](cicd/README.md) |
| 8 (3 h) | CD et projet final | etapes 5 a 7 (Release par tag, image, semantic-release), puis ajout d'une fonctionnalite de bout en bout | [cicd/](cicd/README.md) |

## Seance 4 : exercice configure_file

Le projet montre deja le mecanisme avec une information **detectee** par CMake :
`greet` affiche `built on Linux with GNU 13.3.0` (voir `cmake/greeter_config.h.in`
et `src/greeter/build_info.cpp`).

**Questions :**

1. Ouvrez `build/greeter_config.h`. D'ou viennent les valeurs ?
2. Compilez avec un autre compilateur (`-DCMAKE_CXX_COMPILER=clang++`) : que change-t-il ?
3. Si on copie le programme compile sous Linux sur une autre machine, qu'affiche-t-il ? Pourquoi ?

**Exercice :** meme mecanisme, mais avec une information **choisie** par
l'utilisateur : le nom salue par defaut.

```bash
cmake -S . -B build -DGREETER_DEFAULT_NAME=Alice
cmake --build build
./build/apps/greet          # Hello Alice!
```

Pistes :

- dans `CMakeLists.txt` :
  `set(GREETER_DEFAULT_NAME "World" CACHE STRING "Name used when none is given")` ;
- dans `cmake/greeter_config.h.in` : `#define GREETER_DEFAULT_NAME "@GREETER_DEFAULT_NAME@"` ;
- `greeter_config.h` est prive a la bibliotheque : il ne peut pas etre utilise dans
  `include/greeter/message.h`. Remplacez la valeur par defaut `= "World"` par une
  deuxieme fonction `get_message()` sans parametre, ecrite dans `message.cpp` ;
- **question bonus :** que devient `test-message` avec `-DGREETER_DEFAULT_NAME=Alice` ?
  Comment ecrire un test qui marche quelle que soit la valeur choisie ?

## Seance 8 : projet final

Chaque etudiant (ou binome) ajoute une fonctionnalite en suivant la recette
du [README principal](../README.md#ajouter-une-fonctionnalite) :

1. branche Git ;
2. `.h` + `.cpp` + ligne dans `src/greeter/CMakeLists.txt` ;
3. test + ligne `add_greeter_test(...)` ;
4. utilisation dans `apps/greet.cpp` ;
5. Pull Request avec un titre `feat: ...`, CI verte, *Squash and merge* ;
6. semantic-release publie automatiquement la nouvelle version (Release + archive + image).

Idees de fonctionnalites (de la plus simple a la plus longue) :

- `get_goodbye(name)` : `"Goodbye Alice!"` (exemple du README) ;
- `get_message_upper(name)` : `"HELLO ALICE!"` ;
- `count_letters(name)` : nombre de lettres du prenom ;
- `repeat(text, n)` : repete un texte `n` fois ;
- **une deuxieme bibliotheque** `src/maths/` + `include/maths/` (`add`, `factorial`...),
  avec son propre `CMakeLists.txt` et un `add_subdirectory(src/maths)` : montre
  que la structure du projet supporte plusieurs bibliotheques.

## Bonus (pour les plus rapides)

- verification du formatage avec `clang-format` (etape 8 de [cicd/](cicd/README.md)) ;
- options de warnings du compilateur (`-Wall -Wextra`, `/W4`) dans la CI.
