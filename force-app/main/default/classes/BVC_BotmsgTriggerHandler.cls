public class BVC_BotmsgTriggerHandler {
    
    public static void relatedsetup(list<rsplus__SMS_Bucket__c> msglist){
        string key='Hello BVC';
        set<string> AccountIDs = new  set<string>();
        set<string> NumbersNotAccount = new  set<string>();
        set<id> oldmsgbkt = new  set<id>();
        set<string> phones = new  set<string>();
        list<rsplus__SMS_Bucket__c> filterlist = new  list<rsplus__SMS_Bucket__c>();
        list<rsplus__SMS_Bucket__c> botmsg = new  list<rsplus__SMS_Bucket__c>();
        datetime  presenttime = system.now().addMinutes(-30); // 10 :30 - 10
        for(rsplus__SMS_Bucket__c b :msglist){
            if(string.isNotBlank(b.rsplus__Related_To__c) /*&& b.rsplus__Type__c=='Inbound' && b.rsplus__Bot_Element__c==null*/ ){
                String sObjName = Id.valueof(b.rsplus__Related_To__c).getSObjectType().getDescribe().getName();
                system.debug('sObjName '+sObjName);
                if(sObjName=='Account' || sObjName=='ACCOUNT' || sObjName=='account'){
                    AccountIDs.add(b.rsplus__Related_To__c);
                    filterlist.add(b); 
                }else{
                    NumbersNotAccount.add(b.rsplus__Number__c.right(10)); 
                    filterlist.add(b);   
                }
            }else if(string.isNotBlank(b.rsplus__Number__c) && string.isBlank(b.rsplus__Related_To__c) /*&& b.rsplus__Type__c=='Inbound' && b.rsplus__Bot_Element__c==null*/){
                NumbersNotAccount.add(b.rsplus__Number__c.right(10)); 
                filterlist.add(b);     
            }
            if(string.isNotBlank(b.rsplus__Number__c) && string.isblank(b.rsplus__Contact__c)){
            phones.add(b.rsplus__Number__c.right(10));    
            }
             if((b.rsplus__Type__c=='Inbound'&& b.rsplus__Bot_Element__c==null && b.rsplus__Related_Inbound_SMS_Bucket__c!=null && string.isNotBlank(b.rsplus__Message__c)/*&& presenttime  >= b.rsplus__Related_Inbound_SMS_Bucket__r.rsplus__Submitted_On__c*/)){
                if(!b.rsplus__Message__c.equalsignorecase(key))
                oldmsgbkt.add(b.rsplus__Related_Inbound_SMS_Bucket__c);
                system.debug('expired list '+botmsg);
            }
            if(b.rsplus__Type__c=='Inbound' && b.rsplus__Related_Inbound_SMS_Bucket__c==null && string.isNotBlank(b.rsplus__Message__c)){
               if(!b.rsplus__Message__c.equalsignorecase(key))
               botmsg.add(b); 
            }
            
        }
        
        set<id> filerAccIds = new  set<id>(); 
        if(!AccountIDs.isEmpty()){
            for(Account a :[select Id,Name,PAN_Number_of_Entity__c from account where id=:AccountIDs and RecordType.Name='Shipping' ]){
                filerAccIds.add(a.id);
            } 
        }
        
        
        map<string,contact> conatacts = new map<string,contact>();
        map<string,Id> IdVsNumber = new map<string,Id>();
        if(!NumbersNotAccount.isEmpty()){
            for(Contact c :[Select Id,Name,MobilePhone,Phone,AccountId From Contact Where MobilePhone=:NumbersNotAccount]){
                IdVsNumber.put('91'+c.MobilePhone,c.AccountId);
                conatacts.put('91'+c.MobilePhone,c);
            }
        }else if(!phones.isEmpty()){
            for(Contact c :[Select Id,Name,MobilePhone,Phone,AccountId From Contact Where MobilePhone=:phones]){
                conatacts.put('91'+c.MobilePhone,c);
            }   
        }
               
               
        system.debug('1111 '+IdVsNumber);
        set<id> filerAccIdsTwo = new set<id>();
        Map<string,string> filerAccIdsThree = new   Map<string,string>();
        Map<id,string> pannumberVSac = new  Map<id,string>();
        if(!IdVsNumber.isEmpty()){
            for(Account a :[select Id,Name,PAN_Number_of_Entity__c,RecordType.Name from account where id=:IdVsNumber.values()]){
                 if(a.RecordType.Name=='Shipping')
                 filerAccIdsTwo.add(a.id);
                 if(a.RecordType.Name=='Billing')
                 pannumberVSac.put(a.id,a.PAN_Number_of_Entity__c);
            }     
        }
        if(!pannumberVSac.isEmpty()){
                for(Account a :[select Id,Name,PAN_Number_of_Entity__c from account where PAN_Number_of_Entity__c=:pannumberVSac.values() and RecordType.Name='Shipping']){
                      filerAccIdsThree.put(a.PAN_Number_of_Entity__c,a.id);
                }     
            }

   
        if(filterlist.size() > 0)
            for(rsplus__SMS_Bucket__c b :filterlist){ 
                if(!filerAccIds.isEmpty() && filerAccIds.contains(b.rsplus__Related_To__c)){
                }else{
                  //  b.rsplus__Related_To__c=null;    
                }
                if(!IdVsNumber.isEmpty() && !filerAccIdsTwo.isEmpty() && filerAccIdsTwo.contains(IdVsNumber.get(b.rsplus__Number__c))){
                    b.rsplus__Related_To__c=  IdVsNumber.get(b.rsplus__Number__c); 
                    b.rsplus__Account_del1__c=IdVsNumber.get(b.rsplus__Number__c);
                }else if(!IdVsNumber.isEmpty() && filerAccIdsThree.containsKey(pannumberVSac.get(IdVsNumber.get(b.rsplus__Number__c)))){
                   b.rsplus__Related_To__c=filerAccIdsThree.get(pannumberVSac.get(IdVsNumber.get(b.rsplus__Number__c)));
                   b.rsplus__Account_del1__c=filerAccIdsThree.get(pannumberVSac.get(IdVsNumber.get(b.rsplus__Number__c)));
                }
                if(string.isblank(b.rsplus__Contact__c) && conatacts.containskey(b.rsplus__Number__c)){
                   b.rsplus__Contact__c= conatacts.get(b.rsplus__Number__c).id; 
                }
                
            }
        
        system.debug('IdVsNumber '+IdVsNumber+' filerAccIds  '+filerAccIds+'  filerAccIdsTwo '+filerAccIdsTwo);
        list<rsplus__SMS_Bucket__c> botmsgreply = new  list<rsplus__SMS_Bucket__c>();
        if(oldmsgbkt.size() > 0 ){
            list<id> btid = new list<id>();
            for(rsplus__Bot__c b : [select id,name,rsplus__Bot_Element__c from rsplus__Bot__c where Name='BVC Bot' limit 10]){
                btid.add(b.rsplus__Bot_Element__c);   
            }
            if(!btid.isempty())
                for(rsplus__SMS_Bucket__c m :[select id,rsplus__Submitted_On__c,rsplus__Number__c,rsplus__Sender_ID__c,rsplus__Related_To__c from rsplus__SMS_Bucket__c where id=:oldmsgbkt and rsplus__Submitted_On__c <=:presenttime]){ 
                    rsplus__SMS_Bucket__c v = new rsplus__SMS_Bucket__c();
                    v.rsplus__Bot_Element__c=btid[0];
                    v.rsplus__Number__c=m.rsplus__Number__c;
                    v.rsplus__Sender_ID__c=m.rsplus__Sender_ID__c;
                    v.rsplus__Type__c='Outbound';
                    v.rsplus__Related_To__c=m.rsplus__Related_To__c;
                    botmsgreply.add(v);
                }
            
        }
        if(botmsg.size() > 0 ){
            list<id> btid = new list<id>();
            for(rsplus__Bot__c b : [select id,name,rsplus__Bot_Element__c from rsplus__Bot__c where Name='BVC Bot' limit 10]){
                btid.add(b.rsplus__Bot_Element__c);   
            }
            if(!btid.isempty())
                for(rsplus__SMS_Bucket__c m :botmsg){ 
                    rsplus__SMS_Bucket__c v = new rsplus__SMS_Bucket__c();
                    v.rsplus__Bot_Element__c=btid[0];
                    v.rsplus__Number__c=m.rsplus__Number__c;
                    v.rsplus__Sender_ID__c=m.rsplus__Sender_ID__c;
                    v.rsplus__Type__c='Outbound';
                    v.rsplus__Related_To__c=m.rsplus__Related_To__c;
                    botmsgreply.add(v);
                }
            
        }
        
        
        if(botmsgreply.size() > 0)
            database.insert(botmsgreply,false);       
    } 
    
    
}