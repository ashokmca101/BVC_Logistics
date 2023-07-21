public class updateAwbHelper {
    public static void Indigo(List<Linehaul__c> indigoList) {
    // update linehaul record from Indigo_createAwb apex class.
    // updates AWB_Number__c,Flight_No_for_SpiceJet_Indigo__c and Booked_Flight_For_AWB__c fields 
     List<Linehaul__c> finalIndigoList = new List<Linehaul__c>();
        finalIndigoList.addALL(indigoList);
        
        update finalIndigoList;
    }
    public static void Spicejet(List<Linehaul__c> spicejetList) {
   // updates AWB_Number__c field      
      List<Linehaul__c> finalSpiceJetList = new List<Linehaul__c>();
        finalSpiceJetList.addAll(spicejetList);
        update finalSpiceJetList;
    }
}