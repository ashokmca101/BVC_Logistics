public class UpdateCustomerBillingAddressHelper {
    @invocablemethod
    public static void UpdateAddress(List<RequestParam> Params){
    	
        String CurrentAddressId = Params[0].AddressId;
        String CurrentCustomerId = Params[0].CustomerId;
        List<AddressBook__c> AddressList = new List<AddressBook__c>();
        AddressList = [Select Customer__c,Is_Primary__c, Is_Multiple_Address__c from AddressBook__c WHERE Customer__c = :CurrentCustomerId 
                       AND Is_Primary__c = True 
                       AND Id != :CurrentAddressId];
   		
		List<AddressBook__c> AddressListNew = new List<AddressBook__c>();
            
        Integer count = 0;
        if(AddressList != Null){
        For(AddressBook__c I : AddressList){
            If (I.Is_Primary__c == TRUE){
                I.Is_Primary__c = FALSE;
                I.Is_Multiple_Address__c = TRUE;
                AddressListNew.Add(I);
                
            }   
            
        }
        
        Update AddressListNew;
    }
    }
    public class RequestParam {
        @InvocableVariable()
        public String CustomerId;
        
        @InvocableVariable()
        public String AddressId;
        
    }
}