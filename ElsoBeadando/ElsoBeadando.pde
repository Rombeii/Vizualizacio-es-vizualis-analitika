import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.*;
import javafx.util.Pair;

//SVG adatok
PShape europe;
int rowCount;
int svgWidth = 1200;
int svgOffset = -100;

Integer min = 0;
Integer max = 0;

//Dátumok
LocalDate minDate;
LocalDate maxDate;
DateTimeFormatter dtf;
int daysBetween;

//Segédváltozók
boolean mouseMovedAfterAdd;
List selectedCountries;

//Scrollbar
int barStart;
int barEnd;
HScrollbar hs;

//Koordináta-rendszer
int cHeightLoc;
int cSize = 350;
int selectedMax;

//Gradient
int Y_AXIS = 1;
int X_AXIS = 2;
color b1, b2, c1, c2;


color[] colors = {color(230, 25, 75), color(0, 0, 128), color(255, 225, 25), color(240, 50, 230), color(60, 180, 75)};

ArrayList<CountryData> countryData = new ArrayList();
HashMap<String, List<Pair<Float, Integer>>> countryPoints = new HashMap();

void setup() {
  size(1500, 700);
  //fullScreen();
  barStart = 10;
  barEnd = svgWidth - 200;
  cHeightLoc = height / 3 * 2;
  dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
  selectedCountries = new ArrayList();
  
  europe = loadShape("europe.svg");
  try {
    initCountryData();
    daysBetween = (int) ChronoUnit.DAYS.between(minDate, maxDate) + 1;
  } catch (Exception e) {
    print("nem sikerült beolvasni a dátumokat a formátum miatt");
  }
  
  hs = new HScrollbar(barStart, height - 40, barEnd, 16, 1); 
}

void draw() {
  background(255);
  drawTitle();
  drawEuropeSvg();
  drawScrollbar();
  drawDates();
  
  drawVerticalLine();
  drawCoordinateSystem();
  drawPoints();
  drawGradients();
}



void drawTitle() {
  fill(100);
  textSize(30);
  text("New Cases Per Million", 3, 25);
}

