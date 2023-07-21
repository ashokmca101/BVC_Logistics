trigger DealContactRoleTrigger on OpportunityContactRole (Before Insert,Before Update) {
   	List<ID> newOCROpportunityIdList=new List<ID>();
    Set<Id> newOCROpportunityIdWithRoleAuthorisedSignatory=new Set<Id>();
    If((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        for(OpportunityContactRole ocr:Trigger.New) {
            newOCROpportunityIdList.add(ocr.OpportunityId);
        }
        Set<ID> newOCROpportunityId=new Set<ID>(newOCROpportunityIdList);
        List<OpportunityContactRole> OCRListWithRoleAuthorisedSignatory=[Select id,Opportunityid,Contactid from OpportunityContactRole where opportunityid IN :newOCROpportunityId AND Role='Authorised Signatory'];
        if(OCRListWithRoleAuthorisedSignatory.size()>0) {
            for(OpportunityContactRole ocr:OCRListWithRoleAuthorisedSignatory) {
               newOCROpportunityIdWithRoleAuthorisedSignatory.add(ocr.opportunityid);
            }
            
        }
        for(OpportunityContactRole ocr:Trigger.New) {
            if(newOCROpportunityIdWithRoleAuthorisedSignatory.contains(ocr.OpportunityId) && ocr.Role=='Authorised Signatory') {
                ocr.Role.adderror('Only a single people on a deal can be an Authorised Signatory');
            }
        }
    }
}