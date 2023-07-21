public class ChangeAccountRecordType {
    @InvocableMethod
	Public Static Void ChangeAccountRecordTypeMethod(List<Id> CustomerId){
        List<Account> Acc = [SELECT RecordTypeId FROM Account WHERE Id IN :CustomerId];
        List<Account> AccToUpdate = New List<Account>();
        Id QuickBillingRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Quick Billing').getRecordTypeId();
        Id QuickShippingRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Quick Shipping').getRecordTypeId();
        For(Account A : Acc){
            If(A.RecordTypeId == QuickBillingRecordId){
            	A.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 
                 A.RecordTypeId__c= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 
           		AccToUpdate.add(A); 
            }
            Else If(A.RecordTypeId == QuickShippingRecordId){
            	A.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
                  A.RecordTypeId__c= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
           		AccToUpdate.add(A); 
            }
        }
        Update AccToUpdate;
    }
}