bool est_premier(uint64_t x)
{
  if (x <= 1)
    return false;
  
  double   y = x;
  double   z = sqrt(y);
  uint64_t d = 2;

  while (d <= z) {
    if (x % d == 0)
      return false;

    d++;
  }
  
  return true;
}
