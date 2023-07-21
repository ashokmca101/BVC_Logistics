public class A5DocsCPQConfigCtrl {

    public String currentUrl {get; set;}

    // Flag to report if messages are present
    public Boolean hasMessages {
        get {
            return ApexPages.hasMessages();
        }
    }
    
    // Flag to report if errors are present
    public Boolean hasErrors {
        get {
            return ApexPages.hasMessages(ApexPages.Severity.ERROR) || ApexPages.hasMessages(ApexPages.Severity.FATAL);
        }
    }

    public A5DocsCPQConfigCtrl() {}

    public void executeScript() {
        List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name IN ('Email Quote', 'Email Invoice') ORDER BY Name DESC];
        Id emailQuoteId = emailTemplates[0].Id;
        Id emailInvoiceId = emailTemplates[1].Id;

        List<rsdoc__Document_Action__c> documentActions = new List<rsdoc__Document_Action__c>();

        documentActions.add( new rsdoc__Document_Action__c(
            rsdoc__Email_Template__c = emailQuoteId,
            rsdoc__Template_Document_ID__c = '10zfoqMp8-wNi3hS9Z0HED9FmLwfmF9VIeothFTJjXvg',
            rsdoc__Template_Name__c = 'Email Quote',
            rsdoc__Base_object_API__c = 'SBQQ__Quote__c',
            rsdoc__Visibility__c = 'Link',
            rsdoc__Email_File_As__c = 'Attachment',
            rsdoc__Email_Action__c = 'Preview',
            rsdoc__Access__c = 'Can comment',
            rsdoc__Output_format__c = 'pdf',
            rsdoc__Send_for_Signature_Action__c = '',
            rsdoc__Counter_Sign_Method__c = '',
            rsdoc__Email_To__c = '{!SBQQ__Quote__c.SBQQ__PrimaryContact__c}',
            rsdoc__Folder_ID__c = '',
            rsdoc__Field_To_Update__c = 'SBQQ__Status__c',
            rsdoc__Field_To_Update_Value__c = 'Sent',
            rsdoc__Parent_Lookup_Field_Name__c = '',
            rsdoc__Save_in_Field__c = 'Quote_Doc_URL__c',
            rsdoc__Email_From_Org_Wide_Address__c = '',
            rsdoc__Attach_File__c = true
        ));

        documentActions.add( new rsdoc__Document_Action__c(
            rsdoc__Email_Template__c = emailInvoiceId,
            rsdoc__Template_Document_ID__c = '1RbRn6Yhnwnqg1PmNDHGCTJ_qAW60sp-4Mf5plAJQbUE',
            rsdoc__Template_Name__c = 'Email Invoice Preview',
            rsdoc__Base_object_API__c = 'blng__Invoice__c',
            rsdoc__Visibility__c = 'Link',
            rsdoc__Email_File_As__c = 'Attachment',
            rsdoc__Email_Action__c = 'Preview',
            rsdoc__Access__c = 'Can comment',
            rsdoc__Output_format__c = 'pdf',
            rsdoc__Send_for_Signature_Action__c = '',
            rsdoc__Counter_Sign_Method__c = '',
            rsdoc__Email_To__c = '{!blng__Invoice__c.blng__BillToContactId__c}',
            rsdoc__Folder_ID__c = '1_FkV6H1xSGBkpE2ux7R8hNS39FbrYX_X',
            rsdoc__Field_To_Update__c = 'Send_Status__c',
            rsdoc__Field_To_Update_Value__c = 'Sent',
            rsdoc__Parent_Lookup_Field_Name__c = '',
            rsdoc__Save_in_Field__c = 'Invoice_Doc_URL__c',
            rsdoc__Email_From_Org_Wide_Address__c = '',
            rsdoc__Attach_File__c = true
        ));

        documentActions.add( new rsdoc__Document_Action__c(
            rsdoc__Email_Template__c = emailInvoiceId,
            rsdoc__Template_Document_ID__c = '1RbRn6Yhnwnqg1PmNDHGCTJ_qAW60sp-4Mf5plAJQbUE',
            rsdoc__Template_Name__c = 'Email Invoice Autosend',
            rsdoc__Base_object_API__c = 'blng__Invoice__c',
            rsdoc__Visibility__c = 'Link',
            rsdoc__Email_File_As__c = 'Attachment',
            rsdoc__Email_Action__c = 'Autosend',
            rsdoc__Access__c = 'Can comment',
            rsdoc__Output_format__c = 'pdf',
            rsdoc__Send_for_Signature_Action__c = '',
            rsdoc__Counter_Sign_Method__c = '',
            rsdoc__Email_To__c = '{!blng__Invoice__c.blng__BillToContact__c}',
            rsdoc__Folder_ID__c = '1_FkV6H1xSGBkpE2ux7R8hNS39FbrYX_X',
            rsdoc__Field_To_Update__c = 'Send_Status__c',
            rsdoc__Field_To_Update_Value__c = 'Sent',
            rsdoc__Parent_Lookup_Field_Name__c = '',
            rsdoc__Save_in_Field__c = 'Invoice_Doc_URL__c',
            rsdoc__Email_From_Org_Wide_Address__c = '0D25w000000LBKe',
            rsdoc__Attach_File__c = true
        ));

        documentActions.add( new rsdoc__Document_Action__c(
            rsdoc__Email_Template__c = emailQuoteId,
            rsdoc__Template_Document_ID__c = '1qh9v8JOrkBSMF6YGOPdBhlX5zMXk-DukJI1uVrdhNAI',
            rsdoc__Template_Name__c = 'Email Group Quote',
            rsdoc__Base_object_API__c = 'SBQQ__Quote__c',
            rsdoc__Visibility__c = 'Link',
            rsdoc__Email_File_As__c = 'Attachment',
            rsdoc__Email_Action__c = 'Preview',
            rsdoc__Access__c = 'Can comment',
            rsdoc__Output_format__c = 'pdf',
            rsdoc__Send_for_Signature_Action__c = '',
            rsdoc__Counter_Sign_Method__c = '',
            rsdoc__Email_To__c = '{!SBQQ__Quote__c.SBQQ__PrimaryContact__c}',
            rsdoc__Folder_ID__c = '',
            rsdoc__Field_To_Update__c = 'SBQQ__Status__c',
            rsdoc__Field_To_Update_Value__c = 'Sent',
            rsdoc__Parent_Lookup_Field_Name__c = '',
            rsdoc__Save_in_Field__c = 'Quote_Doc_URL__c',
            rsdoc__Email_From_Org_Wide_Address__c = '',
            rsdoc__Attach_File__c = true
        ));

        try {
            if (!documentActions.isEmpty()) {
                insert documentActions;
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Script run was successful.'));
        }

        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex.getMessage()));
            System.debug('Error: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}