/******************************************
     * Created By: Anamika Shinde
* *****************************************/
@isTest
Private class DealTriggerBVCHelperTestClass {
    @istest static void unittest(){
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
       update standardPricebook;

       Product2 prod = new Product2(Name = 'Laptop X200', 
       Family = 'BATH',ProductCode='BVC Eship service');
        insert prod;

        //Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPricebook.id, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
    }
    
     /******************************************
     * Created By: Anamika Shinde
     * Created Date: 23-08-2022
     * Purpose: Test Method Of DealTriggerBVCHelper class insertPeopleRole Method
     * *****************************************/
    @istest static void insertPeopleRoleTest(){
         Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test@bvc.com';
        insert acc;
        //Insert People 
        Contact cc=new Contact();
        cc.FirstName='Test';
        cc.LastName='Test';
        cc.Title='Customer';
        cc.MobilePhone='77209373737';
        cc.AccountId=acc.id;
        //cc.RecordTypeId='0125g0000002Xb4AAE';
        Insert cc;

        //Insert Oppourtunity
        List<Opportunity> opp1 = new List<Opportunity>();
        Opportunity opp=new Opportunity();
        //opp.BVC_Product__c ='01t0w000002sqOuAAI';
        opp.Name = 'test1';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.newInstance(2016, 12, 9);
        opp.StageName = 'Inbound Lead';
        //opp.Authorised_Signatory_People__c=cc.id;
        opp.Decision_Maker__c=cc.id;
        opp.Evaluator__c=cc.id;
        opp.Influencer__c=cc.id;
        insert opp;
        opp1.add(opp);
        DealTriggerBVCHelper.insertPeopleRole(opp1);
        
    }
}