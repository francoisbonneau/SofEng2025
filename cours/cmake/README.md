# CMake pas a pas

Le projet a la racine du depot est l'**etat final**. Ce dossier ne contient que
les fichiers qui sont **differents** a chaque etape (les lignes ajoutees sont
marquees `# NOUVEAU`). Le code C++ (`include/`, `src/`, `apps/greet.cpp`, `tests/`)
n'existe qu'a un seul endroit : la racine.

| Etape | Seance | Dossier | Nouveaute |
|---|---|---|---|
| 1 | 2 | `01-executable/` | `project`, `add_executable`, `configure_file` |
| 2 | 3 | `02-bibliotheque/` | `add_library`, `add_subdirectory`, `target_link_libraries`, `target_include_directories`, `option` |
| 3 | 4 | `03-tests/` | `enable_testing`, `add_test`, `ctest`, une `function` CMake |
| 4 | 5 | la racine du depot | `install`, `find_package`, CPack |

Dans les commandes ci-dessous, `$COURS` est le dossier de ce depot (SofEng2025)
et on travaille dans **son propre depot**, cree a la seance 1.

Compiler et lancer, a chaque etape :

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build      # a partir de l'etape 3
```

---

## Etape 1 : un seul executable

```bash
cp $COURS/cours/cmake/01-executable/* .
mkdir -p cmake && cp $COURS/cmake/greeter_config.h.in cmake/
```

```
CMakeLists.txt
greet.cpp
cmake/greeter_config.h.in
```

Tout le code est dans `greet.cpp`. `configure_file` cree `build/greeter_config.h`
a partir de `cmake/greeter_config.h.in` : le programme affiche le systeme et le
compilateur utilises **au moment de la compilation**.

```
Hello Alice!
built on Linux with GNU 13.3.0
```

**Questions :**

1. Ouvrez `build/greeter_config.h`. D'ou viennent les valeurs ?
2. Que se passe-t-il si on retire `target_include_directories` ? Pourquoi ?

## Etape 2 : une bibliotheque

On separe le code qui **calcule** (bibliotheque `greeter`) du code qui **affiche**
(programme `greet`).

```bash
git rm greet.cpp
cp -r $COURS/include $COURS/src $COURS/apps .
cp -r $COURS/cours/cmake/02-bibliotheque/. .
```

```
CMakeLists.txt               add_subdirectory(src/greeter), add_subdirectory(apps)
include/greeter/*.h          ce que la bibliotheque propose
src/greeter/*.cpp            comment elle le fait
src/greeter/CMakeLists.txt   add_library(greeter ...)
apps/greet.cpp               le programme, qui utilise greeter
apps/CMakeLists.txt          target_link_libraries(greet PRIVATE greeter)
```

**A observer :**

- `PUBLIC` / `PRIVATE` dans `target_include_directories` : `greet` voit
  `include/` mais pas `greeter_config.h`.
- `cmake -S . -B build -DGREETER_BUILD_APPS=OFF` : seule la bibliotheque est compilee.

**Erreur classique :** `unresolved external symbol` / `undefined reference to greeter::get_message`.
Les fonctions sont declarees dans `namespace greeter` dans le `.h`,
mais definies **hors** du namespace dans le `.cpp`.

## Etape 3 : des tests

```bash
cp -r $COURS/tests .
cp -r $COURS/cours/cmake/03-tests/. .
```

Un test est un programme qui renvoie `0` si tout va bien. `tests/check.h` fournit
`check_equal` et `check_true` ; la fonction CMake `add_greeter_test` compile un
test et l'enregistre dans `ctest` : **un test = une ligne**.

Exercice `configure_file` : voir le [plan du cours](../README.md#seance-4--exercice-configure_file).

## Etape 4 : installer et distribuer

On reprend les fichiers CMake de la racine du depot :

```bash
cp $COURS/CMakeLists.txt .
cp $COURS/apps/CMakeLists.txt apps/
cp $COURS/src/greeter/CMakeLists.txt src/greeter/
cp $COURS/tests/CMakeLists.txt tests/
cp $COURS/cmake/GreeterConfig.cmake.in cmake/
```

Nouveautes, expliquees dans le [README principal](../../README.md#compiler-tester-lancer-cmake) :

- `install(...)` puis `cmake --install build --prefix install` ;
- `$<BUILD_INTERFACE:...>` / `$<INSTALL_INTERFACE:...>` : les en-tetes ne sont
  pas au meme endroit pendant la compilation et une fois installes ;
- `GreeterConfig.cmake` : un autre projet peut faire `find_package(Greeter)`.
  Les tests le montrent : ils se compilent seuls, contre la bibliotheque installee
  (`cmake -S tests -B build-tests -DCMAKE_PREFIX_PATH=install`) ;
- CPack : `cmake --build build --target package` cree une archive.

---

## Pour l'enseignant : maintenir ces etapes

- Modifier le code C++ **uniquement a la racine** : toutes les etapes en profitent.
- Ne mettre dans `0N-.../` que les fichiers qui different de l'etape precedente.
- `bash cours/cmake/check-steps.sh` reconstruit chaque etape (racine + etapes 01 a N
  copiees par-dessus, comme les etudiants) et verifie qu'elle compile, passe ses tests
  et s'execute. La CI le lance a chaque Pull Request (job `CI - Etapes CMake du cours`).
