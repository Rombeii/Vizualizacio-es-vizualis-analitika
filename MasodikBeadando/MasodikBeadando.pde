import java.util.*;

Table players;
Table teams;

ArrayList<TeamStat> teamStats;
HashMap<String, ArrayList<PShape>> teamShapes;
int[] statsToWatch = {8, 7, 11, 12, 13};
HashMap<String, ArrayList<Float>> statsPerTeam;

float BRACKET_PART_HEIGHT;
float BRACKET_PART_WIDTH;

float BRACKET_START_AT_HEIGHT;
float BRACKET_START_AT_WIDTH;

float GROUP_START_AT_HEIGHT;

float TAB_BOTTOM;

String highlightedTeam = "";
String selectedTeam = "";
PlayerStat selectedPlayer = null;
boolean mouseMovedAfterAdd;

String selectedTab = "Bracket";
HashMap<Point, PlayerStat> playerPoints; 

final String PLAYER_FILE_PATH = "PlayerStats.csv";
ParallelCoordinatesView parallelCoordinatesView;

void setup() {
  //size(1700, 900);
  fullScreen();
  BRACKET_PART_HEIGHT = height * 0.05;
  BRACKET_PART_WIDTH = width * 0.1;

  BRACKET_START_AT_HEIGHT = height * 0.1;
  BRACKET_START_AT_WIDTH = width * 0.1;

  GROUP_START_AT_HEIGHT = BRACKET_START_AT_HEIGHT * 7.5;

  initTables();
  initTeamStats();
  initStatsPerTeam();
  initBracket();
  initGroupStage();
  
  teams.removeRow(0);
  teams.setColumnType(12, "float");
  teams.setColumnType(13, "float");
  
  playerPoints = new HashMap();
  
  float canvasWidth = width;
  float canvasHeight = height * 0.8;

  ArrayList<String> labels = createLabelsFrom(PLAYER_FILE_PATH);
  ArrayList<String> labelComments = createLabelCommentsFrom(PLAYER_FILE_PATH);
  ArrayList<Sample> samples = createSamplesFrom(PLAYER_FILE_PATH);
  parallelCoordinatesView = new ParallelCoordinatesView(labels, labelComments, samples, 0.0f, height * 0.05, canvasWidth, canvasHeight);
}

void draw() {
  background(255);
  drawTabs();
  if (selectedTab.equals("Bracket")) {
    drawBracket();
    drawStar();
  } else if (selectedTab.equals("Teams")) {
    drawTeamChart();
  } else if (selectedTab.equals("Players")) {
    parallelCoordinatesView.draw();
  } else if (selectedTab.equals("Roles")) {
    drawPointChart();
  }
}

void drawTabs() {
  textAlign(BASELINE);
  fill(224);
  rectMode(CORNER);
  noStroke();
  textSize(20);
  rect(0, 0, width, height * 0.04);
  if(selectedTab.equals("Bracket")) {
    fill(255);
  } else {
    fill(224);
  }
  rect(0, height * 0.01, width * 0.08, height * 0.03);
  fill(0);
  text("Bracket", width * 0.001, height * 0.01, width * 0.08, height * 0.03);
  
  if(selectedTab.equals("Teams")) {
    fill(255);
  } else {
    fill(224);
  }
  rect(width * 0.08, height * 0.01, width * 0.16, height * 0.03);
  fill(0);
  text("Teams" ,width * 0.08 + width * 0.001, height * 0.01, width * 0.16, height * 0.03);
  
  if(selectedTab.equals("Players")) {
    fill(255);
  } else {
    fill(224);
  }
  rect(width * 0.16, height * 0.01, width * 0.16, height * 0.03);
  fill(0);
  text("Players",width * 0.16 + width * 0.001, height * 0.01, width * 0.16, height * 0.03);
  
  if(selectedTab.equals("Roles")) {
    fill(255);
  } else {
    fill(224);
  }
  rect(width * 0.24, height * 0.01, width * 0.08, height * 0.03);
  fill(0);
  text("Roles", width * 0.24 + width * 0.001, height * 0.01, width * 0.08, height * 0.03);
  
}

