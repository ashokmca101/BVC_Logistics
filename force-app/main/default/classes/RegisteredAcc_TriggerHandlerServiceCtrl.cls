public class RegisteredAcc_TriggerHandlerServiceCtrl {
    
    public static void createBVCPickupAddressMapping(List<Registered_Account__c> newRegAccList)
    {
        Id CustomerBillingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id AddressBillingRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Boolean newRegAdd = false;
        List<Registered_Account__c> updatedRegAccList = new List<Registered_Account__c>();
        map<Id, set<String>> mapCustToSoftId = new map<Id, set<String>>();
        Set<Id> customerIds= new Set<Id>();
        Set<String> softwareIds= new Set<String>();
        List<BVCPICKUPADDRESSMAPPING__c > newPickupAddressList = new List<BVCPICKUPADDRESSMAPPING__c >();
        map<Id, List<AddressBook__c>> newCustomerIdToAddressMap = new map<Id, List<AddressBook__c>>();
        for(Registered_Account__c registeracc: newRegAccList){
            if(registeracc.Parent_Record_TypeId__c ==  CustomerBillingRecordTypeId){
                 customerIds.add(registeracc.Customer__c);
            }
        }
        List<Account> childacclist=[select id,parentid from account where parentid IN :customerIds and recordtypeid=:CustomerBillingRecordTypeId];
        system.debug('ChildAccountList::'+childacclist); 
        for(Account acc:childacclist) {
             if(acc.parentid!=null){
                 customerIds.add(acc.Id);
             }
         }
        system.debug('customerIds::'+customerIds);
        system.debug('softwareIds::'+softwareIds);
        
        List<AddressBook__c> relatedAddressList = [Select id,Customer__c ,customer__r.Parentid,Address_Number__c from AddressBook__c
                                                   WHERE Customer__c =:customerIds and Customer__r.RecordtypeId=:CustomerBillingRecordTypeId and RecordTypeId=:AddressBillingRecordTypeId];
        system.debug('relatedAddressList='+relatedAddressList);
        for(AddressBook__c address:relatedAddressList){
            if(address.customer__r.parentid==null){
                if(newCustomerIdToAddressMap.containsKey(address.Customer__c)){
                	newCustomerIdToAddressMap.get(address.Customer__c).add(address);
            	}else{
                	newCustomerIdToAddressMap.put(address.Customer__c,new List<AddressBook__c>{address});
            	}
            }else{
                if(newCustomerIdToAddressMap.containsKey(address.customer__r.Parentid)){
                	newCustomerIdToAddressMap.get(address.customer__r.Parentid).add(address);
            	}else{
                	newCustomerIdToAddressMap.put(address.customer__r.Parentid,new List<AddressBook__c>{address});
            	}
            }
        }
        for(Registered_Account__c  registeracc: newRegAccList){
           
                    if(newCustomerIdToAddressMap.containskey(registeracc.Customer__c) && registeracc.Parent_Record_TypeId__c ==  CustomerBillingRecordTypeId){
                        for(AddressBook__c address:newCustomerIdToAddressMap.get(registeracc.Customer__c)){
                            BVCPICKUPADDRESSMAPPING__c obj = new BVCPICKUPADDRESSMAPPING__c();
                            obj.Address_ID__c = address.Id;
                            obj.Address__c = address.Id;
                            obj.Address_Number__c = address.Address_Number__c;
                            obj.AWS_Sync_Status__c = registeracc.AWS_SYNC_Status__c;
                            obj.BVC_Company_ID__c = registeracc.BVC_Company_ID__c;
                            obj.BVCSoftwareID__c = registeracc.BVC_Software_Id__c;
                            obj.Customer__c = registeracc.Customer__c;
                            obj.Registered_Account_Id__c = registeracc.Id;
                            obj.ExternalID__c = address.Address_Number__c+registeracc.BVC_Company_ID__c+registeracc.BVC_Software_Id__c;
                            SYstem.debug( 'externalid'+obj.ExternalID__c);
                            newPickupAddressList.add(obj);
                        }
                    }
            }
            
        system.debug('newPickupAddressList:::'+newPickupAddressList.size());
        upsert newPickupAddressList ExternalID__c;
        
       
        
    }
     public static void createPICKUPADDRESSMAPPING(List<Registered_Account__c> newRegAccList){
        Id CustomerBillingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id AddressBillingRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Set<Id> customerIds= new Set<Id>();
        List<Pickup_Address_Mapping__c > newPickupAddressList = new List<Pickup_Address_Mapping__c >();
        map<Id, List<AddressBook__c>> newCustomerIdToAddressMap = new map<Id, List<AddressBook__c>>();
        for(Registered_Account__c registeracc: newRegAccList){
            if(registeracc.Parent_Record_TypeId__c ==  CustomerBillingRecordTypeId){
               customerIds.add(registeracc.Customer__c);
         	}
        }
        List<Account> childacclist=[select id,parentid from account where parentid IN :customerIds and recordtypeid=:CustomerBillingRecordTypeId];
         for(Account acc:childacclist) {
             if(acc.parentid!=null){
                 customerIds.add(acc.Id);
             }
         } 
        List<AddressBook__c> relatedAddressList = [Select id,Customer__c ,customer__r.Parentid,Address_Number__c,Oracle_Site_ID__c from AddressBook__c
                                                   WHERE Customer__c =:customerIds and  Customer__r.RecordtypeId=:CustomerBillingRecordTypeId and RecordTypeId=: AddressBillingRecordTypeId];
        system.debug('relatedAddressList '+relatedAddressList);
         for(AddressBook__c address:relatedAddressList){
            if(address.customer__r.Parentid==null){
               if(newCustomerIdToAddressMap.containsKey(address.Customer__c)){
                	newCustomerIdToAddressMap.get(address.Customer__c).add(address);
                }else{
                    newCustomerIdToAddressMap.put(address.Customer__c,new List<AddressBook__c>{address});
                } 
            }
            else{
                if(newCustomerIdToAddressMap.containsKey(address.customer__r.Parentid)){
                	newCustomerIdToAddressMap.get(address.customer__r.Parentid).add(address);
                }else{
                    newCustomerIdToAddressMap.put(address.customer__r.Parentid,new List<AddressBook__c>{address});
                } 
            }
                
        }
        for(Registered_Account__c  registeracc: newRegAccList){
            if(newCustomerIdToAddressMap.containskey(registeracc.Customer__c) && registeracc.Parent_Record_TypeId__c ==  CustomerBillingRecordTypeId ){
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
        system.debug('newPickupAddressList size='+newPickupAddressList.size());
        Database.upsert(newPickupAddressList,false);
        //upsert  newPickupAddressList External_Id__c;
    }

}