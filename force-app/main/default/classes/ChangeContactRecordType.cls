public class ChangeContactRecordType {
	@InvocableMethod
	Public Static Void ChangeContactRecordTypeMethod(List<Id> ContactId){
        List<Contact> ContactList = [SELECT RecordTypeId FROM Contact WHERE Id IN :ContactId];
        List<Contact> ContactToUpdate = New List<Contact>();
        For(Contact C : ContactList){
           C.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact Record Type').getRecordTypeId(); 
           ContactToUpdate.add(C); 
        }
        Update ContactToUpdate;
    }
}