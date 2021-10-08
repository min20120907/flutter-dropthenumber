// @dart=2.11
// Block class storing every blocks stat
class Block {
  // Value of the block (2, 4, 8, 16...)
  int v = 0;
  // X coordinate of the block, by percentage (0.0 - 100.0)
  double x = 0;
  // Y coordinate of the block, by percentage (0.0 - 100.0)
  double y = 0;

  /**********************************************************************
  * Constructor
  **********************************************************************/
  Block(this.v, this.x, this.y);
}
