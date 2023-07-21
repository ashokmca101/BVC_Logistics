public class CurrentRecordIdDemoController{
public String currentRecordId {get;set;}
public Opportunity opp{get;set;}
 
    public CurrentRecordIdDemoController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        opp = [select id ,name from Opportunity where id =: currentRecordId ];
    }
}