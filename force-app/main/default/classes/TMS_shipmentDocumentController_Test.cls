@isTest
public class TMS_shipmentDocumentController_Test {
    public static testmethod void ShipDocTest(){
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label','EZ333','Available',false);
        Label.Allocated_To_Hub__c = DelhiHub.id;
        insert Label;
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipment_Date__c = system.today();
        insert Ship1;
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('ReqType','PreShipment');
        TMS_shipmentDocumentController tms1 = new TMS_shipmentDocumentController();
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,UserInfo.getUserId(),'Manager',true,true);
        TMS_shipmentDocumentController tms = new TMS_shipmentDocumentController();
        TMS_shipmentDocumentController.getShipmentData(ShipperAcc.id, DelhiHub.id, DelhiHub.id, system.today());
        List<string> ShipIdList = new List<string>();
        ShipIdList.add(Ship1.id);
        TMS_shipmentDocumentController.shipmentJson= json.serialize(ShipIdList);
        TMS_shipmentDocumentController.openAsPdf();
        TMS_shipmentDocumentController.ShipmentLabelWrapper wrap = new TMS_shipmentDocumentController.ShipmentLabelWrapper();
        tms.GeneratePreShipmentPdf();
        wrap.sp = Label;
        wrap.selected =true;
        tms.LabelWrapList.add(wrap);
        tms.GeneratePreShipmentPdf();
        
        //cover TMS_ShipmentPdfController
        ApexPages.currentPage().getParameters().put('type','pre');
        ApexPages.currentPage().getParameters().put('list',Label.id);
        TMS_ShipmentPdfController pdf = new TMS_ShipmentPdfController();
        ApexPages.currentPage().getParameters().put('type','post');
        ApexPages.currentPage().getParameters().put('list',Ship1.id);
        TMS_ShipmentPdfController pdf1 = new TMS_ShipmentPdfController();
        ApexPages.currentPage().getParameters().put('id',Ship1.id);
        TMS_ShipmentPdfController pdf2 = new TMS_ShipmentPdfController();
        test.stopTest();
    }
}