void drawStar() {
  if(selectedTeam != "" || highlightedTeam != "") {
    textSize(15.f);
    fill(0);
    text("Average kills per minute", BRACKET_START_AT_WIDTH * 8.3, BRACKET_START_AT_HEIGHT * 5.8);
    text("Kill Death ratio", BRACKET_START_AT_WIDTH * 6.8, BRACKET_START_AT_HEIGHT * 5.8);
    text("Early game rating", BRACKET_START_AT_WIDTH * 6.4, BRACKET_START_AT_HEIGHT * 3.3);
    text("Mid/Lategame rating", BRACKET_START_AT_WIDTH * 7.5, BRACKET_START_AT_HEIGHT * 1.7);
    text("Gold difference at 15", BRACKET_START_AT_WIDTH * 9, BRACKET_START_AT_HEIGHT * 3.3);
  }
  ArrayList<Float> test = new ArrayList();
  if (selectedTeam != "") {
    for (int i = 0; i < statsToWatch.length; i++) {
      test.add(map(statsPerTeam.get(selectedTeam).get(i), teamStats.get(i).min, teamStats.get(i).max, 0, 100));
    }
  }

  ArrayList<Float> test2 = new ArrayList();
  if (highlightedTeam != "") {
    for (int i = 0; i < statsToWatch.length; i++) {
      test2.add(map(statsPerTeam.get(highlightedTeam).get(i), teamStats.get(i).min, teamStats.get(i).max, 0, 100));
    }
  }

  pushMatrix();
  translate(width*0.8, height*0.4);
  rotate(PI/3.31);
  scale(2.0);
  if(selectedTeam != "" || highlightedTeam != "")
    createBaseStar();
  fill(#000075, 200);
  if(selectedTeam != "")
    star2(0, 0, test);
  fill(#800000, 200);
  if(highlightedTeam != "")
    star2(0, 0, test2);
  popMatrix();
}

void initTables() {
  players = loadTable("PlayerStats.csv");
  teams = loadTable("TeamStats.csv");
}

void initTeamStats() {
  teamStats = new ArrayList();
  for (int i = 0; i < statsToWatch.length; i++) {
    teamStats.add(new TeamStat(i));
  }
}

void initStatsPerTeam() {
  statsPerTeam = new HashMap();
  int rowCount = teams.getRowCount();  
  for (int row = 1; row < rowCount; row++) {
    ArrayList<Float> stats = new ArrayList();
    String teamName = teams.getString(row, 0);
    for (int i = 0; i < statsToWatch.length; i++) {
      int colNum = statsToWatch[i];
      float stat = teams.getFloat(row, colNum);
      stats.add(stat);
      if (stat > teamStats.get(i).max) {
        teamStats.get(i).max = stat;
      } else if (stat < teamStats.get(i).min) {
        teamStats.get(i).min = stat;
      }
    }
    statsPerTeam.put(teamName, stats);
  }
  
}

void initBracket() {
  initEmptyTeamShapes();
  //COL1
  PShape rngShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT);
  PShape edgShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT);
  teamShapes.get("Royal Never Give Up").add(rngShape);
  teamShapes.get("EDward Gaming").add(edgShape);

  PShape gengShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 3);
  PShape c9Shape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 4);
  teamShapes.get("Gen.G").add(gengShape);
  teamShapes.get("Cloud9").add(c9Shape);

  PShape t1Shape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 6);
  PShape hanwaShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 7);
  teamShapes.get("T1").add(t1Shape);
  teamShapes.get("Hanwha Life Esports").add(hanwaShape);

  PShape dwShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 9);
  PShape madShape = createBracketRect(BRACKET_START_AT_WIDTH, BRACKET_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 10);
  teamShapes.get("DWG KIA").add(dwShape);
  teamShapes.get("MAD Lions").add(madShape);

  //COL2
  edgShape = createBracketRect(BRACKET_START_AT_WIDTH * 2.5, BRACKET_START_AT_HEIGHT + BRACKET_START_AT_HEIGHT / PI + BRACKET_PART_HEIGHT);
  gengShape = createBracketRect(BRACKET_START_AT_WIDTH * 2.5, BRACKET_START_AT_HEIGHT  + BRACKET_START_AT_HEIGHT / PI + BRACKET_PART_HEIGHT + BRACKET_PART_HEIGHT);
  teamShapes.get("EDward Gaming").add(edgShape);
  teamShapes.get("Gen.G").add(gengShape);  

  t1Shape = createBracketRect(BRACKET_START_AT_WIDTH * 2.5, BRACKET_START_AT_HEIGHT + BRACKET_START_AT_HEIGHT / PI + BRACKET_PART_HEIGHT + BRACKET_PART_HEIGHT * 6);
  dwShape = createBracketRect(BRACKET_START_AT_WIDTH * 2.5, BRACKET_START_AT_HEIGHT  + BRACKET_START_AT_HEIGHT / PI + BRACKET_PART_HEIGHT + BRACKET_PART_HEIGHT *7);
  teamShapes.get("T1").add(t1Shape);
  teamShapes.get("DWG KIA").add(dwShape);  

  //COL3
  edgShape = createBracketRect(BRACKET_START_AT_WIDTH * 4, BRACKET_START_AT_HEIGHT + BRACKET_START_AT_HEIGHT / PI + BRACKET_PART_HEIGHT * 4);
  dwShape = createBracketRect(BRACKET_START_AT_WIDTH * 4, BRACKET_START_AT_HEIGHT + BRACKET_START_AT_HEIGHT / PI  + BRACKET_PART_HEIGHT * 5);
  teamShapes.get("EDward Gaming").add(edgShape);
  teamShapes.get("DWG KIA").add(dwShape);  

  //COL4
  edgShape = createBracketRect(BRACKET_START_AT_WIDTH * 5.5, BRACKET_START_AT_HEIGHT + BRACKET_START_AT_HEIGHT / PI  + BRACKET_PART_HEIGHT * 4.5);
  teamShapes.get("EDward Gaming").add(edgShape);
}

