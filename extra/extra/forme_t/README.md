# Mettre un tableau en forme de T

Rappelons que la question 6 de l'examen périodique de 2022 porte sur les tableaux _m_ × _n_ en _forme de T_, comme celui-ci:

| 1 | 1 | *1* | 1 | 1 |
|---|---|---|---|---|
| 0 | 0 | **1** | 0 | 0 |
| 0 | 0 | **1** | 0 | 0 |
| 0 | 0 | **1** | 0 | 0 |

## Adresse de la jonction

Supposons que chaque élément du tableau soit stocké sur _k_ octets et que le tableau débute à l'adresse _a_.
La jonction du T, c.-à-d. le premier élément de la colonne du centre, se situe à l'adresse _a + k · (n ÷ 2)_.
Par exemple, dans le cas particulier ci-dessus, où _m = 4_ et _n = 5_, les adresses sont comme suit:

| _a_ | _a+k_ | _a+2k_ | _a+3k_ | _a+4k_ |
|:--|:--|:--|:--|:--|
| _a+5k_ | _a+6k_ | **_a+7k_**| _a+8k_ | _a+9k_ |
| _a+10k_ | _a+11k_ | **_a+12k_** | _a+13k_ | _a+14k_ |
| _a+15k_ | _a+16k_ | **_a+17k_** | _a+18k_ | _a+19k_ |

Dans cet exemple, la jonction se situe donc bien à l'adresse _a + k · (n ÷ 2) = a + k · (5 ÷ 2) = a + 2k_.

***À la révision (H23), j'ai affirmé que la jonction se situe à l'adresse _a + k · (n ÷ 2 + 1)_, ce qui est faux car on compte partir de _0_.***

## Remplir la première ligne

Supposons que `x19`, `x20` et `x21` contiennent respectivement _a_ (adresse du tableau), _m_ (nombre de lignes) et _n_ (nombre de colonnes).
Supposons également que le tableau ne contienne initialement que des 0:

| 0 | 0 | *0* | 0 | 0 |
|---|---|---|---|---|
| 0 | 0 | **0** | 0 | 0 |
| 0 | 0 | **0** | 0 | 0 |
| 0 | 0 | **0** | 0 | 0 |

Dans la question de l'examen, nous avons _k = 2_. Ce code remplit donc la première ligne avec des 1:

```c
  mov   x22, 1             //
  mov   x23, x19           // ptr  = a
  mov   x24, x21           // iter = n
                           //
boucle_ligne:              // do {
  strh  w22, [x23], 2      //   *ptr = 1; ptr += 2
  sub   x24, x24, 1        //   iter--
  cbnz  x24, boucle_ligne  // } while (iter != 0)
```

Après l'exécution, nous obtenons ce contenu:

| 1 | 1 | *1* | 1 | 1 |
|---|---|---|---|---|
| 0 | 0 | **0** | 0 | 0 |
| 0 | 0 | **0** | 0 | 0 |
| 0 | 0 | **0** | 0 | 0 |

## Remplir la colonne du centre

Afin de remplir la colonne du centre, on débute à l'adresse de la jonction, c'est-à-dire _a + 2·(n ÷ 2)_.
Ensuite, à chaque itération, on saute d'une ligne, ce qui correspond à faire un bond de _2n_ octets.
Ce code remplit donc la ligne du centre avec des 1:

```c
  mov   x23, 2             //
  udiv  x23, x21, x23      //
  add   x23, x23, x23      //
  add   x23, x19, x23      // ptr  = a + 2·(n ÷ 2)
  mov   x24, x20           // iter = m
                           //
boucle_col:                // do {
  strh  w22, [x23]         //   *ptr = 1
  add   x23, x23, x21      //
  add   x23, x23, x21      //   ptr += 2*n
  sub   x24, x24, 1        //   iter--
  cbnz  x24, boucle_col    // } while (iter != 0)
```

Après l'exécution, nous obtenons ce contenu:

| 1 | 1 | *1* | 1 | 1 |
|---|---|---|---|---|
| 0 | 0 | **1** | 0 | 0 |
| 0 | 0 | **1** | 0 | 0 |
| 0 | 0 | **1** | 0 | 0 |

Notons que la jonction contenait déjà 1, donc la première itération écrase ce 1 par un autre 1 (ce qui est inutile mais non problématique).

***Le solutionnaire de l'examen utilise l'adresse _a + (n - 1)_ pour la jonction, ce qui est équivalent, car  _2·(n ÷ 2) = n - 1_ lorsque _n_ est impair.***

