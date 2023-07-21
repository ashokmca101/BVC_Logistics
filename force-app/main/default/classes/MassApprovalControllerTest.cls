@isTest
private  class MassApprovalControllerTest {
    
    @testSetup static void setup() {
        
        /*Account acc = new 	Account();
        acc.Name = 'testaccount';
        acc.PAN_Number_of_Entity__c='djzst12345';
        acc.Name_As_Per_PAN_Manual_Input__c = 'testpannumber';
        insert acc;
        
        
        blng__CreditNote__c creditnotes = new blng__CreditNote__c();
        
        creditnotes.blng__Account__c = acc.Id;
        creditnotes.blng__CreditNoteDate__c= Date.today();
        creditnotes.Internal_Comments__c='no Comments' ;
        creditnotes.Remark__c = 'no Remark';
        creditnotes.Reason_for_Credit_Note__c='ACR Billing';
        
        insert creditnotes;*/
        
    } 
  @isTest
    
    private static void testmethod1(){
        
        Test.startTest();
        MassApprovalRejectionController.Method2();
        
        /*  blng__CreditNote__c creditnotes = [SELECT Id,blng__Account__c,blng__CreditNoteDate__c,Internal_Comments__c,Remark__c,Reason_for_Credit_Note__c FROM blng__CreditNote__c WHERE Reason_for_Credit_Note__c='ACR Billing' LIMIT 1 ];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(creditnotes.Id);
        req1.setSubmitterId('0055g00000BUBhjAAH'); 
        req1.setProcessDefinitionNameOrId('CreditNote_Amount_Less_than_10k');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        list<ProcessInstance> p =  [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate FROM ProcessInstance ];
        list<ProcessInstanceWorkItem> pw= [SELECT id,ProcessInstanceId,OriginalActorId FROM ProcessInstanceWorkItem ];
        list<ProcessInstanceStep> ps = [SELECT id,ProcessInstanceId,OriginalActorId,StepStatus FROM ProcessInstanceStep ];
        system.debug('query p-->'+ p);
        system.debug('query pw-->'+ pw);
        system.debug('query ps-->'+ ps);
        
        list<string> lstWorkItemIds = new list<string>();
        lstWorkItemIds.add(pw[0].Id);
        
        MassApprovalRejectionController.getSubmittedRecords();
        MassApprovalRejectionController.processRecords(lstWorkItemIds, 'Approve');*/
        
        
        Test.stopTest();  
        
    }
    
    
}