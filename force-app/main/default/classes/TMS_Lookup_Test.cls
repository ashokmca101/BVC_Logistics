@isTest
public class TMS_Lookup_Test {
    public static testmethod void lookupTest(){
        TMS_Lookup.searchDB('Transport__c', 'name', 'Id', 2, 'name', 'Del', 'BVC Vehicle', '', '', '');
        TMS_Lookup.searchDB('Secure_Packaging__c', 'name', 'Id', 2, 'name', 'Del', '', '', '', 'Secure Bag');
        TMS_Lookup.searchDB('Flight_Schedule__c', 'name', 'Id', 2, 'name', 'Del', '', 'OriginPort', 'DestPort', '');
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        TMS_Lookup.searchDB('Account', 'name', 'Id', 2, 'name', 'BVCL', 'Shipping', '', '', '');
    }
}