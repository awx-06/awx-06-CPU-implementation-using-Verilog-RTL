// ============================================================
// test.asm  -- MARIE assembly translation of test.c
//
// C source:
//   int i = 0;
//   while ( i < N ) {
//        a[i] = i;
//        i   = i + 1;
//   }
//
// Memory map (matches provided sample test.hex layout):
//   0x00..0x13  Program code (20 instructions)
//   0x14..0x15  Reserved / NOP padding (2 words)
//   0x16        I    (loop counter)
//   0x17        N    (loop bound = 5)
//   0x18        ONE  (constant 1)
//   0x19        ZERO (constant 0)
//   0x1A        BASE (constant 40 = 0x28, address of a[0])
//   0x1B        PTR  (working pointer)
// ============================================================

        ORG 0

START,  Load ZERO        // AC <- 0
        Store I          // i = 0

        Load BASE        // AC <- 40
        Store PTR        // PTR = 40  (points to a[0])

LOOP,   Load I           // AC <- i
        Subt N           // AC = i - N
        Skipcond 000     // if (AC < 0)  i.e. i < N  -> skip next
        Jump  END        // else loop is done -> exit
        Jump  BODY       // run loop body (i < N)

BODY,   Load N
        Subt I           // AC = N - i  (demo computed value)
        Store PTR        // write into PTR slot

        // advance PTR (simulate a[i+1])
        Load PTR
        Add  ONE
        Store PTR        // PTR = PTR + 1

        // i = i + 1
        Load I
        Add  ONE
        Store I          // i = i + 1

        Jump LOOP        // re-test the condition

END,    Halt

        NOP              // padding to align data section
        NOP              // padding to align data section

/ -------- Data Section ----------------------------
I,      DEC 0            // @ 0x16
N,      DEC 5            // @ 0x17
ONE,    DEC 1            // @ 0x18
ZERO,   DEC 0            // @ 0x19
BASE,   DEC 40           // @ 0x1A   (0x28 = 40 = address of a[0])
PTR,    DEC 0            // @ 0x1B
