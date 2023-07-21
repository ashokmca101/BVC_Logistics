/*
* Created By: PwC
* Specification:TestAutoConvertLeads Class is to test AutoConvertLeads class.
* Date:11/02/2021
*/
@isTest (SeeAllData = false)
public class TestAutoConvertLeads{
    static testMethod void createnewlead() {
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        
        Test.startTest();
        Product2 prd=new Product2();
        prd.Name='Domestic Valuables';
        prd.IsActive = true;
        insert prd;
        system.debug('----'+prd.Id);
        Lead leadToCreate =new Lead();
        Set<id> Ids= New Set<Id>();
        //leadToCreate.ownerid= userToCreate.id;
        leadToCreate.LastName ='Gupta';
        leadToCreate.Company='Salesforce';
        //leadToCreate.LeadSource='Partner Referral';
        leadToCreate.Rating='Hot';
        leadToCreate.Status='';
        leadToCreate.Email = 'test@gmail.com';
        leadToCreate.Product__c='Domestic Valuables' ;   
        insert leadToCreate; 
        Ids.add(leadToCreate.id);
        //AutoConvertLeads.LeadAssign(Ids);
        Test.stopTest();
    }
}