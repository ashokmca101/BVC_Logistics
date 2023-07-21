/*Method to BulkShipmentImportController.
Added By: PWC
Added on: 15-07-2021
*/
@isTest (SeeAllData = false)
public class TestComm_BulkShipmentImportController {
    static testMethod void testmethod1() {
        String csvtojson='[{"Origin":"123123","Destination":"123123","BillingAddressReferenceNumber":"12982772","ProductDescription":"GoldJewellery","ShipmentValueinINR":"100","GrossWeightInKG":"200","NetWeightInGram":"501","InsuranceByBVC_Yes_or_No":"No","NumberOfPackages":"2","YourReferenceNumber":"ABC 123"},{"Origin":"1211222","Destination":"224455","BillingAddressReferenceNumber":"1288982822","ProductDescription":"GoldJewellery","ShipmentValueinINR":"100","GrossWeightInKG":"200","NetWeightInGram":"501","InsuranceByBVC_Yes_or_No":"No","NumberOfPackages":"1","YourReferenceNumber":"XYZ 488"}]';
        String destcsvtojson='[{"Destination":"123123","BillingAddressReferenceNumber":"12982772","ProductDescription":"GoldJewellery","ShipmentValueinINR":"100","GrossWeightInKG":"200","NetWeightInGram":"501","InsuranceByBVC_Yes_or_No":"No","NumberOfPackages":"2","YourReferenceNumber":"ABC 123"}]';
        String biltcsvtojson='[{"BillingAddressReferenceNumber":"12982772","ProductDescription":"GoldJewellery","ShipmentValueinINR":"100","GrossWeightInKG":"200","NetWeightInGram":"501","InsuranceByBVC_Yes_or_No":"No","NumberOfPackages":"2","YourReferenceNumber":"ABC 123"}]';
        String blatcsvtojson='[{"ProductDescription":"GoldJewellery","ShipmentValueinINR":"100","GrossWeightInKG":"200","NetWeightInGram":"501","InsuranceByBVC_Yes_or_No":"No","NumberOfPackages":"2","YourReferenceNumber":"ABC 123"}]';
        Profile adminProfile = [Select id from Profile where Name='System Administrator'];
        UserRole nonPortalRole = [Select PortalType, PortalAccountId From UserRole where PortalType !='CustomerPortal' limit 1];
        User adminUser = new User(alias = 'testABC', email='test123ABC@noemail.com',UserRoleId = nonPortalRole.Id,
                             emailencodingkey='UTF-8', lastname='TestingA', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = adminProfile.id, country='United States',IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testABC@noemail.com',PAN_Number_of_Entity__c='iupek54645',Name_As_Per_Pan_Manual_Input__c='abcAB',Firstname='TestingA');
        insert adminUser;
        Id p = [select id from profile where name='Custom Customer Community Plus Login User'].id;
        UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
        User newUser ;
        Account ac = new Account(name ='GrazittiABC',PAN_Number_of_Entity__c='jupek54645') ;
        System.runAs(adminUser){
            insert ac; 
            
            Contact con = new Contact(LastName ='testConABC',AccountId =ac.Id);
            con.MobilePhone = '1234567812';
            con.Email = 'testABC@gmail.com';
            insert con; 
            
            newUser = new User(
            //UserRoleId = ur.Id,
            profileId = p,
            username = 'newUser@yahoo.com',
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            firstName='GrazittiABC',
            lastname='lastname',
            contactId = con.id,
            isactive=true,
            PAN_Number_of_Entity__c='jupek54645',Name_As_Per_Pan_Manual_Input__c='abcAB'
            );
            insert newUser;
            system.debug('newUser'+newUser);
        }
            test.startTest();
        System.runAs(adminUser){
            String sub='test';
            map<String,String> str=Community_BulkShipmentImportController.getProducts();
            }    
        System.runAs(newUser){
            String Prdlist='Import';
            String Prdlistexception='Importt';
            Date shpmtdt=Date.Today();
            Community_BulkShipmentImportController.insertData(csvtojson,Prdlist,shpmtdt);
            Community_BulkShipmentImportController.insertData(destcsvtojson,Prdlist,shpmtdt);
            Community_BulkShipmentImportController.insertData(biltcsvtojson,Prdlist,shpmtdt);
            Community_BulkShipmentImportController.testCoverage();
            List<AddressBook__c> adr1=Community_BulkShipmentImportController.getAddressId('test',ac.id);
            List<AddressBook__c> adr2=Community_BulkShipmentImportController.getBilligAddressId('test',ac.id);
            //Community_BulkShipmentImportController.insertData(sub,ac.Id,csvtojson);
            //System.assert(newUser.id!=null);
            
            }
        	
          	test.stopTest();
    }
}