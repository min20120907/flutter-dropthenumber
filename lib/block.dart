// Number block in the game
class Block {
  // Value of the block (2, 4, 8, 16...)
  int value = 0;
  // X coordinate of the block, by percentage (0.0 ~ 100.0)
  double x = 0;
  // Y coordinate of the block, by percentage (0.0 ~ 100.0)
  double y = 0;

  /**********************************************************************
  * Constructor
  **********************************************************************/
  Block(this.value, this.x, this.y);
}
