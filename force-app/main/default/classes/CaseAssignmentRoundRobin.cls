public class CaseAssignmentRoundRobin {
    @InvocableMethod
    public static void assignTicketRoundRobin(List<ID> ticketIdsSet){
        List<Case> ticketList=new List<Case>();
        List<Case> domesticticketList=new List<Case>();
        List<Case> kycDomesticList=new List<Case>();
        List<Case> internationalmumbaiticketList=new List<Case>();
        List<Case> internationalsuratticketList=new List<Case>();
        List<Case> internationalseepzticketList=new List<Case>();

        ticketList=[Select id, Subject, Type, RecordType.Name from Case where ID IN :ticketIdsSet AND Account.Primary_Service_Owner__c = Null AND 
                 Account.Secondary_Service_Owner__c = Null];
        
        for(Case caseRecord:ticketList){
            if(caseRecord.RecordType.Name == 'Domestic Tickets'){
                    if(caseRecord.Subject != null){
                        if(caseRecord.Subject.contains('KYC')){
                            kycDomesticList.add(caseRecord);
                        }else{
                            domesticticketList.add(caseRecord);
                        }
                }else{
                    domesticticketList.add(caseRecord);
                }
            }                       
            if(caseRecord.RecordType.Name == 'International Tickets Mumbai'){
                internationalmumbaiticketList.add(caseRecord);
            }
            if(caseRecord.RecordType.Name == 'International Tickets Seepz'){
                internationalseepzticketList.add(caseRecord);
            }if(caseRecord.RecordType.Name == 'International Tickets Surat'){
                internationalsuratticketList.add(caseRecord);
            }
        }
            if(internationalmumbaiticketList.size()>0){
                assignInternationalMumbaiTickets(internationalmumbaiticketList);
            }
        	if(internationalsuratticketList.size()>0){
                assignInternationalSuratTickets(internationalsuratticketList);
            }
        	if(internationalseepzticketList.size()>0){
                assignInternationalSeepzTickets(internationalseepzticketList);
            }
            if(domesticticketList.size()>0){
                assignDomesticTicketRoundRobin(domesticticketList);
            }
            if(kycDomesticList.size()>0){
                assignKYCDomesticTicketRoundRobin(kycDomesticList);
            }
    }
    public static void assignDomesticTicketRoundRobin(List<Case> newCase){
        
        List<Group> QueueIds = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'ServiceRep_Queue_For_Email_To_Case'];
        List<User> activeusers=[Select id from user where IsActive=true];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember WHERE GroupId =:QueueIds AND UserOrGroupId IN:activeusers];
        Set<Id> newAssignedOwner = New Set<Id>();
        Map<Id,Id> newAssignedOwnerManagerMap = New Map<Id,Id>();
        Map<Id,Id> newAssignedOwnerDirectorMap = New Map<Id,Id>();
        List<User> OwnerManager = New List<User>();
        List<User> OwnerDirector = New List<User>();
        if(QueueMembers.size()>0){
            Integer AgentSize = 0;
            Integer MiniumCaseOwnerCount=999999999;
            Id MiniumCaseCountOwnerId;
            Set<Id> AgentIdSet = new Set<Id>();
            List<ID> AgentIdList=new List<ID>();
            for(GroupMember queuememberid:QueueMembers) {
                AgentIdSet.add(queuememberid.UserOrGroupId);  
            }
            AgentSize=AgentIdSet.Size();
            AgentIdList.addAll(AgentIdSet);
            system.debug('AgentIdList '+AgentIdList);
            system.debug('AgentSize '+AgentSize);
            //Fetched Count of cases for all service rep present in service queue.
            List<AggregateResult> CasecountBasedOnOwner=[Select Count(id)cscnt,ownerid from case where ownerid IN :AgentIdSet AND Status!='Closed' group by ownerid order by Count(id) asc Limit 50000];//added today
            Map<ID,Integer> ServiceRepIdWithCountOfCase=new Map<ID,Integer>();
            for(AggregateResult ag:CasecountBasedOnOwner) {
                String ownrid=(String)ag.get('ownerid');
                Integer Count=(Integer)ag.get('cscnt');
                ServiceRepIdWithCountOfCase.put(ownrid,Count);
            }
            system.debug('CasecountBasedOnOwner '+CasecountBasedOnOwner);
            system.debug('ServiceRepIdWithCountOfCase '+ServiceRepIdWithCountOfCase);
            for(Case cs:newCase) {
                if(ServiceRepIdWithCountOfCase.ContainsKey(AgentIdList[0])) {
                    MiniumCaseOwnerCount=ServiceRepIdWithCountOfCase.get(AgentIdList[0]);
                    system.debug('MiniumCaseOwnerCount '+MiniumCaseOwnerCount);
                }
                for(ID servicerepId:AgentIdSet) {
                    if(ServiceRepIdWithCountOfCase.containskey(servicerepId)){
                        if(ServiceRepIdWithCountOfCase.get(servicerepId)<= MiniumCaseOwnerCount) {
                            MiniumCaseOwnerCount= ServiceRepIdWithCountOfCase.get(servicerepId);
                            MiniumCaseCountOwnerId=servicerepId;  
                        }
                    }
                    else{
                        ServiceRepIdWithCountOfCase.put(servicerepId,0);
                        MiniumCaseOwnerCount=0;
                        MiniumCaseCountOwnerId=servicerepId;
                    }
                }
                
                cs.ownerId=MiniumCaseCountOwnerId;
				newAssignedOwner.add(MiniumCaseCountOwnerId);                
                ServiceRepIdWithCountOfCase.put(MiniumCaseCountOwnerId,MiniumCaseOwnerCount+1);
                
            }
            if(newAssignedOwner.size() > 0){
            OwnerManager = [SELECT ManagerId, Id, Manager.ManagerId FROM User WHERE Id IN :newAssignedOwner];
            for(User U: OwnerManager){
                newAssignedOwnerManagerMap.put(U.Id, U.ManagerId);
                newAssignedOwnerDirectorMap.put(U.Id,U.Manager.ManagerId);
            }
            }    
            for(Case C: newCase){
                C.Manager__c = newAssignedOwnerManagerMap.get(C.OwnerId);
                C.Director__c = newAssignedOwnerDirectorMap.get(C.OwnerId);
            	System.Debug('Owner'+ C.OwnerId);
                System.debug('Manager'+C.Manager__c);
                System.debug('Director'+C.Director__c);
            }
            Update newCase;
        }
    }

    public static void assignKYCDomesticTicketRoundRobin(List<Case> newCase){  
        List<Group> CopUserIds = [Select Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'COP_User_Queue'];
        List<User> activeusers=[Select id from user where IsActive=true];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember WHERE GroupId =:CopUserIds AND UserOrGroupId IN:activeusers];
        Set<Id> newAssignedOwner = New Set<Id>();
        Map<Id,Id> newAssignedOwnerManagerMap = New Map<Id,Id>();
        Map<Id,Id> newAssignedOwnerDirectorMap = New Map<Id,Id>();
        List<User> OwnerManager = New List<User>();
        List<User> OwnerDirector = New List<User>();
        if(QueueMembers.size()>0){
            Integer AgentSize = 0;
            Integer MiniumCaseOwnerCount=999999999;
            Id MiniumCaseCountOwnerId;
            Set<Id> AgentIdSet = new Set<Id>();
            List<ID> AgentIdList=new List<ID>();
            for(GroupMember queuememberid:QueueMembers) {
                AgentIdSet.add(queuememberid.UserOrGroupId);  
            }
            AgentSize=AgentIdSet.Size();
            AgentIdList.addAll(AgentIdSet);
            system.debug('AgentIdList '+AgentIdList);
            system.debug('AgentSize '+AgentSize);
            //Fetched Count of cases for all service rep present in service queue.
            List<AggregateResult> CasecountBasedOnOwner=[Select Count(id)cscnt,ownerid from case where ownerid IN :AgentIdSet AND Status!='Closed' group by ownerid order by Count(id) asc Limit 50000];//added today
            Map<ID,Integer> ServiceRepIdWithCountOfCase=new Map<ID,Integer>();
            for(AggregateResult ag:CasecountBasedOnOwner) {
                String ownrid=(String)ag.get('ownerid');
                Integer Count=(Integer)ag.get('cscnt');
                ServiceRepIdWithCountOfCase.put(ownrid,Count);
            }
            system.debug('CasecountBasedOnOwner '+CasecountBasedOnOwner);
            system.debug('ServiceRepIdWithCountOfCase '+ServiceRepIdWithCountOfCase);
            for(Case cs:newCase) {
                if(ServiceRepIdWithCountOfCase.ContainsKey(AgentIdList[0])) {
                    MiniumCaseOwnerCount=ServiceRepIdWithCountOfCase.get(AgentIdList[0]);
                    system.debug('MiniumCaseOwnerCount '+MiniumCaseOwnerCount);
                }
                for(ID servicerepId:AgentIdSet) {
                    if(ServiceRepIdWithCountOfCase.containskey(servicerepId)){
                        if(ServiceRepIdWithCountOfCase.get(servicerepId)<= MiniumCaseOwnerCount) {
                            MiniumCaseOwnerCount= ServiceRepIdWithCountOfCase.get(servicerepId);
                            MiniumCaseCountOwnerId=servicerepId;  
                        }
                    }
                    else{
                        ServiceRepIdWithCountOfCase.put(servicerepId,0);
                        MiniumCaseOwnerCount=0;
                        MiniumCaseCountOwnerId=servicerepId;
                    }
                }
                
                cs.ownerId=MiniumCaseCountOwnerId;
				newAssignedOwner.add(MiniumCaseCountOwnerId);                
                ServiceRepIdWithCountOfCase.put(MiniumCaseCountOwnerId,MiniumCaseOwnerCount+1);
                
            }
            if(newAssignedOwner.size() > 0){
            OwnerManager = [SELECT ManagerId, Id, Manager.ManagerId FROM User WHERE Id IN :newAssignedOwner];
            for(User U: OwnerManager){
                newAssignedOwnerManagerMap.put(U.Id, U.ManagerId);
                newAssignedOwnerDirectorMap.put(U.Id,U.Manager.ManagerId);
            }
            }    
            for(Case C: newCase){
                C.Manager__c = newAssignedOwnerManagerMap.get(C.OwnerId);
                C.Director__c = newAssignedOwnerDirectorMap.get(C.OwnerId);
            	System.Debug('Owner'+ C.OwnerId);
                System.debug('Manager'+C.Manager__c);
                System.debug('Director'+C.Director__c);
            }
            Update newCase;
        }
    }
    
    public static void assignInternationalMumbaiTickets(List<Case> newCase){
        
        List<Group> QueueIds = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'International_Mumbai_Service_Rep_Queue'];
        List<User> activeusers=[Select id from user where IsActive=true];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember where GroupId =:QueueIds AND UserOrGroupId IN:activeusers];
        Set<Id> newAssignedOwner = New Set<Id>();
        Map<Id,Id> newAssignedOwnerManagerMap = New Map<Id,Id>();
        Map<Id,Id> newAssignedOwnerDirectorMap = New Map<Id,Id>();
        List<User> OwnerManager = New List<User>();
        List<User> OwnerDirector = New List<User>();
        if(QueueMembers.size()>0)
        {
            Integer AgentSize = 0;
            Integer MiniumCaseOwnerCount=999999999;
            Id MiniumCaseCountOwnerId;
            Set<Id> AgentIdSet = new Set<Id>();
            List<ID> AgentIdList=new List<ID>();
            for(GroupMember queuememberid:QueueMembers) {
                AgentIdSet.add(queuememberid.UserOrGroupId);  
            }
            AgentSize=AgentIdSet.Size();
            AgentIdList.addAll(AgentIdSet);
            system.debug('AgentIdList '+AgentIdList);
            system.debug('AgentSize '+AgentSize);
            //Fetched Count of cases for all service rep present in service queue.
            List<AggregateResult> CasecountBasedOnOwner=[Select Count(id)cscnt,ownerid from case where ownerid IN :AgentIdSet AND Status!='Closed' group by ownerid order by Count(id) asc Limit 50000];//added today
            Map<ID,Integer> ServiceRepIdWithCountOfCase=new Map<ID,Integer>();
            for(AggregateResult ag:CasecountBasedOnOwner) {
                String ownrid=(String)ag.get('ownerid');
                Integer Count=(Integer)ag.get('cscnt');
                ServiceRepIdWithCountOfCase.put(ownrid,Count);
            }
            system.debug('CasecountBasedOnOwner '+CasecountBasedOnOwner);
            system.debug('ServiceRepIdWithCountOfCase '+ServiceRepIdWithCountOfCase);
            for(Case cs:newCase) {
                if(ServiceRepIdWithCountOfCase.ContainsKey(AgentIdList[0])) {
                    MiniumCaseOwnerCount=ServiceRepIdWithCountOfCase.get(AgentIdList[0]);
                    system.debug('MiniumCaseOwnerCount '+MiniumCaseOwnerCount);
                }
                for(ID servicerepId:AgentIdSet) {
                    if(ServiceRepIdWithCountOfCase.containskey(servicerepId)){
                        if(ServiceRepIdWithCountOfCase.get(servicerepId)<= MiniumCaseOwnerCount) {
                            MiniumCaseOwnerCount= ServiceRepIdWithCountOfCase.get(servicerepId);
                            MiniumCaseCountOwnerId=servicerepId;  
                        }
                    }
                    else{
                        ServiceRepIdWithCountOfCase.put(servicerepId,0);
                        MiniumCaseOwnerCount=0;
                        MiniumCaseCountOwnerId=servicerepId;
                    }
                }
                cs.ownerId=MiniumCaseCountOwnerId;
                newAssignedOwner.add(MiniumCaseCountOwnerId);  
                ServiceRepIdWithCountOfCase.put(MiniumCaseCountOwnerId,MiniumCaseOwnerCount+1);
                
            }
            If(newAssignedOwner.size() > 0){
            OwnerManager = [SELECT ManagerId, Id, Manager.ManagerId FROM User WHERE Id IN :newAssignedOwner];
            For(User U: OwnerManager){
                newAssignedOwnerManagerMap.put(U.Id, U.ManagerId);
                newAssignedOwnerDirectorMap.put(U.Id,U.Manager.ManagerId);
            }
            }    
            For(Case C: newCase){
                C.Manager__c = newAssignedOwnerManagerMap.get(C.OwnerId);
                C.Director__c = newAssignedOwnerDirectorMap.get(C.OwnerId);
            	System.Debug('Owner'+ C.OwnerId);
                System.debug('Manager'+C.Manager__c);
                System.debug('Director'+C.Director__c);
            }
            Update newCase;
        }
    }
    
    public static void assignInternationalSuratTickets(List<Case> newCase){
        
        List<Group> QueueIds = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'International_Surat_Service_Rep_Queue'];
        List<User> activeusers=[Select id from user where IsActive=true];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember where GroupId =:QueueIds AND UserOrGroupId IN:activeusers];
        Set<Id> newAssignedOwner = New Set<Id>();
        Map<Id,Id> newAssignedOwnerManagerMap = New Map<Id,Id>();
        Map<Id,Id> newAssignedOwnerDirectorMap = New Map<Id,Id>();
        List<User> OwnerManager = New List<User>();
        List<User> OwnerDirector = New List<User>();
        if(QueueMembers.size()>0)
        {
            Integer AgentSize = 0;
            Integer MiniumCaseOwnerCount=999999999;
            Id MiniumCaseCountOwnerId;
            Set<Id> AgentIdSet = new Set<Id>();
            List<ID> AgentIdList=new List<ID>();
            for(GroupMember queuememberid:QueueMembers) {
                AgentIdSet.add(queuememberid.UserOrGroupId);  
            }
            AgentSize=AgentIdSet.Size();
            AgentIdList.addAll(AgentIdSet);
            system.debug('AgentIdList '+AgentIdList);
            system.debug('AgentSize '+AgentSize);
            //Fetched Count of cases for all service rep present in service queue.
            List<AggregateResult> CasecountBasedOnOwner=[Select Count(id)cscnt,ownerid from case where ownerid IN :AgentIdSet AND Status!='Closed' group by ownerid order by Count(id) asc Limit 50000];//added today
            Map<ID,Integer> ServiceRepIdWithCountOfCase=new Map<ID,Integer>();
            for(AggregateResult ag:CasecountBasedOnOwner) {
                String ownrid=(String)ag.get('ownerid');
                Integer Count=(Integer)ag.get('cscnt');
                ServiceRepIdWithCountOfCase.put(ownrid,Count);
            }
            system.debug('CasecountBasedOnOwner '+CasecountBasedOnOwner);
            system.debug('ServiceRepIdWithCountOfCase '+ServiceRepIdWithCountOfCase);
            for(Case cs:newCase) {
                if(ServiceRepIdWithCountOfCase.ContainsKey(AgentIdList[0])) {
                    MiniumCaseOwnerCount=ServiceRepIdWithCountOfCase.get(AgentIdList[0]);
                    system.debug('MiniumCaseOwnerCount '+MiniumCaseOwnerCount);
                }
                for(ID servicerepId:AgentIdSet) {
                    if(ServiceRepIdWithCountOfCase.containskey(servicerepId)){
                        if(ServiceRepIdWithCountOfCase.get(servicerepId)<= MiniumCaseOwnerCount) {
                            MiniumCaseOwnerCount= ServiceRepIdWithCountOfCase.get(servicerepId);
                            MiniumCaseCountOwnerId=servicerepId;  
                        }
                    }
                    else{
                        ServiceRepIdWithCountOfCase.put(servicerepId,0);
                        MiniumCaseOwnerCount=0;
                        MiniumCaseCountOwnerId=servicerepId;
                    }
                }
                cs.ownerId=MiniumCaseCountOwnerId;
                newAssignedOwner.add(MiniumCaseCountOwnerId);  
                ServiceRepIdWithCountOfCase.put(MiniumCaseCountOwnerId,MiniumCaseOwnerCount+1);
                
            }
            If(newAssignedOwner.size() > 0){
            OwnerManager = [SELECT ManagerId, Id, Manager.ManagerId FROM User WHERE Id IN :newAssignedOwner];
            For(User U: OwnerManager){
                newAssignedOwnerManagerMap.put(U.Id, U.ManagerId);
                newAssignedOwnerDirectorMap.put(U.Id,U.Manager.ManagerId);
            }
            }    
            For(Case C: newCase){
                C.Manager__c = newAssignedOwnerManagerMap.get(C.OwnerId);
                C.Director__c = newAssignedOwnerDirectorMap.get(C.OwnerId);
            	System.Debug('Owner'+ C.OwnerId);
                System.debug('Manager'+C.Manager__c);
                System.debug('Director'+C.Director__c);
            }
            Update newCase;
        }
    }
    
    public static void assignInternationalSeepzTickets(List<Case> newCase){
        
        List<Group> QueueIds = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'International_Seepz_Service_Rep_Queue'];
        List<User> activeusers=[Select id from user where IsActive=true];
        List<GroupMember> QueueMembers = [Select UserOrGroupId,Id From GroupMember where GroupId =:QueueIds AND UserOrGroupId IN:activeusers];
        Set<Id> newAssignedOwner = New Set<Id>();
        Map<Id,Id> newAssignedOwnerManagerMap = New Map<Id,Id>();
        Map<Id,Id> newAssignedOwnerDirectorMap = New Map<Id,Id>();
        List<User> OwnerManager = New List<User>();
        List<User> OwnerDirector = New List<User>();
        if(QueueMembers.size()>0)
        {
            Integer AgentSize = 0;
            Integer MiniumCaseOwnerCount=999999999;
            Id MiniumCaseCountOwnerId;
            Set<Id> AgentIdSet = new Set<Id>();
            List<ID> AgentIdList=new List<ID>();
            for(GroupMember queuememberid:QueueMembers) {
                AgentIdSet.add(queuememberid.UserOrGroupId);  
            }
            AgentSize=AgentIdSet.Size();
            AgentIdList.addAll(AgentIdSet);
            system.debug('AgentIdList '+AgentIdList);
            system.debug('AgentSize '+AgentSize);
            //Fetched Count of cases for all service rep present in service queue.
            List<AggregateResult> CasecountBasedOnOwner=[Select Count(id)cscnt,ownerid from case where ownerid IN :AgentIdSet AND Status!='Closed' group by ownerid order by Count(id) asc Limit 50000];//added today
            Map<ID,Integer> ServiceRepIdWithCountOfCase=new Map<ID,Integer>();
            for(AggregateResult ag:CasecountBasedOnOwner) {
                String ownrid=(String)ag.get('ownerid');
                Integer Count=(Integer)ag.get('cscnt');
                ServiceRepIdWithCountOfCase.put(ownrid,Count);
            }
            system.debug('CasecountBasedOnOwner '+CasecountBasedOnOwner);
            system.debug('ServiceRepIdWithCountOfCase '+ServiceRepIdWithCountOfCase);
            for(Case cs:newCase) {
                if(ServiceRepIdWithCountOfCase.ContainsKey(AgentIdList[0])) {
                    MiniumCaseOwnerCount=ServiceRepIdWithCountOfCase.get(AgentIdList[0]);
                    system.debug('MiniumCaseOwnerCount '+MiniumCaseOwnerCount);
                }
                for(ID servicerepId:AgentIdSet) {
                    if(ServiceRepIdWithCountOfCase.containskey(servicerepId)){
                        if(ServiceRepIdWithCountOfCase.get(servicerepId)<= MiniumCaseOwnerCount) {
                            MiniumCaseOwnerCount= ServiceRepIdWithCountOfCase.get(servicerepId);
                            MiniumCaseCountOwnerId=servicerepId;  
                        }
                    }
                    else{
                        ServiceRepIdWithCountOfCase.put(servicerepId,0);
                        MiniumCaseOwnerCount=0;
                        MiniumCaseCountOwnerId=servicerepId;
                    }
                }
                cs.ownerId=MiniumCaseCountOwnerId;
                newAssignedOwner.add(MiniumCaseCountOwnerId);  
                ServiceRepIdWithCountOfCase.put(MiniumCaseCountOwnerId,MiniumCaseOwnerCount+1);
                
            }
            If(newAssignedOwner.size() > 0){
            OwnerManager = [SELECT ManagerId, Id, Manager.ManagerId FROM User WHERE Id IN :newAssignedOwner];
            For(User U: OwnerManager){
                newAssignedOwnerManagerMap.put(U.Id, U.ManagerId);
                newAssignedOwnerDirectorMap.put(U.Id,U.Manager.ManagerId);
            }
            }    
            For(Case C: newCase){
                C.Manager__c = newAssignedOwnerManagerMap.get(C.OwnerId);
                C.Director__c = newAssignedOwnerDirectorMap.get(C.OwnerId);
            	System.Debug('Owner'+ C.OwnerId);
                System.debug('Manager'+C.Manager__c);
                System.debug('Director'+C.Director__c);
            }
            Update newCase;
        }
    }
}