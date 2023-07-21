@IsTest
public class A5DocsCPQConfigCtrlTest {
    
    @IsTest
    static void testExecuteScript() {

        Test.startTest();

        A5DocsCPQConfigCtrl configCtrl = new A5DocsCPQConfigCtrl();
        configCtrl.executeScript();

        Test.stopTest();

        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE Name IN ('Email Quote', 'Email Invoice') ORDER BY Name DESC];
        Id emailQuoteId = templates[0].Id;
        Id emailInvoiceId = templates[1].Id;
        List<rsdoc__Document_Action__c> resultDocActions = [SELECT rsdoc__Email_Template__c FROM rsdoc__Document_Action__c];

        System.assertEquals(2, templates.size());
        System.assertEquals(4, resultDocActions.size());
        System.assertEquals(emailQuoteId, resultDocActions[0].rsdoc__Email_Template__c);
        System.assertEquals(emailInvoiceId, resultDocActions[1].rsdoc__Email_Template__c);
        System.assertEquals(emailInvoiceId, resultDocActions[2].rsdoc__Email_Template__c);
        System.assertEquals(emailQuoteId, resultDocActions[3].rsdoc__Email_Template__c);
    }
}