void initGroupStage() {
  teamShapes.get("DWG KIA").add(createGroupRect(BRACKET_START_AT_WIDTH * 1.25, GROUP_START_AT_HEIGHT));
  teamShapes.get("Cloud9").add(createGroupRect(BRACKET_START_AT_WIDTH * 1.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT));
  teamShapes.get("Rogue").add(createGroupRect(BRACKET_START_AT_WIDTH * 1.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 2));
  teamShapes.get("FunPlus Phoenix").add(createGroupRect(BRACKET_START_AT_WIDTH * 1.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 3));

  teamShapes.get("T1").add(createGroupRect(BRACKET_START_AT_WIDTH * 3.25, GROUP_START_AT_HEIGHT));
  teamShapes.get("EDward Gaming").add(createGroupRect(BRACKET_START_AT_WIDTH * 3.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT));
  teamShapes.get("100 Thieves").add(createGroupRect(BRACKET_START_AT_WIDTH * 3.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 2));
  teamShapes.get("DetonatioN FocusMe").add(createGroupRect(BRACKET_START_AT_WIDTH * 3.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 3));

  teamShapes.get("Royal Never Give Up").add(createGroupRect(BRACKET_START_AT_WIDTH * 5.25, GROUP_START_AT_HEIGHT));
  teamShapes.get("Hanwha Life Esports").add(createGroupRect(BRACKET_START_AT_WIDTH * 5.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT));
  teamShapes.get("PSG Talon").add(createGroupRect(BRACKET_START_AT_WIDTH * 5.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 2));
  teamShapes.get("Fnatic").add(createGroupRect(BRACKET_START_AT_WIDTH * 5.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 3));

  teamShapes.get("Gen.G").add(createGroupRect(BRACKET_START_AT_WIDTH * 7.25, GROUP_START_AT_HEIGHT));
  teamShapes.get("MAD Lions").add(createGroupRect(BRACKET_START_AT_WIDTH * 7.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT));
  teamShapes.get("LNG Esports").add(createGroupRect(BRACKET_START_AT_WIDTH * 7.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 2));
  teamShapes.get("Team Liquid").add(createGroupRect(BRACKET_START_AT_WIDTH * 7.25, GROUP_START_AT_HEIGHT + BRACKET_PART_HEIGHT * 3));
}

