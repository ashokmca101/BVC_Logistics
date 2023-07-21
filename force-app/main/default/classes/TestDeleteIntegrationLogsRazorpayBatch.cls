@isTest
private class TestDeleteIntegrationLogsRazorpayBatch {
    // Test data
    private static List<Integration_Log__c> testLogs;

    // Create test data
    private static void createTestData() {
        testLogs = new List<Integration_Log__c>();
        for (Integer i = 0; i < 200; i++) {
            Integration_Log__c log = new Integration_Log__c();
            log.Integration_Server__c = 'Razorpay';
            log.CreatedDate = Date.today().addDays(-90);
            testLogs.add(log);
        }
        insert testLogs;
    }

    // Test the batch class
    @isTest
    static void testBatch() {
        createTestData();
        Test.startTest();
            Database.executeBatch(new DeleteIntegrationLogsRazorpayBatch(), 2000);
        Test.stopTest();
        List<Integration_Log__c> logs = [SELECT Id FROM Integration_Log__c WHERE Integration_Server__c = 'Razorpay' AND CreatedDate < LAST_N_DAYS : 60];
        System.assertEquals(0, logs.size(), 'Records not deleted');
    }
}