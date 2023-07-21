public class CheckGSTINHelper {
    
    public static void CheckGstin(List<AddressBook__c> A){
        For(AddressBook__c Add : A){
        List<Account> AccList = [SELECT PAN_Number_of_Entity__c FROM Account where Id = :Add.Customer__c];
        
        String GstIn = Add.GSTIN__c;
        String PanNo;
        For(Account Acc : AccList){
            PanNo = Acc.PAN_Number_of_Entity__c;            
        }
        If((Add.Source__c != 'KARZAA') && (!(GstIn.Contains(PanNo)))){
            Add.addError('GSTIN does not contain the PAN Number');
        }
    }
    }
}