@isTest
public class TMS_Lookup2Test {
    public static testmethod void lookupTest(){
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Account ShipperAcc1 = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer1','Billing',true);
        TMS_Lookup2.searchDB('Account', 'name', 'Id', 2, 'name', 'BVCL', 'Shipping', '', '', '','','ST_Pricing_Type__c');
        TMS_Lookup2.searchDB('Account', 'name', 'Id', 2, 'name', 'BVCL', 'Billing', '', '', '','','ST_Pricing_Type__c');
        TMS_Lookup2.searchDB('AddressBook__c', 'name', 'Id', 2, 'name', '', 'Billing', '', '', '',ShipperAcc.Id,'');       
    }
}