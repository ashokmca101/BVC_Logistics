public without sharing class AddressForPickupAuraController {
    
    @AuraEnabled
    Public static Wrapper getAddressList(){
        //get all Address list related to current user
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        String accid= getCustomerId();
        //String accid='0011m00000HCHfyAAH';
        List<AddressBook__c> addrList;
        if(accid != null){
            addrList = [SELECT Id, Name ,Customer__r.Id FROM AddressBook__c WHERE Customer__r.Id=:accid];
        }
        Wrapper wrap = new Wrapper();
        wrap.customerId= accid;
        wrap.addressList = new List<AddressBook__c>();
        wrap.addressList = addrList;
        return wrap;
    }
    @AuraEnabled
    Public static void insertPickupData1(List<String> selectedAddressId,Id customerId){
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        String accid= getCustomerId();
        //system.debug('pickup'+pickupMap);
        List<Pickup__c> newPickupList = new  List<Pickup__c>();
        for(String addressId:selectedAddressId){
            Pickup__c record = new Pickup__c();
            record.Customer__c = customerId;
            record.Pickup_Time__c = System.now();
            //record.Name = accid;
            //record.Shipper_Address_ID__c
            ////date time
            //shippername = String accid= getCustomerId();
            //shipperaddress
            record.Pickup_Address__c = addressId;
            system.debug(record);
            //insert record;//DML inside loop to escape from list exception of two identical record in one list
            newPickupList.add(record);
        }
        insert newPickupList;
    }
   
    public static String getCustomerId(){
        return Utility.getCommunityUserAccountId();
    }
    public Class Wrapper{
        @AuraEnabled
        public String customerId;
        @AuraEnabled
        public List<AddressBook__c> addressList;
         
    }
}