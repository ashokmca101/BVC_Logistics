public class NotificationToManagerAboutTopDeals {
    @invocablemethod
    public static void SendNotificationToManager(List<Id> OpportunityIdList){
        List <Opportunity> TopDeals = [SELECT Amount, Name, ID, OwnerId, Owner.Name,Owner.ManagerId, BVC_Opportunity_Number__c
                                       FROM Opportunity WHERE AMOUNT != NULL AND OwnerId = : UserInfo.getUserId() ORDER BY Amount DESC LIMIT 5];
        List<Opportunity> OpportunityList = [SELECT Id, Amount, Name, OwnerId, Owner.Name,Owner.ManagerId, BVC_Opportunity_Number__c
                                             FROM Opportunity WHERE Id IN :OpportunityIdList AND Amount != NULL];
        //Map <Id, Id> OpportunityIdWithOwnerId = new Map<Id,Id>();
        Set<Id> Top5DealsId = new Set<Id>();
        for(Opportunity opp:OpportunityList) {
            For(Opportunity A: TopDeals){
                if(Opp.amount>A.amount) {
                    Top5DealsId.add(Opp.Id);  
                }
                else {
                    Top5DealsId.add(A.Id);  
                }
            }
        }
        
        system.debug('Line 13');
        Map<Id, Set<Opportunity>> OppMap = New Map<Id, Set<Opportunity>>();
        Set <Id> EmailList = new Set<Id>();
        For(Opportunity A: OpportunityList){
            If(Top5DealsId.Contains(A.Id) || (A.Amount>=1000000)){
                if(A.Owner.ManagerId!=null){
                   EmailList.add(A.Owner.ManagerId);
                }
                if(OppMap.containsKey(A.Owner.ManagerId)) {
                    Set<Opportunity> oppset=OppMap.get(A.Owner.ManagerId); 
                    oppset.add(A); 
                    OppMap.put(A.OwnerId,oppset);  
                }
                else {
                    Set<Opportunity> oppset=new Set<Opportunity>(); 
                    oppset.add(A); 
                    OppMap.put(A.Owner.ManagerId,oppset);  
                }
                
            }
        }
        system.debug('OppMap'+OppMap);
        //Update OpportunityList;
        system.debug('Line 25');
        EmailTemplate et=[Select Id,Subject,Description,htmlvalue,body from EmailTemplate 
                          where DeveloperName ='Top_Deal_Amount_Email' limit 1];
        system.debug('Email template'+et);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        If(EmailList.size()>0){
            For(Id OppOwnerId: EmailList){
                if(OppMap.containskey(OppOwnerId)) {
                    Set<Opportunity> oppset=OppMap.get(OppOwnerId);
                    for(Opportunity opty:oppset) {
                        String recordurl=URL.getSalesforceBaseUrl().toExternalForm()+'/'+opty.Id;
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(OppOwnerId);
                        mail.setTemplateId(et.id);
                        mail.setsubject('New Top Deal');
                        system.debug('$$$'+OppOWnerId);
                        mail.setSaveAsActivity(false);
                        String htmlBody =et.HtmlValue;
                        system.debug('-->htmlBody1'+htmlBody);
                        htmlBody = htmlBody.replace('{!Opportunity.Name}', String.isNotBlank(opty.Name) ? opty.Name : '');
                        htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', String.isNotBlank(opty.Owner.Name) ? opty.Owner.Name : '');
                        htmlBody = htmlBody.replace('{!Opportunity.Amount}', String.valueof(opty.Amount));
                        htmlBody = htmlBody.replace('{!Opportunity.Link}', String.isNotBlank(String.valueof(recordurl))? String.valueof(recordurl): '');
                        system.debug('-->htmlBody2'+htmlBody);
                        mail.setHtmlBody(htmlBody);
                        system.debug('-->mails'+mail);
                        mails.add(mail);
                    }
                }
            }
            Messaging.sendEmail(mails);
        }
        
    }
}