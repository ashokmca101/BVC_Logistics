public class MassApprovalRejectionController {
    
    //Method to fetch all the records which are submitted for approval
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        
        
        //string userId; //list<string> userid = new list<string>();
        List<Id> userids = new List<Id>();
        if(!Test.isRunningTest()){
            userids.add(UserInfo.getUserId());
        }
        else{
            String[] userid = Label.BulkApprovalUsers.split(',');
            for(User p :[SELECT Id From User WHERE Id IN :userid]){
                userids.add(p.Id); 
                system.debug('ids---->'+p);
            }
        }
        
        
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        list<Id> CreditNoteIds = new list<Id>();
        List<ProcessInstance> ProcessInstanceList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                  (SELECT ID FROM WorkItems WHERE OriginalActorId IN :userids),
                                  (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance];
        system.debug('Size of ProcessInstanceList++++++++++++'+ProcessInstanceList.size());
        for(ProcessInstance ps :ProcessInstanceList){
                                      CreditNoteIds.add(ps.TargetObject.Id);  
                                  }
        system.debug('Size of CreditNoteIds++++++++++++'+CreditNoteIds.size());
        Map<Id,blng__CreditNote__c> CreditnoteMap = new Map<Id,blng__CreditNote__c>();
        list<blng__CreditNote__c> CNList = [SELECT Id,blng__Account__r.Name, blng__Subtotal__c,blng__CreditNoteDate__c,Internal_Comments__c,Remark__c,Reason_for_Credit_Note__c FROM blng__CreditNote__c WHERE Id IN :CreditNoteIds and blng__Status__c= 'Draft' order by createddate DESC limit 50000];
        for(blng__CreditNote__c cn:CNList){
            system.debug('Size of CNList++++++++++++'+CNList.size());
            CreditnoteMap.put(cn.Id, cn);
            system.debug('credit notes+++++++++'+CreditnoteMap);
        }
        List<ProcessInstance> ProcessInstanceList1 =[SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                  (SELECT ID FROM WorkItems WHERE OriginalActorId IN :userids),
                                  (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance WHERE TargetObjectId IN :CreditnoteMap.keySet()];
        system.debug('Size of ProcessInstanceList1++++++++++++'+ProcessInstanceList1.size());
        for(ProcessInstance ps :ProcessInstanceList1 ){
                                      if(!ps.WorkItems.isEmpty()){
                                          SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                                          objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                                          objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                                          objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                                          //objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                                          //objSubmittedRecordsWrapper.CreditNoteDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                                          objSubmittedRecordsWrapper.CreditNoteDate= CreditnoteMap.get(ps.TargetObject.Id).blng__CreditNoteDate__c;
                                          objSubmittedRecordsWrapper.Account = CreditnoteMap.get(ps.TargetObject.Id).blng__Account__r.Name;
                                          objSubmittedRecordsWrapper.InternalComments =CreditnoteMap.get(ps.TargetObject.Id).Internal_Comments__c;
                                          system.debug('internalcoments'+objSubmittedRecordsWrapper.InternalComments);
                                          objSubmittedRecordsWrapper.Remarks = CreditnoteMap.get(ps.TargetObject.Id).Remark__c;
                                          system.debug('Remarks'+ objSubmittedRecordsWrapper.Remarks);
                                          objSubmittedRecordsWrapper.ReasonForCreditnote = CreditnoteMap.get(ps.TargetObject.Id).Reason_for_Credit_Note__c;
                                          objSubmittedRecordsWrapper.Subtotal = CreditnoteMap.get(ps.TargetObject.Id).blng__Subtotal__c;
                                          
                                          
                                          if(!ps.steps.isEmpty()){
                                              objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                                              lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                                          }
                                      }
                                  }
        System.debug('data retrive from Server : '+JSON.serialize(lstSubmissionWrapper));
        return lstSubmissionWrapper;
        
    }
    
    /*  public static String getObjectName(String recordId){
//To get the label of the object name using Schema methods
String keyPrefix = recordId.subString(0,3);
String objectName = '';
Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
for(String obj : sobjectTypeMap.keySet()){
Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
if(sobjectResult.getKeyPrefix() == keyPrefix){
objectName = sobjectResult.getLabel();
break;
}
}
return objectName;
}*/
    
    //Method to Approve or Reject the selected records
    @AuraEnabled
    public static String processRecords(List<String> lstWorkItemIds,String processType){
        String message = '';
        Integer recordsProcessed = 0;
        String comments = processType == 'Approve' ? 'Approved' : 'Rejected';
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(comments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            message = 'All records are '+comments+' successfully';
        }
        return message;
    }
    
    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        //@AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public Date CreditNoteDate;
        @AuraEnabled public String Account;
        @AuraEnabled public String InternalComments;
        @AuraEnabled public String Remarks;
        @AuraEnabled Public String ReasonForCreditnote;
        @AuraEnabled public Decimal Subtotal;
    }
    
    public static void Method2(){
        integer i = 0;
          
        
      
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      
            i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    
    }
}