void drawEuropeSvg()  {
 HashMap<String, Integer> summedCases = new HashMap();
 min = 99999999;
 max = 0;
 selectedMax = 0;
 
 //kiszámoljuk az összegeket, hogy tudjunk min-t és max-ot számolni
 for (int i = 0; i < this.countryData.size(); i++) {
   String isoCode = this.countryData.get(i).iso_code;
    PShape tempState = europe.getChild(isoCode);
    if(tempState == null) {
      continue;
    }
   String abbrev = this.countryData.get(i).iso_code;
   Integer sum = this.countryData.get(i).getSumBetweenDates(getPos1AsDate(), getPos2AsDate());
   summedCases.put(abbrev, sum);
     
   if(sum < min) {
     min = sum;
   }
     
   if(sum > max) {
     max = sum;
   }
   
   if(selectedCountries.contains(isoCode)) {
     List points = new ArrayList();
     
     HashMap<LocalDate, Integer> caseData = this.countryData.get(i).data;
     LocalDate currDate = getPos1AsDate();
     int j = 0;
     while (currDate.isBefore(getPos2AsDate().plusDays(1))) {
       if(caseData.containsKey(currDate)) {
         Integer casesForCurrDate = caseData.get(currDate);
         Float x = map(j, 0, (int) ChronoUnit.DAYS.between(getPos1AsDate(), getPos2AsDate()) + 1, 1100, 1100 + cSize);
         //Float y = map(casesForCurrDate, 0, 2000, cHeightLoc, cHeightLoc - cSize);
         points.add(new Pair(x, casesForCurrDate));
         //point(x, y);
         if(casesForCurrDate > selectedMax) {
           selectedMax = casesForCurrDate;
         }
       }
       currDate = currDate.plusDays(1);
       j++;
     }
     countryPoints.put(isoCode, points);
     strokeWeight(1);
    }
   
 }
 
  for (Map.Entry<String, Integer> me : summedCases.entrySet()) {
    PShape tempState = europe.getChild(me.getKey());
    if(tempState == null) {
      continue;
    }
    
    float cases = me.getValue();
    strokeWeight(1);
    stroke(100);
    
    tempState.disableStyle();
    if (cases >= 0) {
      //nem olyan jó színezés
      //float a = map(cases, 0, max, 0, 255);
      //fill(#333366, a);
      float percent = norm(cases, min, max);
      //viridis
      //color between = lerpColors(percent,#fde725, #90d743, #35b779, #21918c, #31688e, #443983, #440154);
      //magma
      color between = lerpColors(percent, #fcfdbf, #feb078, #f1605d, #b73779, #721f81, #2c115f, #000004);
      fill(between);
    }
    
    if(tempState.contains(mouseX - svgOffset, mouseY)) {
      if(mousePressed && mouseMovedAfterAdd && hs.locked == 0) {
        if(selectedCountries.contains(me.getKey())) {
          selectedCountries.remove(me.getKey());
          countryPoints.remove(me.getKey());
          mouseMovedAfterAdd = false;
        } else if(!selectedCountries.contains(me.getKey()) && selectedCountries.size() < colors.length){
          selectedCountries.add(me.getKey());
          mouseMovedAfterAdd = false;
        }
      }
    }
    
    if(selectedCountries.contains(me.getKey())) {
      strokeWeight(3);
      stroke(colors[selectedCountries.indexOf(me.getKey())]);
    }
    
    shape(tempState, svgOffset, 0);
  }
}

LocalDate getPos1AsDate() {
  return minDate.plusDays((int)map(hs.getPos1(), barStart, barEnd - 5, 0, daysBetween));
}

LocalDate getPos2AsDate() {
  return minDate.plusDays((int)map(hs.getPos2(), barStart, barEnd  - 5, 0, daysBetween));
}

void drawScrollbar() {
  hs.update();
  hs.display();
}

void mouseMoved() {
  mouseMovedAfterAdd = true;
}

void initCountryData() throws Exception {
  Table dataTable = loadTable("covidData.csv");
  rowCount = dataTable.getRowCount();
  String currentCountryCode = null;
  HashMap<LocalDate, Integer> caseCount = new HashMap(); 
 
  minDate = LocalDate.parse(dataTable.getString(1, 3), dtf);
  maxDate = LocalDate.parse(dataTable.getString(rowCount - 1, 3), dtf);
  
  for (int row = 1; row < rowCount; row++) {
    String countryCode = dataTable.getString(row, 0);
    if(!countryCode.equals(currentCountryCode)) {
      if(currentCountryCode != null) {
        countryData.add(new CountryData(currentCountryCode, caseCount));
        caseCount = new HashMap();
      }
      currentCountryCode = countryCode;
    }
    caseCount.put(LocalDate.parse(dataTable.getString(row, 3), dtf), dataTable.getInt(row, 12));
  }
  countryData.add(new CountryData(currentCountryCode, caseCount));
}

void drawDates() {
  textSize(20);
  text(getPos1AsDate().toString(), svgWidth /2 - 150 + svgOffset, height - 10);
  text("-", svgWidth/2 + svgOffset, height - 10);
  text(getPos2AsDate().toString(), svgWidth /2 + 35 + svgOffset, height - 10); 
}

void drawVerticalLine() {
  stroke(0);
  strokeWeight(1);
  line(1050, 0, 1050, height);
}

void drawCoordinateSystem() {
  if(selectedMax != 0) {
    line(1100, cHeightLoc, 1100 + cSize, cHeightLoc);
    line(1100, cHeightLoc - cSize, 1100, cHeightLoc);
    text("0", 1080, cHeightLoc + 5);
    text(selectedMax, 1080, cHeightLoc - cSize - 5);
  } else {
    textSize(40);
    text("Choose a country!", 1100, 350);
  }
}

void drawPoints() {
  strokeWeight(5);
  for(Map.Entry<String, List<Pair<Float, Integer>>> me : countryPoints.entrySet()) {
    noFill();
    beginShape();
    stroke(colors[selectedCountries.indexOf(me.getKey())]);
    for(Pair<Float, Integer> point : me.getValue()) {
      //point(point.getKey(), map(point.getValue(), 0, selectedMax, cHeightLoc, cHeightLoc - cSize));
      vertex(point.getKey(), map(point.getValue(), 0, selectedMax, cHeightLoc, cHeightLoc - cSize));
    }
    endShape();
    fill(colors[selectedCountries.indexOf(me.getKey())]);
    text(me.getKey(), 1150 + selectedCountries.indexOf(me.getKey()) * 60, cHeightLoc + 50 );
  }
  strokeWeight(1);
  stroke(100);
}

//https://discourse.processing.org/t/how-do-i-cycle-lerp-between-multiple-colors/13441/4
color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cunit = 1.0/(colors.length-1);
  return lerpColor(colors[floor(amt / cunit)], colors[ceil(amt / cunit)], amt%cunit/cunit);
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}

void drawGradients() {
  
  //#fcfdbf, #feb078, #f1605d, #b73779, #721f81, #2c115f, #000004
  fill(100);
  textSize(15);
  text(min.toString(), 947, 475);
  text(max.toString(), 947, 25);
  setGradient(950, 30, width/30, height/10, color(#000004), color(#2c115f), Y_AXIS);
  setGradient(950, height/10 + 30, width/30, height/10, color(#2c115f), color(#721f81), Y_AXIS);
  setGradient(950, height/10 * 2 + 30, width/30, height/10, color(#721f81), color(#b73779), Y_AXIS);
  setGradient(950, height/10 * 3 + 30, width/30, height/10, color(#b73779), color(#f1605d), Y_AXIS);
  setGradient(950, height/10 * 4 + 30, width/30, height/10, color(#f1605d), color(#feb078), Y_AXIS);
  setGradient(950, height/10 * 5 + 30, width/30, height/10, color(#feb078), color(#fcfdbf), Y_AXIS);
}
