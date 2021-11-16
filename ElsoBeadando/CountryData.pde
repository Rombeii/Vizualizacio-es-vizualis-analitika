import java.util.Map;
import java.time.LocalDate;

public class CountryData {
  String iso_code;
  HashMap<LocalDate, Integer> data;
  
  CountryData(String iso_code, HashMap<LocalDate, Integer> data) {
    this.iso_code = iso_code;
    this.data = data;
  }
  
  public void print() {
    println(iso_code);
    for (Map.Entry me : this.data.entrySet()) {
    println(me.getKey() + " is ");
    println(me.getValue());
    }
  }
  
  public Integer getSumBetweenDates(LocalDate from, LocalDate to) {
    Integer sum = 0;
    for (Map.Entry<LocalDate, Integer> me : this.data.entrySet()) {
      LocalDate dateToCheck = me.getKey();
      
      boolean dateIsBetween = dateToCheck.isAfter(from) && dateToCheck.isBefore(to);
      boolean dateIsOn = dateToCheck.equals(from) || dateToCheck.equals(to);
      
      if(dateIsBetween || dateIsOn) {
        sum += me.getValue();
      }
    }
    return sum;
  }
  
}
