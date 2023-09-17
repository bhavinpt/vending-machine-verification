
// ---------------------------------------------------------------------------------
// testbench -- types 
// ---------------------------------------------------------------------------------

typedef enum{
  NICKEL = 5,
  DIME = 10,
  QUARTER = 25
} Coin;

typedef struct{
  Coin coin;
  int count = 0;
} CoinCount;



