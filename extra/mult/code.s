.global main

/* Usage des registres:
    x19 -- a    x21 -- c    x27 -- constantes
    x20 -- b    x22 -- i    x28 -- pour adressage */
main:                                   // main()
    // Lire a                           // {
    adr     x0, fmtEntree               //
    adr     x1, temp                    //
    bl      scanf                       //
    adr     x28, temp                   //   scanf(fmtEntree, &temp)
    ldrsh   w19, [x28]                  //   int16 a = temp
                                        //
    // Lire b                           //
    adr     x0, fmtEntree               //
    adr     x1, temp                    //
    bl      scanf                       //
    adr     x28, temp                   //   scanf(fmtEntree, &temp)
    ldrsh   w20, [x28]                  //   int16 b = temp
                                        //
    // Somme                            //
    add     w21, w19, w20               //   int32 c = a + b
                                        //
    adr     x0, fmtSortie               //
    mov     w1, w21                     //
    bl      printf                      //   printf(fmtSortie, c)
                                        //
    cmp     w21, 32768                  //
    b.ge    debordement                 //   if !(c >= 2¹⁵ ||
    cmp     w21, -32768                 //        c < -2¹⁵) {
    b.lt    debordement                 //
    adr     x0, msgSansDebordement      //     msg = msgSansDebordement
    b       afficher                    //   }
debordement:                            //   else {
    adr     x0, msgDebordement          //     msg = msgDebordement
afficher:                               //   }
    bl      printf                      //   printf(msg)
                                        //
    // Produit                          //
produit:                                //
    mov     x21, 0                      //   uint64 c = 0
    mov     x22, 0                      //   uint64 i = 0
    mov     x27, 2                      //
boucle:                                 //
    cmp     x22, 32                     //   while (i != 32)
    b.eq    fin                         //   {
    tbz     x20, 0, prochain            //     if (a % 2 != 0) {
    add     x21, x21, x19               //       c += a
prochain:                               //     }
    add     x19, x19, x19               //     a *= 2
    udiv    x20, x20, x27               //     b /= 2
    add     x22, x22, 1                 //     i += 1
    b       boucle                      //   }
fin:                                    //
    adr     x0, fmtSortie               //
    mov     w1, w21                     //
    bl      printf                      //   printf(fmtSortie, (int32)c)
                                        //
    mov     x0, 0                       //
    bl      exit                        // }

.section ".bss"
            .align  2
temp:       .skip   2

.section ".rodata"
fmtEntree:          .asciz  "%hd"
fmtSortie:          .asciz  "%d\n"
msgDebordement:     .asciz  "débordement\n"
msgSansDebordement: .asciz  "sans débordement\n"
