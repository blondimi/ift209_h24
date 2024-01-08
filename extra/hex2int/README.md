# D'un caractère hexadécimal vers sa valeur numérique

Supposons que `w19` contienne le code ASCII d'un caractère parmi {`0`, ..., `9`, `A`, ..., `F`}.
Voyons comment obtenir la valeur numérique du caractère dans `w20`. Par exemple, `C` doit devenir 12. 

## 0 à 9

Les caractrères `0` à `9` sont représentés comme suit:

| Caractère | Code décimal | Code binaire |
|:-:|:-:|:-:|
|`0`|48|00110000|
|`1`|49|00110001|
|`2`|50|00110010|
|`3`|51|00110011|
|`4`|52|00110100|
|`5`|53|00110101|
|`6`|54|00110110|
|`7`|55|00110111|
|`8`|56|00111000|
|`9`|57|00111001|

Remarquons que les quatre bits de poids faible du code binaire correspondent exactement à la valeur numérique du chiffre.
Par exemple, `9` est représenté par 0011**1001** et vaut en effet 1001₂ = 9. Ainsi, la valeur numérique peut être obtenue avec:

```c
     and  w20, w19, 0x0F
```

## A à F

Les caractrères `A` à `F` sont représentés comme suit:

| Caractère | Code décimal | Code binaire |
|:-:|:-:|:-:|
|`A`|65|01000001|
|`B`|66|01000010|
|`C`|67|01000011|
|`D`|68|01000100|
|`E`|69|01000101|
|`F`|70|01000110|

Remarquons que les quatre bits de poids faible du code binaire correspondent à la valeur numérique du chiffre déphasée de 9.
Par exemple, `F` est représenté par 0100**0110** et vaut en effet 0110₂ + 9 = 6 + 9 = 15. Ainsi, la valeur numérique peut être obtenue avec:

```c
     and  w20, w19, 0x0F
     add  w20, w20, 0x09
```

## 0 à F

En combinant les deux cas possibles, nous pouvons donc extraire la valeur numérique de cette façon:

```c
     and   w20, w19, 0x0F
     cmp   w19, 65
     b.lo  fin
     add   w20, w20, 0x09
fin:
```

Il existe une façon (plus cryptique) d'arriver au même résultat _sans utiliser de branchement_. Remarquons
que le deuxième bit de poids fort vaut 0 pour les chiffres et 1 pour les lettres:

| Caractère | Code décimal | Code binaire |
|:-:|:-:|:-:|
|`0`|48|0**0**110000|
|⋮|⋮|⋮|
|`9`|57|0**0**111001|
|`A`|65|0**1**000001|
|⋮|⋮|⋮|
|`F`|70|0**1**000110|

Le code ci-dessous génère 00000000₂ = 0 si `w19` est un chiffre, et 00001001₂ = 9 si `w19` est une lettre:

```c
                                 // Exemples
                                 // w19 = 00110101 ('5')      w19 = 01000110 ('F')
     lsr  w21, w19, 6            // w21 = 00000000            w21 = 00000001
     lsl  w22, w21, 3            // w22 = 00000000            w22 = 00001000
     orr  w22, w21, w22          // w22 = 00000000 (0)        w22 = 00001001 (9)
```

On peut donc extraire la valeur numérique du caractère de cette façon:

```c
                                 // Exemples
                                 // w19 = 00110101 ('5')      w19 = 01000110 ('F')
     and   w20, w19, 0x0F        // w20 = 00000101 (5)        w20 = 00000110 (6)
     lsr   w21, w19, 6           // w21 = 00000000            w21 = 00000001
     lsl   w22, w21, 3           // w22 = 00000000            w22 = 00001000
     orr   w22, w21, w22         // w22 = 00000000 (0)        w22 = 00001001 (9)
     add   w20, w20, w22         // w20 = 00000101 (5)        w20 = 00001111 (15)
```

On peut sauver une ligne de code en combinant deux instructions comme suit:

```c
                                 // Exemples
                                 // w19 = 00110101 ('5')      w19 = 01000110 ('F')
     and   w20, w19, 0x0F        // w20 = 00000101 (5)        w20 = 00000110 (6)
     lsr   w21, w19, 6           // w21 = 00000000            w21 = 00000001
     orr   w22, w21, w21, lsl 3  // w22 = 00000000 (0)        w22 = 00001001 (9)
     add   w20, w20, w22         // w20 = 00000101 (5)        w20 = 00001111 (15)
```
