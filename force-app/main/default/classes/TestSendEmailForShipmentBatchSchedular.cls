@istest
public class TestSendEmailForShipmentBatchSchedular {

    Static TestMethod Void SchedularForShipmentMethod(){
        Test.startTest();
        SendEmailForShipmentBatchSchedular sh1 = new SendEmailForShipmentBatchSchedular();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check Shipment', sch, sh1);
        Test.stopTest();
        
    }
}