public class TMS_UpdatePincode {
    
    @InvocableMethod
    public static void updatePincode(List<AddressBook__c> addressBookList){
        List<AddressBook__c> tempDataUpdate = new  List<AddressBook__c>();
        for( AddressBook__c addressBookRecord :  addressBookList){
            
            AddressBook__c tempBook = new AddressBook__c();
            tempBook.Id = addressBookRecord.Id; 
            tempBook.Pincode_TMS__c = getPincodeId(addressBookRecord.PINCODE__c);
            tempDataUpdate.add(tempBook);
        }
        
        if(tempDataUpdate.size() > 0){
            Database.SaveResult [] result = Database.update(tempDataUpdate , false);
            System.debug('===== '+tempDataUpdate);
        }  
    }
    
    public static String getPincodeId(String addressBookRecord){     
        System.debug('==addressBookRecord=== '+addressBookRecord);
        Active_Pincode__c [] activePincode = [ SELECT Id, Name FROM Active_Pincode__c WHERE  Name =:addressBookRecord LIMIT 1 ];
        //System.debug('==activePincode[0].Id=== '+activePincode[0].Id);
        return activePincode.size() > 0 ? activePincode[0].Id : ''; 
    }
}