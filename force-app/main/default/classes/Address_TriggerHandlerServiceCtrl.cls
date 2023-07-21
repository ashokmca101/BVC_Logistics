public class Address_TriggerHandlerServiceCtrl {
    private static boolean run = true;
    public static void updateBillingAddressCheckBox(List<AddressBook__c> newAddress)
    {
        List<Account> lstAcc = new List<Account>();
        SET<Id> setAcc = new SET<Id>();
        Account accObj = new Account();
        for(AddressBook__c addObj : newAddress)
        {
            setAcc.add(addObj.Customer__c);
           
        }
        Boolean checkFlag = false;
        List<AddressBook__c> lstAddress = [SELECT Id,Customer__c,Is_Billing_Address__c,RecordType.Name
                                           FROM AddressBook__c
                                           WHERE Customer__c =:setAcc ];
        for(AddressBook__c addObjNew : lstAddress)
        {
            if(addObjNew.RecordType.Name == 'Billing')
            {
                checkFlag = true;
               
            }
        }
            if(checkFlag == true)
            {
                updateAccount(setAcc, true);
            }
        if(checkFlag == false)
            {
                updateAccount(setAcc, false);
            }
        system.debug('lstAcc::'+lstAcc);
        //update accObj;    
    }
    
    

     public static void createPICKUPADDRESSMAPPING(List<AddressBook__c> newAddressList){
        Id AddressBillingRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id CustomerBillingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       
         Set<Id> customerIds= new Set<Id>();
        List<Pickup_Address_Mapping__c > newPickupAddressList = new List<Pickup_Address_Mapping__c >();
        map<Id, List<AddressBook__c>> newCustomerIdToAddressMap = new map<Id, List<AddressBook__c>>();
        Set<Id> parentCustomers = new Set<Id> ();
        
        for(AddressBook__c newaddress: newAddressList){
            
            //if address is getting created for parent customer
            if(AddressBillingRecordTypeId == newaddress.RecordTypeId && newaddress.Parent_Record_TypeId__c ==CustomerBillingRecordTypeId ){
               //if address is getting created for child customer
                String customerId;
                if(newaddress.Parent_Customer_Id__c !=null && newaddress.Parent_Customer_Id__c !='' 
                   && newAddress.Parent_Customer_Record_Type_Id__c == CustomerBillingRecordTypeId){
                    customerIds.add(newaddress.Parent_Customer_Id__c);
                    customerId = newaddress.Parent_Customer_Id__c;
                }
                else {
                    customerIds.add(newaddress.Customer__c);
                    customerId = newaddress.Customer__c;
                }
                
                if(newCustomerIdToAddressMap.containsKey(customerId)){
                    newCustomerIdToAddressMap.get(customerId).add(newaddress);
                }else{
                    newCustomerIdToAddressMap.put(customerId,new List<AddressBook__c>{newaddress});
                }
            }
            
        }
        List<Registered_Account__c> relatedRegisteredAccList = [Select id,Customer__c ,BVC_Company_ID__c from Registered_Account__c WHERE Customer__c =:customerIds];
        
		for(Registered_Account__c  registeracc: relatedRegisteredAccList){
            if(newCustomerIdToAddressMap.containskey(registeracc.Customer__c)){
                for(AddressBook__c address:newCustomerIdToAddressMap.get(registeracc.Customer__c)){
                    Pickup_Address_Mapping__c obj = new Pickup_Address_Mapping__c();
                    obj.Address_ID__c = address.Id;
                     obj.Address__c = address.Id;
                    obj.Registered_Account_ID__c = registeracc.Id;
                    obj.AWS_SYNC_Status__c = 'Pending';
                    obj.Address_Number__c = address.Address_Number__c;
                    obj.BVC_Company_ID__c = registeracc.BVC_Company_ID__c;
                    obj.Oracle_Site_ID__c = address.Oracle_Site_ID__c;
                     obj.Customer__c = registeracc.Customer__c;
                    obj.External_Id__c = registeracc.BVC_Company_ID__c+address.Address_Number__c;
                    newPickupAddressList.add(obj);
               }
            }
            
        }
         System.debug('newPickupAddressList'+newPickupAddressList);
        Database.upsert(newPickupAddressList,false);
        
  } 
    
    public static void addressPickupMappingCreation(List<AddressBook__c> newAddressList) {
         Id AddressBillingRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id CustomerBillingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Map<String,Registered_Account__c> mapSoftIdRegAcc = new Map<String,Registered_Account__c>();
        Set<Id> customerIds= new Set<Id>();
        List<Registered_Account__c> registerAccList = new List<Registered_Account__c>();
        List<BVCPICKUPADDRESSMAPPING__c > newPickupAddressList = new List<BVCPICKUPADDRESSMAPPING__c >();
        map<Id, List<AddressBook__c>> newCustomerIdToAddressMap = new map<Id, List<AddressBook__c>>();
        for(AddressBook__c newaddress: newAddressList){
            if(AddressBillingRecordTypeId == newaddress.RecordTypeId && newaddress.Parent_Record_TypeId__c == CustomerBillingRecordTypeId){
                //customerIds.add(newaddress.Customer__c);
                 String customerId;
                if(newaddress.Parent_Customer_Id__c !=null && newaddress.Parent_Customer_Id__c !='' 
                   && newAddress.Parent_Customer_Record_Type_Id__c == CustomerBillingRecordTypeId){
                    customerIds.add(newaddress.Parent_Customer_Id__c);
                    customerId = newaddress.Parent_Customer_Id__c;
                }
                else {
                    customerIds.add(newaddress.Customer__c);
                    customerId = newaddress.Customer__c;
                }
                
                
                if(newCustomerIdToAddressMap.containsKey(customerId)){
                    newCustomerIdToAddressMap.get(customerId).add(newaddress);
                }else{
                    newCustomerIdToAddressMap.put(customerId,new List<AddressBook__c>{newaddress});
                }
            }
            
        }
        
        system.debug('newCustomerIdToAddressMap:::'+newCustomerIdToAddressMap);
        List<Registered_Account__c> relatedRegisteredAccList = [Select Id,Name,BVC_Software_Id__c,Customer__c,AWS_SYNC_Status__c,BVC_Company_ID__c  from Registered_Account__c WHERE Customer__c =:customerIds ];
        
       
        system.debug('relatedRegisteredAccList::'+relatedRegisteredAccList.size());
        
		for(Registered_Account__c  regAccount: relatedRegisteredAccList){
            if(newCustomerIdToAddressMap.containskey(regAccount.Customer__c)){
                for(AddressBook__c address:newCustomerIdToAddressMap.get(regAccount.Customer__c)){
                    BVCPICKUPADDRESSMAPPING__c obj = new BVCPICKUPADDRESSMAPPING__c();
                    obj.Address_Id__c = address.Id;
                     obj.Address__c = address.Id;
            		obj.Address_Number__c = address.Address_Number__c;
                    obj.AWS_Sync_Status__c = 'Pending';
                    obj.BVC_Company_ID__c = regAccount.BVC_Company_ID__c;
                    obj.BVCSoftwareID__c =regAccount.BVC_Software_Id__c;
                    obj.Customer__c = regAccount.Customer__c;
                	obj.Registered_Account_Id__c = regAccount.Id;
                    
                	obj.ExternalID__c =address.Address_Number__c+regAccount.BVC_Company_ID__c+regAccount.BVC_Software_Id__c;
                    SYstem.debug('External Id'+obj.ExternalID__c);
                    newPickupAddressList.add(obj);
               }
            }
        }
        
        System.debug('newPickupAddressList'+newPickupAddressList);
       upsert newPickupAddressList ExternalID__c; 
    }
    public static void updateAccount(Set<Id> setAcc, boolean b){
         List<Account> lstAccUpdate = [SELECT Id,Is_Billing_Address_Present__c 
                                           FROM Account
                                           WHERE Id =:setAcc ];
                for(Account acc:lstAccUpdate)
                {
                    acc.Is_Billing_Address_Present__c = b;
                }
                system.debug('lstAccUpdate::'+lstAccUpdate);
                system.debug('lstAccUpdate Size::'+lstAccUpdate.size());
                
                update lstAccUpdate;
    }
}