void initEmptyTeamShapes() {
  teamShapes = new HashMap();
  teamShapes.put("100 Thieves", new ArrayList());
  teamShapes.put("Cloud9", new ArrayList());
  teamShapes.put("DetonatioN FocusMe", new ArrayList());
  teamShapes.put("DWG KIA", new ArrayList());
  teamShapes.put("EDward Gaming", new ArrayList());
  teamShapes.put("Fnatic", new ArrayList());
  teamShapes.put("FunPlus Phoenix", new ArrayList());
  teamShapes.put("Gen.G", new ArrayList());
  teamShapes.put("Hanwha Life Esports", new ArrayList());
  teamShapes.put("LNG Esports", new ArrayList());
  teamShapes.put("MAD Lions", new ArrayList());
  teamShapes.put("PSG Talon", new ArrayList());
  teamShapes.put("Rogue", new ArrayList());
  teamShapes.put("Royal Never Give Up", new ArrayList());
  teamShapes.put("T1", new ArrayList());
  teamShapes.put("Team Liquid", new ArrayList());
}

PShape createBracketRect(float x, float y) {
  PShape rect = createShape(PShape.PATH);
  rect.beginShape();
  rect.vertex(x, y);
  rect.vertex(x +  BRACKET_PART_WIDTH, y);
  rect.vertex(x + BRACKET_PART_WIDTH, y + BRACKET_PART_HEIGHT);
  rect.vertex(x, y + BRACKET_PART_HEIGHT);
  rect.endShape(CLOSE);
  return rect;
}

PShape createGroupRect(float x, float y) {
  PShape rect = createShape(PShape.PATH);
  rect.beginShape();
  rect.vertex(x, y);
  rect.vertex(x +  BRACKET_PART_WIDTH * 1.5, y);
  rect.vertex(x + BRACKET_PART_WIDTH  * 1.5, y + BRACKET_PART_HEIGHT);
  rect.vertex(x, y + BRACKET_PART_HEIGHT);
  rect.endShape(CLOSE);
  return rect;
}

