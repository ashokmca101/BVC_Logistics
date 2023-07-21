@isTest
public class Send_Report_AttachementTest {
@testSetup static void testDataSetup(){
         
        RecordType rec=[SELECT id FROM RecordType WHERE name = 'Billing' and sobjecttype ='Account'];
         Account acc= new Account();
        acc.Name='Test1';
        acc.Last_Name__c='Test';
        acc.RecordTypeId=rec.id;
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        acc.Primary_Customer_Email__c='test1@bvc.com';
        insert acc;
      }
    @istest static void createAnnexureAccountTest1(){
       Send_Report_Attachement.fMethod();
    }
}