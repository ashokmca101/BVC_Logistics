public class Check_For_Pincode_In_Directory {
    @invocablemethod
    public static void Check_Pincode(List<Id> NonValidationAddressId){
        List<Non_Validated_Address__c> AddressList = [SELECT Id, Pincode__c, Active_Pincode__c 
                                                       FROM Non_Validated_Address__c 
                                                       WHERE Id IN :NonValidationAddressId];
        List<String> NonValidatedPincode = New List<String>();
        For(Non_Validated_Address__C A: AddressList){
            NonValidatedPincode.add(A.Pincode__c);
        }
        List<Active_Pincode__c> ActivePincodeList = [SELECT Pincodes__c FROM Active_Pincode__c 
                                                     WHERE Pincodes__c IN :NonValidatedPincode];
        List<String> ActivePincode = New List<String>();
        For(Active_Pincode__c X: ActivePincodeList){
            ActivePincode.add(X.Pincodes__c);
        }
        For(Non_Validated_Address__c NVA : AddressList){
            If(ActivePincode.Contains(NVA.Pincode__c)){
                NVA.Active_Pincode__c = TRUE;
            }
        }
        Update AddressList;
    }
}