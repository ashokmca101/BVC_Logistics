public with sharing class sendSignatureController {

    @AuraEnabled
    public static string validateAndSendEsign(String recordId){

        try {
            List<SBQQ__Quote__c> quoteObj = [Select id,SBQQ__Account__c,SBQQ__Account__r.KYC_Indicator_for_Domestic_Flag__c,People__c from SBQQ__Quote__c WHERE id =: recordId];
            List<dfsle__EnvelopeConfiguration__c> EnvelopeTemplate = [Select id from dfsle__EnvelopeConfiguration__c where dfsle__SourceObject__c ='SBQQ__Quote__c'];
            String sendEsignURL;
            if(quoteObj != null &&!quoteObj.isEmpty()){
                if(quoteObj[0].SBQQ__Account__c != null && !(quoteObj[0].SBQQ__Account__r.KYC_Indicator_for_Domestic_Flag__c)){
                     sendEsignURL = 'A';
                }
                else if(quoteObj[0].People__c == null){
                    sendEsignURL = 'C';
                }else if (EnvelopeTemplate.isEmpty()) {
                    sendEsignURL = 'D';
                }else if(EnvelopeTemplate != null && !EnvelopeTemplate.isEmpty()){
                    Pagereference pg = Page.dfsle__sending;
                    pg.getParameters().put('sId',recordId);
                    pg.getParameters().put('templateId',EnvelopeTemplate[0].Id);
                    pg.getParameters().put('recordId',recordId);
                    pg.getParameters().put('title','Send esign');
                    sendEsignURL =  pg.getUrl();                    
                }
                return sendEsignURL;    
            }else{
                return 'E';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
           
        }
    }
}