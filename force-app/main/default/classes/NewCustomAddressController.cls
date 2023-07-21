public  class NewCustomAddressController {
    @auraEnabled public Boolean IsGstRegistered;
    
    @auraEnabled public static boolean gstStatus(String AccId){
        Account[] acc = [select id,GST_Registered__c FROM Account WHERE id=:AccId LIMIT 1];
        if(acc !=null && acc.size()==1)
            return acc[0].GST_Registered__c;
        else
            return null;
    }
    @auraEnabled
    Public static PincodeWrapper findCountryStateAndCityBasedOnPin (String Pincode) {
        system.debug('Pincode--'+Pincode);//record id of active pincode.
        List<Active_Pincode__c> activepincodedetails=[Select Country__c,State__c,District__c,City__c from Active_Pincode__c where Id=:Pincode];
        PincodeWrapper pindetails=new PincodeWrapper();
        List<String> Pincodedetails=new List<String>();
        
        
        If(activepincodedetails!=null){
            Pincodedetails.add(activepincodedetails[0].City__c);
            Pincodedetails.add(activepincodedetails[0].Country__c);
            Pincodedetails.add(activepincodedetails[0].State__c);
            Pincodedetails.add('PINCODERECEIVED');
            
       /* Pincodedetails[0]=activepincodedetails[0].City__c;
        Pincodedetails[1]=activepincodedetails[0].Country__c;
        Pincodedetails[2]=activepincodedetails[0].State__c;
        Pincodedetails[3]='PINCODERECEIVED';*/   
        pindetails.City=activepincodedetails[0].City__c;
        pindetails.District=activepincodedetails[0].District__c;
        pindetails.Country=activepincodedetails[0].Country__c;
        pindetails.State=activepincodedetails[0].State__c;
        pindetails.Status='PINCODERECEIVED';    
        }
        return pindetails;
        
    }
    
    @auraEnabled
    Public static string getCustomerMethod() {
        Id userId = UserInfo.getUserId();
        User userObj = [SELECT IsActive, Id, Name, ContactId FROM User WHERE Id = :userId];
        Contact currentContact = [SELECT Id, AccountId FROM Contact WHERE Id = :userObj.ContactId];
        if(currentContact!=null){
         string accId = currentContact.AccountId;
            return accId;
        }
        else{
            return null;
        }
        
    }
    @auraEnabled
    Public static PincodeWrapper getRecordTypeIdMethod(string recTypeId){
        PincodeWrapper pw=new PincodeWrapper();
        string recordType;
        Id ShipperRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
 		Id BillingRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        String BillingRecTypeId=BillingRecordTypeId;
        //Id ShipperAddressRecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipper Address').getRecordTypeId();
        Id userId = UserInfo.getUserId();
        User userObj = [SELECT IsActive, Id, Name, ContactId FROM User WHERE Id = :userId];
        if(userObj.ContactId != null){
            string recTypeIdNew = ShipperRecordTypeId;
        	pw.RecrdTypeId=recTypeIdNew;
            pw.NotaPortalUser=false;
        }
        else{
            If(recTypeId ==ShipperRecordTypeId){
               pw.NotaPortalUser=false; 
            }
            else{
                pw.NotaPortalUser=true;
            }
            pw.RecrdTypeId=recTypeId;
            
        }
        pw.RecordtypeName = Schema.getGlobalDescribe().get('AddressBook__c').getDescribe().getRecordTypeInfosById().get(pw.RecrdTypeId).getName();
        return pw;
    }
    Public class PincodeWrapper{
       @auraEnabled Public String City;
       @auraEnabled Public String District;
       @auraEnabled Public String Country;
       @auraEnabled Public String State;
       @auraEnabled Public String Status;
       @auraEnabled Public Boolean NotaPortalUser;
       @auraEnabled Public String RecrdTypeId;
       @auraenabled public String RecordtypeName;
    }
    
    
}