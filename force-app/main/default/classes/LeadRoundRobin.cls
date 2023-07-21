public class LeadRoundRobin {
    public static void assignTicketRoundRobin(Set<Id> ticketIdsSet){
        /* Get list of all leads */
        //If(CheckRecursive.isFirstTime){
            //CheckRecursive.isFirstTime = FALSE;
        System.Debug('TicketIdSet' + ticketIdsSet);
        List<Lead> ticketList = [Select Id, PostalCode, ownerId
                                 FROM Lead WHERE Id IN :ticketIdsSet AND LeadSource!='Others'];
        Set<String> LeadPincode = new Set<String>();
        List<Address> AddressList = new List<Address>();
        List<Lead> InactivePincodeLeads = new List<Lead>();
        //Adding Lead pincode in a list
        System.debug('List of tickets' + ticketlist);
        for(Lead L: ticketList){
            if(L.PostalCode != NULL){
                LeadPincode.add(L.PostalCode);
            }
            else{
                InactivePincodeLeads.add(L);
            }
        }
        
        List<Active_Area_Sales_Rep__c> SalesRepList = [Select Active_Pincode__c,Active_Pincode__r.Pincodes__c, Sales_Rep__c FROM 
                                                       Active_Area_Sales_Rep__c WHERE 
                                                       Active_Pincode__r.Pincodes__c IN :LeadPincode];
        Map<String,Set<ID>>PincodeWithSalesRepMap=new Map<String,Set<ID>>();
        Set<ID> salesrepId=new Set<ID>();//added today
        for(Active_Area_Sales_Rep__c salesrep:SalesRepList) {
            salesrepId.add(salesrep.Sales_Rep__c);//added today
            if(PincodeWithSalesRepMap.containsKey(salesrep.Active_Pincode__r.Pincodes__c)) {
                Set<ID> repId = PincodeWithSalesRepMap.get(salesrep.Active_Pincode__r.Pincodes__c);
                repId.add(salesrep.Sales_Rep__c);
                PincodeWithSalesRepMap.put(salesrep.Active_Pincode__r.Pincodes__c,repId);
            }
            else {
                Set<ID> FirstrepId = new Set<ID>();
                FirstrepId.add(salesrep.Sales_Rep__c);
                PincodeWithSalesRepMap.put(salesrep.Active_Pincode__r.Pincodes__c,FirstrepId);
            } 
        }
        List<AggregateResult> LeadcountBasedOnOwner=[Select Count(id)ldcnt,ownerid from lead where ownerid IN :salesrepId AND IsConverted=False group by ownerid order by Count(id) asc Limit 50000];//added today
        Map<ID,Integer> SalesRepIdWithCountOfLead=new Map<ID,Integer>();
        for(AggregateResult ag:LeadcountBasedOnOwner) {
            String ldid=(String)ag.get('ownerid');
            Integer Count=(Integer)ag.get('ldcnt');
            SalesRepIdWithCountOfLead.put(ldid,Count);
        }
        system.debug('LeadcountBasedOnOwner'+LeadcountBasedOnOwner);
        system.debug('SalesRepIdWithCountOfLead'+SalesRepIdWithCountOfLead);
        set<String> PincodewithMultipleSalesRep=new Set<String>();
        for(Lead ld:ticketList) {
            if(PincodeWithSalesRepMap.containsKey(ld.PostalCode)) {
                Set<Id> salesrepSet=PincodeWithSalesRepMap.get(ld.PostalCode);
                if(salesrepSet.size()==1) {
                    List<Id> Listsalesrep=new List<Id>();
                    Listsalesrep.addAll(salesrepSet);
                    ld.OwnerId=Listsalesrep[0]; 
                }
                else if(salesrepSet.size()>1) {
                    List<Id> Listsalesrep=new List<Id>();
                    Listsalesrep.addAll(salesrepSet);
                    for(ID srepId:salesrepSet) {
                        PincodewithMultipleSalesRep.add(ld.PostalCode); 
                    } 
                    
                }
            }
            else{
                InactivePincodeLeads.add(ld);
            }
        }
        List<Id> AgentIdList = new List<Id>();
        Integer AgentSize = 0;
        //Integer index = 0;
        //Integer TicketNumber = 0;
        for(Lead lead:ticketList) {
            if(PincodewithMultipleSalesRep.contains(lead.PostalCode)){
                AgentSize = PincodeWithSalesRepMap.get(lead.PostalCode).size();
                AgentIdList = (new List<Id>(PincodeWithSalesRepMap.get(lead.PostalCode)) );
                Integer miniumLeadCount=999999999;
                ID SalesrepminCountId;
                if(SalesRepIdWithCountOfLead.ContainsKey(AgentIdList[0])) {
                    miniumLeadCount=SalesRepIdWithCountOfLead.get(AgentIdList[0]);
                }
                for(ID slsrepId:AgentIdList) {
                    if(SalesRepIdWithCountOfLead.ContainsKey(slsrepId)) {
                        if(SalesRepIdWithCountOfLead.get(slsrepId)<=miniumLeadCount)
                        {
                            miniumLeadCount=SalesRepIdWithCountOfLead.get(slsrepId); 
                            SalesrepminCountId=slsrepId;
                        }
                    }
                    else{
                        SalesRepIdWithCountOfLead.put(slsrepId,0);
                        miniumLeadCount=0;
                        SalesrepminCountId=slsrepId;
                    }
                }
                system.debug('miniumLeadCount---'+miniumLeadCount+' SalesrepminCountId---'+SalesrepminCountId);
                SalesRepIdWithCountOfLead.put(SalesrepminCountId,miniumLeadCount+1) ;     
                //TicketNumber = Integer.valueOf(lead.Lead_Number__c);
                //index = Math.mod(TicketNumber, AgentSize);     
                lead.OwnerId = SalesrepminCountId;//AgentIdList[index];
            }
        }
        
        List<Group> QueueIds = [SELECT Id FROM Group WHERE 
                                Type = 'Queue' AND DeveloperName = 'Unassigned_Leads'];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember where GroupId =:QueueIds];
        
        List<Id> EmailList = new List<Id>();
        
        For(Lead L : InactivePincodeLeads){          
            L.OwnerId = QueueMembers[0].UserOrGroupId;
            L.Is_Inactive_Pincode__c = TRUE;
            //EmailList.add(QueueMembers[0].UserOrGroupId);
        }
        Utility.isRun= true;
        Update ticketList;
        System.debug('Set assiment value'+Utility.isRun);
        
        /*
        EmailTemplate et=[Select Id,Subject,Description,htmlvalue,body from EmailTemplate 
                          where DeveloperName ='Inactive_Lead_Pincode' limit 1];            
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        For(Lead LeadOwnr: InactivePincodeLeads){
            If(LeadOwnr.OwnerId == QueueMembers[0].UserOrGroupId ){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setTargetObjectId(LeadOwnr.OwnerId);
                //mail.setWhatId(LeadOwnr.Id);
                mail.setSaveAsActivity(false);
                mail.setTemplateId(et.id);
                system.debug('-->mails'+mail);
                mails.add(mail);
            } 
        }
        Messaging.sendEmail(mails);*/
    }
//}
    
}