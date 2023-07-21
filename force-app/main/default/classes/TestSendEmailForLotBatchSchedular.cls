@istest
public class TestSendEmailForLotBatchSchedular {
    Static TestMethod Void SchedularForLotBatchMethod(){
        Test.startTest();
        SendEmailForLotBatchSchedular sh1 = new SendEmailForLotBatchSchedular();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
}