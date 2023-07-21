/* Method to Test CRM_SelectBVCProductController.
Added By: PWC
Added on: 29-Apr-2021
*/
@isTest (SeeAllData = false) 
public class TestCRM_SelectBVCProductController {
    static testMethod void testSelectBVCProductController() {
        Test.startTest();
        Account acc=new Account ();
        acc.name='test';
        insert acc;
        Product2 prd=new product2();
        prd.Product_Level_2__c='ValSHIP';
        prd.Product_Level_1__c='Domestic Valuables'; 
        prd.Name='Domestic Valuables';
        prd.IsActive=true;
        insert prd;
        
        Opportunity opp=new Opportunity();
        opp.Name='Test Oppty';
        opp.BVC_Product__c=prd.id;
        opp.StageName='Inbound Lead';
        opp.Amount=200;
        opp.CloseDate=date.today();
        opp.AccountId=acc.id;
        insert opp;
        List<String> prdlst=new List<String>();
        String secondlevelProduct='valship';
        prdlst.add(secondlevelProduct);
        String recid=opp.id;
        CRM_SelectBVCProductController.retrieveBVCProduct(opp.id);
        CRM_SelectBVCProductController.saveProductToDeal(prdlst,recid);
        Test.stopTest();
    }
}