void drawBracket() {
  textSize(30.f);
  fill(0);
  strokeWeight(1);
  text("Bracket stage:", BRACKET_START_AT_WIDTH * 0.5, BRACKET_START_AT_HEIGHT * 0.75);
  text("Group stage:", BRACKET_START_AT_WIDTH * 0.5, BRACKET_START_AT_HEIGHT * 7.2);
  boolean highlightChanged = false;
  for (String teamName : teamShapes.keySet()) {
    for (PShape shape : teamShapes.get(teamName)) {
      if (shape.contains(mouseX, mouseY)) {
        highlightedTeam = teamName;
        highlightChanged = true;
        if (mousePressed && mouseMovedAfterAdd) {
          if(selectedTeam == teamName) {
            mouseMovedAfterAdd = false;
            selectedTeam = "";
          } else {
            mouseMovedAfterAdd = false;
            selectedTeam = teamName;
          }
          
        }
      }
    }
  }

  if (!highlightChanged)
    highlightedTeam = "";

  for (String teamName : teamShapes.keySet()) {
    for (PShape shape : teamShapes.get(teamName)) {
      strokeWeight(1);
      stroke(100);
      shape.disableStyle();
      if (teamName.equals(highlightedTeam)) {
        fill(#800000);
      } else if (teamName.equals(selectedTeam)){
       stroke(#000075);
       strokeWeight(3);
       fill(#469990);
      } else {
        fill(#469990);
      }
      shape(shape);
      fill(255);
      textSize(14);  
      text(teamName, shape.getVertex(0).x + BRACKET_PART_WIDTH / 8, shape.getVertex(0).y + BRACKET_PART_HEIGHT / 3.5, shape.getVertex(3).x, shape.getVertex(3).y);
    }
  }
}

void star(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  noFill();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    line(x, y, sx, sy);
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void star2(float x, float y, ArrayList<Float> radiuses) {
  int numberOfRadiuses = radiuses.size();
  float angle = TWO_PI / numberOfRadiuses;
  beginShape();
  int i = 0;
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radiuses.get(i);
    float sy = y + sin(a) * radiuses.get(i);
    vertex(sx, sy);
    i++;
  }
  endShape(CLOSE);
}

void createBaseStar() {
  stroke(0);
  fill(0);
  strokeWeight(1);
  for (int i = 20; i <= 100; i+=20) {
    star(0, 0, float(i), 5);
  }
}

void mouseClicked(){
  parallelCoordinatesView.onMouseClickedOn(mouseX, mouseY);
  if(selectedTab.equals("Teams")) {
    sortTable(mouseX, mouseY);
  }
}

void sortTable(float x, float y) {
  if(x >  width * 0.12 && x < 2 * width * 0.12 && y < height * 0.2 && y > height * 0.15) { 
    teams.sort(0);
  }
  
  for(int i = 0; i < statsToWatch.length; i++) {
      if(x > (i + 2) * width * 0.12 && x < (i + 3) * width * 0.12 && y < height * 0.2 && y > height * 0.15) { 
        teams.sortReverse(statsToWatch[i]); //<>//
      }
  }
}

void mouseMoved(){
  mouseMovedAfterAdd = true;
  if(selectedTab == "Players") {
      parallelCoordinatesView.onMouseMovedTo(mouseX, mouseY);
  }
}
void mousePressed(){
  parallelCoordinatesView.onMousePressedAt(mouseX, mouseY);
  if (mouseY > 0 && mouseY < height * 0.04) {
    if (mouseX > 0 && mouseX <  width * 0.08) {
      selectedTab = "Bracket";
    }
    if (mouseX >  width * 0.08 && mouseX <  width * 0.16) {
      selectedTab = "Teams";
    }
    if (mouseX >  width * 0.16 && mouseX < width * 0.24) {
      selectedTab = "Players";
    }
    if (mouseX >  width * 0.24 && mouseX < width * 0.32) {
      selectedTab = "Roles";
    }
  }
}
void mouseDragged(){
  parallelCoordinatesView.onMouseDragged(pmouseX, pmouseY, mouseX, mouseY);
}
void mouseReleased(){
  parallelCoordinatesView.onMouseReleasedAt(mouseX, mouseY);
}

ArrayList<String> createLabelsFrom(String dataFilePath){
  ArrayList<String> labels = new ArrayList<String>();
  String[] lines = loadStrings(dataFilePath);
  String[] labelData = splitTokens(trim(lines[0]), ",");
  for(int i = 3; i < labelData.length; i++)
    labels.add(trim(labelData[i]));
  return labels;
}

ArrayList<String> createLabelCommentsFrom(String dataFilePath){
  ArrayList<String> comments = new ArrayList<String>();
  String[] lines = loadStrings(dataFilePath);
  String[] labelData = splitTokens(trim(lines[1]), ",");
  for(int i = 3; i < labelData.length; i++) {
    comments.add(trim(labelData[i]));
  }
  return comments;
}

ArrayList<Sample> createSamplesFrom(String dataFilePath){
  ArrayList<Sample> samples = new ArrayList<Sample>();
  String[] lines = loadStrings(dataFilePath);
  for(int i = 2; i < lines.length; i++){
    String[] data = splitTokens(trim(lines[i]), ",");
    ArrayList<Float> features = new ArrayList<Float>();
    for(int j = 3; j < data.length; j++) {
      features.add(float(trim(data[j])));
    }
    String classLabel = trim(data[2]);
    String name = trim(data[0]);
    String team = trim(data[1]);
    samples.add(new Sample(features, classLabel, name, team));
  }
  return samples;
}

void drawTeamChart() {
  stroke(0);
  strokeWeight(1);
  fill(0);
  line(width * 0.05, height * 0.2, width * 0.95, height * 0.2);
  line(width * 0.05, height * 0.15, width * 0.95, height * 0.15);
  line(width * 0.05, height * 0.78, width * 0.95, height * 0.78);
  for (int i = 1; i < statsToWatch.length + 3; i++) {
    float mx = width * 0.05 + (i - 1) * width * 0.15;
    line(mx, height * 0.15, mx, height * 0.78);
    if(i > 4 && teamStats.get(i - 3).min < 0) {
      mx = (i - 1.15) * width * 0.15;
      line(mx, height * 0.2, mx, height * 0.78);
    }
  }
  
  text("Team name", width * 0.055, height * 0.19);
  text("Average kills", width * 0.055 + 1 * width * 0.15, height * 0.19);
  text("Kill Death ratio", width * 0.055 + 2 * width * 0.15, height * 0.19);
  text("Early game rating", width * 0.055 + 3 * width * 0.15, height * 0.19);
  text("Mid/Lategame rating", width * 0.055 + 4 * width * 0.15, height * 0.19);
  text("Gold diff at 15", width * 0.055 + 5 * width * 0.15, height * 0.19);
  
  int rowCount = teams.getRowCount();  
  
  for (int row = 0; row < rowCount; row++) {
    fill(0);
    text(teams.getString(row, 0), width * 0.052, height * 0.2 + (row + 1) * height * 0.035);
    for (int i = 0; i < statsToWatch.length; i++) {
      boolean isPositive = teamStats.get(i).min > 0;
      //float mapFrom = isPositive ? teamStats.get(i).min : -1 * teamStats.get(i).max; 
      float mapFrom = isPositive ? teamStats.get(i).min : 0;
      //float mapTo = teamStats.get(i).max > teamStats.get(i).min * -1 ? teamStats.get(i).max : ;
      float rectLength = map(teams.getFloat(row, statsToWatch[i]),
                             mapFrom, isPositive ? teamStats.get(i).max : -1 * teamStats.get(i).min,
                             width * 0.125 + (i + 1)  * width * 0.15,
                             width * 0.155 + (i + 1) * width * 0.15 + width * 0.11);
      if(mouseY > height * 0.2 + row  * height * 0.035 + height * 0.01 && mouseY < height * 0.2 + (row + 1) * height * 0.035) {
        fill(#469990);
      } else {
        fill(#000075);
      }

      if(!isPositive) {
        rect(width * 0.052 + (i + 1.5)  * width * 0.15,
        height * 0.1805 + (row + 1) * height * 0.03535,
        (rectLength - (width * 0.122 + (i + 1)  * width * 0.15)) / 2,
        height * 0.015);
      } else {
        rect(width * 0.05 + (i + 1)  * width * 0.15,
        height * 0.1805 + (row + 1) * height * 0.03535,
        rectLength - (width * 0.122 + (i + 1)  * width * 0.15),
        height * 0.015);
      }

      //text(teams.getFloat(row, statsToWatch[i]), width * 0.122 + (i + 1)  * width * 0.12, height * 0.2 + row * height * 0.035);
    }
  }
}

void drawPointChart() {
  drawCoordSystem(width * 0.15, height * 0.2, height * 0.7, height * 0.7);
  drawPoints(width * 0.15, height * 0.2, height * 0.7, height * 0.7);
}

void drawCoordSystem(float xLoc, float yLoc, float cWidth, float cHeight) {
  stroke(0);
  strokeWeight(2.0);
  line(xLoc, yLoc, xLoc, yLoc + cHeight);
  line(xLoc, yLoc + cHeight, xLoc + cWidth, yLoc + cHeight);
  for(int i = 0; i <= 40; i += 1) {
    stroke(120);
    strokeWeight(0.2);
    float v = map(i, 0, 40, 0, cWidth);
    line(xLoc + v, yLoc, xLoc + v, yLoc + cHeight);
    line(xLoc, yLoc + cHeight - v, xLoc + cWidth, yLoc + cHeight - v);
  }
  
  for(int i = 0; i <= 4; i += 1) {
    stroke(120);
    strokeWeight(0.2);
    float v = map(i, 0, 4, 0, cWidth);
    text(nf(map(i, 0, 4, 0, 40), 0, 0), xLoc + v, yLoc * 4.5);
    text(nf(map(i, 0, 4, 0, 40), 0, 0), xLoc, yLoc + cHeight - v, xLoc + cWidth);
  }
  
  stroke(0);
  strokeWeight(1.0);
  pushMatrix();
  rotate(radians(-90));
  text("Gold Share: average share of team's total gold earned", -800, yLoc * 1.2);
  popMatrix();
  text("Damage share: average share of team's total damage to champions", xLoc, yLoc + cHeight + cHeight / 15);
  
  strokeWeight(5);
  
  fill(#3cb44b);
  stroke(#3cb44b);
  ellipse(xLoc + xLoc * 2.75, yLoc * 2, 10.0, 10.0);
  text("Top", xLoc + xLoc * 2.78, yLoc * 2.035);
  
  fill(#42d4f4);
  stroke(#42d4f4);
  ellipse(xLoc + xLoc * 2.75, yLoc * 2.2, 10.0, 10.0);
  text("Jungle", xLoc + xLoc * 2.78, yLoc * 2.235);
  
  fill(#f032e6);
  stroke(#f032e6);
  ellipse(xLoc + xLoc * 2.75, yLoc * 2.4, 10.0, 10.0);
  text("Middle", xLoc + xLoc * 2.78, yLoc * 2.435);
  
  fill(#f58231);
  stroke(#f58231);
  ellipse(xLoc + xLoc * 2.75, yLoc * 2.6, 10.0, 10.0);
  text("ADC", xLoc + xLoc * 2.78, yLoc * 2.635);
  
  fill(#469990);
  stroke(#469990);
  ellipse(xLoc + xLoc * 2.75, yLoc * 2.8, 10.0, 10.0);
  text("Support", xLoc + xLoc * 2.78, yLoc * 2.835);
  
  fill(#ffffff);
  stroke(#000075);
  ellipse(xLoc + xLoc * 2.75, yLoc * 3.0, 10.0, 10.0);
  fill(#000075);
  text("Teammates", xLoc + xLoc * 2.78, yLoc * 3.035);

  
}

void drawPoints(float xLoc, float yLoc, float cWidth, float cHeight) {
  int rowCount = players.getRowCount();
  strokeWeight(5);
  for (int row = 2; row < rowCount; row++) {
    String pos = players.getString(row, 2);
    String teamName = players.getString(row, 1);
    float x = map(players.getFloat(row, 20), 0, 40, 0, cWidth);
    float y = map(players.getFloat(row, 23), 0, 40, 0, cWidth);
    playerPoints.put(new Point(xLoc + x, yLoc + cHeight - y), new PlayerStat(players.getString(row, 0), players.getString(row, 1)));
    if (pos.equals("Top")) {
      fill(#3cb44b);
      stroke(#3cb44b);
    } else if (pos.equals("Jungle")) {
      fill(#42d4f4);
      stroke(#42d4f4);
    } else if (pos.equals("Middle")) {
      fill(#f032e6);
      stroke(#f032e6);
    } else if (pos.equals("ADC")) {
      fill(#f58231);
      stroke(#f58231);
    } else {
      fill(#469990);
      stroke(#469990);
    }
    
    if(selectedPlayer != null && selectedPlayer.teamName.equals(teamName))
        stroke(#000075);
    ellipse(xLoc + x, yLoc + cHeight - y, 10.0, 10.0);
  }
  
  Point closest = null;
  float prevDist = MAX_FLOAT;
  for (Point point : playerPoints.keySet()) {
    float dist = point.getDist();
    if(dist < 10.0 && prevDist > dist) {
      prevDist = dist;
      closest = point;
    }
  }
  
  if (closest != null) {
    fill(0);
    PlayerStat player = playerPoints.get(closest);
    String playerName = player.name;
    text(playerName, closest.x, closest.y);
    selectedPlayer = player;
  } else {
    selectedPlayer = null;
  } 
}

 void keyPressed() {
   if(selectedTab.equals("Players")) {
     this.parallelCoordinatesView.onKeyPressed();
   }
 }
