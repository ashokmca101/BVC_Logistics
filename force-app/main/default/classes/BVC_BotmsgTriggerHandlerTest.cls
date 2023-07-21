@istest
public class BVC_BotmsgTriggerHandlerTest {
    
    testmethod static void relationmapone(){ 
        
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
        
        rsplus__Bot__c bt = new rsplus__Bot__c();
        bt.name='BVC Bot';
       // bt.rsplus__Bot_Element__c=b.id;
        insert bt;

        
        rsplus__Bot_Element__c b = new rsplus__Bot_Element__c();
        b.rsplus__Text_Question__c='test';
        b.rsplus__Parent_bot__c=bt.id;
        insert b;
        
        rsplus__Bot__c bt1 = new rsplus__Bot__c(id=bt.id);
        bt1.name='BVC Bot';
       bt1.rsplus__Bot_Element__c=b.id;
        update bt1;
   
       
 
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        
         contact cn= new contact();
        cn.Lastname='VTTEST';
        cn.MobilePhone='6309409167';
        cn.AccountId=ac.id;
        insert cn;
        
        
        list<rsplus__SMS_Bucket__c> bfmsglist= new list<rsplus__SMS_Bucket__c>();  
        rsplus__SMS_Bucket__c v= new rsplus__SMS_Bucket__c();
        v.rsplus__Related_To__c=ac.id;
        v.rsplus__Number__c='916309409167';
        v.rsplus__Sender_ID__c='15415161800';
        v.rsplus__Type__c='Inbound';
        v.rsplus__Message__c='Test';
        bfmsglist.add(v);
        BVC_BotmsgTriggerHandler.relatedsetup(bfmsglist);  
        
    }    
    
     testmethod static void relationmaptwo(){ 
        
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
         
         
         contact cn= new contact();
        cn.Lastname='VTTEST';
        cn.MobilePhone='6309409167';
        cn.AccountId=ac.id;
        insert cn;
         
         rsplus__Bot__c bt = new rsplus__Bot__c();
        bt.name='BVC Bot';
       // bt.rsplus__Bot_Element__c=b.id;
        insert bt;

        
        rsplus__Bot_Element__c b = new rsplus__Bot_Element__c();
        b.rsplus__Text_Question__c='test';
        b.rsplus__Parent_bot__c=bt.id;
        insert b;
        
        rsplus__Bot__c bt1 = new rsplus__Bot__c(id=bt.id);
        bt1.name='BVC Bot';
       bt1.rsplus__Bot_Element__c=b.id;
        update bt1;

        rsplus__SMS_Bucket__c v1= new rsplus__SMS_Bucket__c();
        v1.rsplus__Related_To__c=ac.id;
        v1.rsplus__Number__c='916309409167';
        v1.rsplus__Sender_ID__c='15415161800';
        v1.rsplus__Type__c='Inbound';
          v1.rsplus__Message__c='Test';
        v1.rsplus__Submitted_On__c=system.now(); 
        insert v1;
 
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        list<rsplus__SMS_Bucket__c> bfmsglist= new list<rsplus__SMS_Bucket__c>();  
        rsplus__SMS_Bucket__c v= new rsplus__SMS_Bucket__c();
       // v.rsplus__Related_To__c=ac.id;
        v.rsplus__Number__c='916309409167';
        v.rsplus__Sender_ID__c='15415161800';
        v.rsplus__Type__c='Inbound';
        v.rsplus__Related_Inbound_SMS_Bucket__c=v1.id;
        bfmsglist.add(v);
        BVC_BotmsgTriggerHandler.relatedsetup(bfmsglist);  
        
    }    
    
    
}