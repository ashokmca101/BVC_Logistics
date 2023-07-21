@isTest
public class CRM_QueuableFinancialSummaryAPI_Test {
    
     @testSetup static void setup() {
        // Create common test account
        Account testAccts = new Account();
        testAccts.name='Test1';
        testAccts.PAN_Number_of_Entity__c = 'AAACT5131A';
        testAccts.Entity_Id__c = 'ABVCD';
        insert testAccts;
    }
    
     
    @isTest
    static void testCRM_QueuableFinancialSummaryAPI(){
        Account accObj = [SELECT id,PAN_Number_of_Entity__c,Entity_Id__c FROM Account WHERE name='Test1'];
        string accId = string.valueOf(accObj.Id);
        CRM_QueuableFinancialSummaryAPI.doChainJob = false;
         Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForFinan());
        HttpRequest req = new HttpRequest();
        MockHttpResponseGeneratorForFinan mock = new MockHttpResponseGeneratorForFinan();
        HttpResponse res = mock.respond(req);
        
        
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.debug('actualValue:::'+res.getBody());
        System.assertEquals(200, res.getStatusCode());
        
        
        system.enqueueJob(new CRM_QueuableFinancialSummaryAPI(accId, accObj.Entity_Id__c, accObj.PAN_Number_of_Entity__c));
        //obj.execute(CRM_QueuableFinancialSummaryAPI);
        Test.stopTest();
    }
    
}