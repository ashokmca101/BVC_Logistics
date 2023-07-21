@isTest
public class TMS_ShipmentPdfController_Test {
    Public static String test12(){
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Shipping',True);
       Hub__c hb = BVCL_TestDataFactory.CreateHub('Test',True,'AGRA');
       Active_Pincode__c ap = BVCL_TestDataFactory.CreatePincode('Test',String.valueOf(hb.Id),'Agra','Test',True);
       AddressBook__c add = BVCL_TestDataFactory.CreateAddress('Shipping',String.valueOf(acc.Id),'Test',String.valueOf(ap.Id),'Test',True);
       Shipment__c sc = BVCL_TestDataFactory.CreateShipment(String.valueOf(acc.Id),String.valueOf(acc.Id),String.valueOf(add.Id),String.valueOf(acc.Id),String.valueOf(add.Id),true);
        sc.Invoice_Number__c = '10000000000000000021345678654323567865643454647';
        system.debug('#####'+sc.Invoice_Number__c.length());
        DataBase.SaveResult res = DataBase.update(sc, false);
        return String.valueOf(sc.Id);
    }
    @isTest static void TMS_ShipmentPdfController_Mthd1(){    
       
        Test.StartTest(); 
        PageReference testPage = Page.TMS_ShippingPdfPage; 
        testPage.getParameters().put('id', test12());
        Test.setCurrentPage(testPage);
        TMS_ShipmentPdfController testAccPlan = new TMS_ShipmentPdfController();
        Test.StopTest();
    } 
    @isTest static void TMS_ShipmentPdfController_Mthd2(){
        Test.StartTest(); 
        PageReference testPage1 = Page.TMS_ShippingPdfPage; 
        testPage1.getParameters().put('type', 'pre');
        testPage1.getParameters().put('list',test12());
        Test.setCurrentPage(testPage1);
        TMS_ShipmentPdfController testAccPlan = new TMS_ShipmentPdfController();
        Test.StopTest();
    }
    @isTest static void TMS_ShipmentPdfController_Mthd3(){
         Test.StartTest(); 
        PageReference testPage2 = Page.TMS_ShippingPdfPage; 
        testPage2.getParameters().put('type', 'post');
        testPage2.getParameters().put('list',test12());
        Test.setCurrentPage(testPage2);
        TMS_ShipmentPdfController testAccPlan = new TMS_ShipmentPdfController();
        Test.StopTest();
    }
}