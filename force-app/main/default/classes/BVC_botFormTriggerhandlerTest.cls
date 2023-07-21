@IsTest
public class BVC_botFormTriggerhandlerTest {
    
    testmethod static void relationmapone(){ 
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
        
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        list<rsplus__Bot_Form__c> bflist= new list<rsplus__Bot_Form__c>();  
        rsplus__Bot_Form__c c= new rsplus__Bot_Form__c();
        c.rsplus__Related_To__c=ac.id;
        insert c;
        bflist.add(c);
        BVC_botFormTriggerHandler.relatedsetup(bflist);  
        
    }
    
    testmethod static void relationmaptwo(){ 
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
        
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        
        contact cn= new contact();
        cn.Lastname='VTTEST';
        cn.MobilePhone='6309409166';
        cn.AccountId=ac.id;
        insert cn;
        list<rsplus__Bot_Form__c> bflist= new list<rsplus__Bot_Form__c>();  
        rsplus__Bot_Form__c c= new rsplus__Bot_Form__c();
        c.rsplus__Related_To__c=null;
        c.rsplus__To__c='916309409166';
        insert c;
        bflist.add(c);
        BVC_botFormTriggerHandler.relatedsetup(bflist);
    }
    
    
    testmethod static void newaddresssetupone(){
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
        
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        Hub__c h= new Hub__c();
        h.name='DELHI';
        insert h;
        
        
        Active_Pincode__c ap=new Active_Pincode__c();
        ap.City__c='Noida';
        ap.Country__c='india';
        ap.Hub__c=h.id;
        ap.State__c='Uttar Pradesh';
        ap.name='506201';
        insert ap;
        
      /*Id shippingRecType = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        AddressBook__c  a = new AddressBook__c();
        a.Name='Hyderabad';
        a.Customer__c=ac.id;
        a.Active_Pincode__c=ap.id;
        a.RecordTypeId=shippingRecType;
        a.ADDRESS1__c='HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH';
        a.Your_Address_Identifier__c='BOT BVC '+String.valueOf(system.now());
        insert a;*/
        
        
        
        list<rsplus__Bot_Form__c> bflist= new list<rsplus__Bot_Form__c>();  
        rsplus__Bot_Form__c c= new rsplus__Bot_Form__c();
        c.rsplus__Related_To__c=ac.id;
        c.Shipping_Customer_ID__c=ac.id;
        c.Billing_Customer_ID__c=acb.id;
        c.rsplus__To__c='916309409166';
        c.rsplus__Status__c='Completed';
        c.rsplus__Answer_2__c='New Address';
        c.rsplus__Answer_3__c='Hyderabad';
        c.rsplus__Answer_4__c='506201';
        c.rsplus__Answer_1000_Char__c='HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH';
        c.Answer_5__c='1';
        insert c;
        bflist.add(c);
        BVC_botFormTriggerHandler.NewaddressSetup(bflist);  
        
    }
    
    testmethod static void newaddresssetuptwo(){
        id reocrdtypeid =[SELECT id from RecordType where Name ='Shipping' limit 1].id;
        id reocrdtypeidbling =[SELECT id from RecordType where Name ='Billing' limit 1].id;
        Account ac = new Account();
        ac.Name='VTTEST';
        ac.RecordTypeId =reocrdtypeid;
        ac.PAN_Number_of_Entity__c='1234567890';
        insert ac;
        
        Account acb = new Account();
        acb.Name='VTTEST2';
        acb.RecordTypeId =reocrdtypeidbling;
        acb.PAN_Number_of_Entity__c='1234567890';
        acb.ParentId=ac.id;
        insert acb; 
        Hub__c h= new Hub__c();
        h.name='DELHI';
        insert h;
        
        
        Active_Pincode__c ap=new Active_Pincode__c();
        ap.City__c='Noida';
        ap.Country__c='india';
        ap.Hub__c=h.id;
        ap.State__c='Uttar Pradesh';
        ap.name='506201';
        insert ap;
        
      Id shippingRecType = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        AddressBook__c  a = new AddressBook__c();
        a.Name='Hyderabad';
        a.Customer__c=ac.id;
        a.Active_Pincode__c=ap.id;
        a.RecordTypeId=shippingRecType;
        a.ADDRESS1__c='HHHHHHHHHHHHHHHHHHHHHHHHHHHH';
        a.Your_Address_Identifier__c='BOT BVC '+String.valueOf(system.now());
        insert a;
        
        
        
        list<rsplus__Bot_Form__c> bflist= new list<rsplus__Bot_Form__c>();  
        rsplus__Bot_Form__c c= new rsplus__Bot_Form__c();
        c.rsplus__Related_To__c=ac.id;
        c.Shipping_Customer_ID__c=ac.id;
        c.Billing_Customer_ID__c=acb.id;
        c.rsplus__To__c='916309409166';
        c.rsplus__Status__c='Completed';
        c.rsplus__Answer_2__c=a.id;
       //.rsplus__Answer_3__c='Hyderabad';
       //.rsplus__Answer_4__c='506201';
       //.rsplus__Answer_1000_Char__c='HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH';
        c.Answer_5__c='1';
        insert c;
        bflist.add(c);
        BVC_botFormTriggerHandler.NewaddressSetup(bflist);  
        
    }
    
}