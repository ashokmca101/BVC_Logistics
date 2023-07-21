@istest
public class eShipFileUploadHprTest {

    @istest public static void BathFileUplaodTest(){
        Bath_Standard_Pricing__c bathstand= new Bath_Standard_Pricing__c(Secure_logistics_rate__c=300,Visit_Outcome__c='Successful',Origin_Destination_Pairing__c='Within City');
        insert bathstand;
        String Uid = UserInfo.getUserId();
       /* UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            BATH_eSHIP_Billing_Branch__c = 'MUMBAI-BDB',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        insert u;*/
        
        
        
        
        Hub__c hub = new  Hub__c(
            Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid
        );
        insert hub;
        
        
        Active_Pincode__c Pin = new Active_Pincode__c();
        Pin.Name = '100003';
        Pin.Hub__c = hub.Id;
        Entity__c entity = new Entity__c(Name = 'BVC Test Entity');
        insert entity;
        blng__LegalEntity__c leObj = new blng__LegalEntity__c(
                                            Name = 'Bvc Legal Entity',
                                            Billing_Authorised_Signatory__c = 'test Signatory',
                                            GSTIN__c = 'DHA528BA5Q',
                                            Billling_Entity_PAN_No__c = 'FHA5HWQ8A',
                                            GSTIN_Principle_Business_Address_Line_1__c = '123,house',
                                            CurrencyIsoCode = 'INR',
                                            GSTIN_State_Code__c = '28',
                                            Billing_Serial_Number__c = 01,
                                            blng__Active__c = true,
                                            blng__Country__c = 'India',
                                            BVC_Entity__c = entity.Id);
        insert leObj;
        Hub__c newHub = new Hub__c();
        newHub.Name='MUMBAI-BDB';
        newHub.Branch__c='AGRA';
        newHub.Billing_Entity_Name__c=leObj.id;
        newHub.Sales_person__c = Uid;
        insert newHub;
        
        insert Pin;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodESHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodiVALSHIP = new Product2(Name = 'Eship freight Charge',Family = 'Eship freight Charge',ProductCode='Eship freight Charge');
        Product2 prodiEVALSHIP = new Product2(Name = 'BVC ieSHIP',Family = 'BVC ieSHIP',ProductCode='BVC ieSHIP');
        Product2 prodExibiSHIP = new Product2(Name = 'BVC ExhibiSHIP',Family = 'BVC ExhibiSHIP',ProductCode='BVC ExhibiSHIP');
        prodList.add(prodBATh);
        prodList.add(prodESHIP);
        prodList.add(prodiVALSHIP);
        prodList.add(prodiEVALSHIP);
        prodList.add(prodExibiSHIP);
        insert prodList;
        list<PricebookEntry> PBentry = new list<PricebookEntry>();
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice1 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodBATh.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice2 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodESHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice3 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice4 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodiEVALSHIP.Id,UnitPrice = 0, IsActive = true);
        PricebookEntry BVCPrice5 = new PricebookEntry(Pricebook2Id = BVCPricebook.id, Product2Id = prodExibiSHIP.Id,UnitPrice = 0, IsActive = true);
        PBentry.add(standardPrice1);
        PBentry.add(standardPrice2);
        PBentry.add(standardPrice3);
        PBentry.add(standardPrice4);
        PBentry.add(standardPrice5);
        PBentry.add(BVCPrice1);
        PBentry.add(BVCPrice2);
        PBentry.add(BVCPrice3);
        PBentry.add(BVCPrice4);
        PBentry.add(BVCPrice5);
        insert PBentry;
        Account acc= new Account();
        acc.Name='Test';
        acc.Last_Name__c='Test';
        acc.RecordTypeId='0125g0000002XavAAE';
        acc.PAN_Number_of_Entity__c='546gtyhu78';
        insert acc;
        Contract con = new Contract();
        con.AccountId=acc.Id;
        con.Business_Type__c='Non ACR';
        con.BVC_Service__c='eSHIP';
        con.Status='Draft';
        con.EndDate=Date.newInstance(2028, 06, 09);
        con.StartDate=Date.Today();
        con.ContractTerm=12;
        con.Contract_Amount__c=150000;
        //con.SBQQ__Quote__c=qT.ID;
        insert con;
        con.Status='Activated';
        update con;
        Account ShipperAcc= new Account();
        ShipperAcc.Name='TestShipper';
        ShipperAcc.Last_Name__c='TestShipper';
        ShipperAcc.RecordTypeId='0125g0000002XazAAE';
        ShipperAcc.PAN_Number_of_Entity__c='546gtyhu78';
        insert ShipperAcc;
        AddressBook__c ab=new AddressBook__c();
            ab.name='demo';
            ab.ADDRESS1__c='Address1';
            ab.ADDRESS2__c='Address2';
            ab.CITY__c='city';
            ab.COUNTRY__c='India';
            ab.Customer__c=ShipperAcc.id;
        	ab.RecordTypeId='0125g0000002Xb1AAE';
            ab.PINCODE__c='100003';
            ab.District__c='district';
            ab.TRADE_NAME__c=ShipperAcc.name;
            ab.GSTIN__c='';
            
        insert ab;
        Account TestShipperAcc = [select ID,Account_Number__c from Account where Id=:ShipperAcc.Id];
        Account TestAcc = [select ID,Account_Number__c from Account where Id=:acc.Id];
        AddressBook__c TestAB = [select ID,Address_Number__c from AddressBook__c where Id=:ab.Id];
        string base64='[{"Docket No":"TEST-1","Order No":"C-452192258","Pincode":"100003","Consignee Name":"TEST-1","Consignee Email":"shahajal78@gmail.com","Consignee Phone No":"9769960288","Consignee Address":"KERALA","Payment Mode":"COD","Shipment Type":"Intercity","RTO":"Yes","From City":"Mumbai","To City":"Delhi","Docket Date":"09/02/2020","Booking Date":"09/02/2020","Declared Value":"10367","COD Amount":"4500","No Of Attempts":"12","Shipper Account":"'+TestShipperAcc.Account_Number__c+'","Shipper Address":"'+TestAB.Address_Number__c+'","Net weight in Gram":"7.7","Gross weight in Gram":"36","BVC Service":"eSHIP","Product Category":"Studded Jewellery","Customer Number":"'+TestAcc.Account_Number__c+'"}]';
        //eShipFileUploadHpr2.doChainJob = false;
        test.startTest();
        string message = eShipFileUploadHpr.parseFile(base64,'test');
        system.debug('message::::::::::::::::::'+message);
        test.stopTest();
    }
    
}