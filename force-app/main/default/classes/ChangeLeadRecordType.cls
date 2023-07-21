public class ChangeLeadRecordType {
	@InvocableMethod
	Public Static Void ChangeLeadRecordTypeMethod(List<Id> LeadId){
        List<Lead> LeadList = [SELECT RecordTypeId FROM Lead WHERE Id IN :LeadId];
        List<Lead> LeadToUpdate = New List<Lead>();
        For(Lead L : LeadList){
           L.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BVC Lead').getRecordTypeId(); 
           LeadToUpdate.add(L); 
        }
        Update LeadToUpdate;
    }
}