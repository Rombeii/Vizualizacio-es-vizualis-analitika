public class TeamStat {
  int colNum;
  float min;
  float max;
  
  public TeamStat(int colNum) {
    this.colNum = colNum;
    this.min = MAX_FLOAT;
    this.max = MIN_FLOAT;
  }
}
