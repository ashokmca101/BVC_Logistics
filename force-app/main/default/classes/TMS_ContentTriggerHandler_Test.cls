@isTest
public class TMS_ContentTriggerHandler_Test {
    public static testMethod void createPublicLinkForFileTest(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Signature',
            PathOnClient = 'Signature.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
    }
}