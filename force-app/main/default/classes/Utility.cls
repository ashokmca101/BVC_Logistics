public class Utility {
    public static boolean isRun = false;
    public static Id getCommunityUserAccountId(){
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        String accid=currentusr.Contact.Accountid;
        
        return accid;
    }
    public static User getUserDetails(){
        User currentusr= [Select id,Name,ContactId From User Where Id =:Userinfo.getUserId()];
       
        
        return currentusr;
    }
    public static map<String,Active_Pincode__c> getActivePinCode(){
        Map<String, Active_Pincode__c> pincodeMap = new Map<String, Active_Pincode__c>(); 
        for(Active_Pincode__c objPincode : [Select Pincodes__c ,Country__c ,District__c , State__c,City__c  From Active_Pincode__c])
        {
            pincodeMap.put(objPincode.Pincodes__c , objPincode);
        }
        system.debug(pincodeMap.size());
            
        return pincodeMap;
    } 
}