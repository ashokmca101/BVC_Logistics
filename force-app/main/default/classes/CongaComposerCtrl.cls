public class CongaComposerCtrl {
    
    public static boolean isFutureCalled=false;
    public static String congaURL;
    public String quoteId ;
    public String quoteReturnURL {get;set;}
    public String errorMessage {get;set;}
    
    public CongaComposerCtrl(ApexPages.StandardController controller) {
        
        quoteId = ApexPages.CurrentPage().getparameters().get('Id');
    }
    
    public PageReference congaReq(){
        quoteId = ApexPages.CurrentPage().getparameters().get('Id');
        SBQQ__Quote__c sqId = [select SBQQ__EmailTemplateId__c,Business_Type__c,SBQQ__QuoteTemplateId__c,Id,SBQQ__Opportunity2__c,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Name,Name,SBQQ__Status__c,
                               SBQQ__Account__c,SBQQ__Account__r.KYC_Indicator_for_Domestic_Flag__c FROM SBQQ__Quote__c 
                               Where Id=:quoteId];
        System.debug('KY Verified or Not. '+sqId.SBQQ__Account__r.KYC_Indicator_for_Domestic_Flag__c);
        if(sqId != null && (sqId.SBQQ__Status__c == 'Draft' ||sqId.SBQQ__Status__c == 'In Review' || sqId.SBQQ__Status__c == 'Approval Rejected') ){
            errorMessage = Label.Non_Approval_Send_Quote_Error ;
            quoteReturnURL = '/'+quoteId;
            
            return null;
        }/*else if(sqId.SBQQ__Account__c != null && !(sqId.SBQQ__Account__r.KYC_Indicator_for_Domestic_Flag__c)){
            errorMessage = 'KYC not Verified';
            quoteReturnURL = '/'+quoteId;
            return null;
        }*/
        List<String> strRole = new List<String>();
        strRole.add('Decision Maker');
        strRole.add('Evaluator');
        List<OpportunityContactRole> oppCRoleLst = [SELECT ContactId,Id,IsPrimary,OpportunityId,Role,Contact.Email FROM OpportunityContactRole WHERE OpportunityId =:sqId.SBQQ__Opportunity2__c AND Role IN:strRole];
        List<String> sEmails = new List<String>();
        String sAddlEmail = '';
        String[] toAddresses = new String[]{};
            String qtype ='';
        for(OpportunityContactRole oppCRole : oppCRoleLst){
            sEmails.add(oppCRole.Contact.Email);
            sAddlEmail += oppCRole.Contact.Email+',';
        }
        System.debug('sAddlEmail====>'+sAddlEmail);
        
        String sfUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();
        system.debug('sfUrl=======>'+sfUrl);
        
        String EmailToId=((oppCRoleLst != null && !oppCRoleLst.isEmpty()) ? oppCRoleLst[0].ContactId :null);
        System.debug('sAddlEmail=========>'+sAddlEmail);
        System.debug('EmailToId=====>'+EmailToId);
        String EmailTemplateId=  sqId.SBQQ__EmailTemplateId__c;// '00X9D0000010I5H';
        String filename = 'BVC Quotes '+sqId.Name;
        String QueryIds; 
        String templateId; 
        if(sqId.Business_Type__c == 'ACR'){
            QueryIds = '[acrType]0Q_000MAE149637,[splServ]0Q_001MAE862555,[valship]0Q_002MAE677306,[goldship]0Q_004MAE264731,[silvership]0Q_005MAE993510,[genship]0Q_008EAY236725';
            templateId = '0T_007UAQ978552';
            qtype = 'ACR';
            
        }
        if(sqId.Business_Type__c == 'Non ACR'){
            QueryIds ='[goldshp]0Q_006MAE407069,[silvershp]0Q_008MAE619838,[valshp]0Q_009MAE614039,[splServ]0Q_001MAE862555,[genshp]0Q_012EAY544246';
            templateId = '0T_001MAE034241';
            qtype = 'Non ACR';
        }
        if(sqId.Business_Type__c == 'Exhibition'){
            QueryIds ='[express]0Q_009EAY440221,[wcity]0Q_010EAY342974,[surface]0Q_011EAY720078,[genshp]0Q_012EAY544246';
            templateId = '0T_002EAY594830';
            qtype = 'Exhibition';
        }
        List<EmailTemplate> emailTempList = [select id,Name from EmailTemplate where Name = 'Contract Document for eSignature'];
        System.debug('emailTemp. '+emailTempList);
        
        //String newURL = 'https://bvc2--cpqdev--apxtcfq.visualforce.com/apex/Conga_Composer?SolMgr=1&serverUrl={!SURL}&Id={!qId}&QueryId={!query_Id}&TemplateId={!TId}&EmailToId={!E_id}&OFN={!Q_Name}&EmailAdditionalTo={!sAddlEmail}&UF0=1&MFTS0=SBQQ__Status__c&MFTSValue0=Accepted&MFTS1=SBQQ__Status__c&SC0=1&SC1=SalesforceFile&EmailTemplateId=00X9D0000010I5H&DefaultPDF=1&DS7=12';
        //String newURL = 'https://bvc2--cpqqa--apxtcfq.visualforce.com/apex/Conga_Composer?SolMgr=1&serverUrl={!SURL}&Id={!qId}&EmailRelatedToId={!emailQId}&QueryId={!query_Id}&TemplateId={!TId}&EmailToId={!E_id}&OFN={!Q_Name}&EmailAdditionalTo={!sAddlEmail}&UF0=1&MFTS0=SBQQ__Status__c&MFTSValue0=Quote%20Sent&MFTS1=SBQQ__Status__c&SC0=1&SC1=SalesforceFile&EmailTemplateId=00XO0000000XvXW&DefaultPDF=1&DS7=12';
		 
        String newURL = Label.CongaVF_Base_URL+'/apex/Conga_Composer?SolMgr=1&serverUrl={!SURL}&Id={!qId}&EmailRelatedToId={!emailQId}&QueryId={!query_Id}&TemplateId={!TId}&EmailToId={!E_id}&OFN={!Q_Name}&EmailAdditionalTo={!sAddlEmail}&UF0=1&MFTS0=SBQQ__Status__c&MFTSValue0=Quote%20Sent&MFTS1=SBQQ__Status__c&SC0=1&SC1=SalesforceFile&EmailTemplateId='+((emailTempList != null && !emailTempList.isEmpty()) ?emailTempList[0].Id :'00XO0000000XvXW')+'&DefaultPDF=1&DS7=12';
        
        //MFTS0=SBQQ__Status__c&MFTSValue0=Accepted&MFTS1=SBQQ__Status__c&
        
        newURL = newURL.replace('{!SURL}',sfUrl);
        newURL = newURL.replace('{!S_ID}',UserInfo.getSessionId());
        newURL = newURL.replace('{!qId}',quoteId);
        newURL = newURL.replace('{!emailQId}',quoteId);
        newURL = newURL.replace('{!TId}',templateId);
        if(EmailToId != null){
        	newURL = newURL.replace('{!E_id}',EmailToId); 
        }else{
            errorMessage = 'Cannot find Contact Role, Please validate Quote   ' ;
            quoteReturnURL = '/'+quoteId;
            
            return null;
        }
        newURL = newURL.replace('{!Q_Name}',qtype+' Order Form - '+String.valueOf(Date.TODAY())); 
        newURL = newURL.replace('{!At}',filename); 
        newURL = newURL.replace('{!query_Id}',QueryIds); 
        newURL = newURL.replace('{!sAddlEmail}',sAddlEmail); 
        
        congaURL = newURL;
        
        System.debug('congaURL=====>'+congaURL);
        PageReference pg= new pageReference(congaURL);
        pg.setRedirect(true);
        
        return pg;
    }
    
}