#include <iostream>

class Foo
{
  long a;   //  8 octets
  int  b;   //  4 octets
            //  4 octets (remplissage pour alignement)
  long c;   //  8 octets
  int  d;   //  4 octets
            //  4 octets (remplissage pour alignement)
};          // ---------
            // 32 octets

class Bar
{
  long a;   //  8 octets
  long c;   //  8 octets
  int  b;   //  4 octets
  int  d;   //  4 octets
};          // ---------
            // 24 octets

int main()
{
  std::cout << sizeof(Foo) << std::endl
            << sizeof(Bar) << std::endl;
}
