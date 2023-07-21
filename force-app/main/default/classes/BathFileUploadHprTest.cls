@istest 
public class BathFileUploadHprTest {
    
    @istest public static void BathFileUplaodTest(){
        Bath_Standard_Pricing__c bathstand= new Bath_Standard_Pricing__c(Secure_logistics_rate__c=300,Visit_Outcome__c='Successful',Origin_Destination_Pairing__c='Within City');
        insert bathstand;
        String Uid = UserInfo.getUserId();
        Hub__c hub = new  Hub__c(Name='Test',Branch__c='MUMBAI',Sales_person__c=Uid);
        insert hub;
        Active_Pincode__c Pin = new Active_Pincode__c();
        Pin.Name = '100003';
        Pin.Hub__c = hub.Id;
        insert Pin;
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
        insert newHub;
        List<Hub__c> BVCbranch = [select id,Name from Hub__c where Sales_person__c=:Uid];
        system.debug('hub'+BVCbranch);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Pricebook2 BVCPricebook = new Pricebook2(name='BVC INR Price Book',IsActive = true);
       	insert BVCPricebook;

        list<Product2> prodList = new list<Product2>();
       	Product2 prodBATh = new Product2(Name = 'BVC BATH',Family = 'BVC BATH',ProductCode='BVC BATH');
        Product2 prodESHIP = new Product2(Name = 'BVC eSHIP',Family = 'BVC eSHIP',ProductCode='BVC eSHIP');
        Product2 prodiVALSHIP = new Product2(Name = 'BATH freight Charge',Family = 'BATH freight Charge',ProductCode='BATH freight Charge');
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
        con.BVC_Service__c='BATH';
        con.BVC_Branch__c=newHub.id;
        con.BVC_Billing_Entity__c=leObj.id;
        con.Status='Draft';
        con.StartDate=Date.Today();
        con.EndDate=Date.newInstance(2028, 06, 09);
        con.ContractTerm=12;
        con.Contract_Amount__c=150000;
        //con.SBQQ__Quote__c=qT.ID;
        insert con;
        con.Status='Activated';
        update con;
        Account TestAcc = [select ID,Account_Number__c from Account where Id=:acc.Id];
        string base64='[{"BVC Service":"BATH","Customer Number":"'+TestAcc.Account_Number__c+'","Total Invoice Value":"24232","Visit Outcome":"Successful","Origin Destination Pairing":"Within City","Product Category":"Studded Jewellery","Month":"Aug","Lead Date":"20/07/2022","Appt Date":"30/08/2022","Reschdule Date":"15/09/2022","Status":"Confirmed","Actual Date Of Visit":"10/09/2022","Customer Lead Id":"6607","Consignee Name":"SARVESH B","Consignee Email":"scsfgvd89@gmail.com","Consignee Phone No":"123456356","Consignee Address":"2701, 27th floor Orion tower","Pincode":"100003","SKU":"UT00874-1Y0000","price":"7895","Barcode":"BC12351020T","Barcode Location":"CL-ST-MUM-Bandra Turner Road","BVC AWB NO":"101","Bag NO":"4566","Dispatch Date":"13/09/2022","BVC REMARK":"Sold Bracelet @11496","Jewellery Category":"Studded","JSA":"sakshi"}]';
        
        test.startTest();
        string message = BathFileUploadHpr.parseFile(base64,'test');
        system.debug('message::::::::::::::::::'+message);
        test.stopTest();
    }
    public static List<JSON2ApexController> parse(String XlsxAsAString1) {
        return (List<JSON2ApexController>) System.JSON.deserialize(XlsxAsAString1, List<JSON2ApexController>.class);
    }
    public with sharing class JSON2ApexController {      
        public String Month;
        public String LeadDate;
        public String ApptDate;
        public String ReschduleDate;
        public String Status;
        public String ActualDateOfVisit;
        public String CustomerLeadId;
        public String ConsigneeName;
        public String ConsigneeEmail;
        public String ConsigneePhoneNo;
        public String ConsigneeAddress;
        public String Pincode;
        public String SKU;
        public String price;
        public String Barcode;
        public String BarcodeLocation;
        public String COMMENTS;
        public String ILONO;
        public String BVCAWBNO;
        public String BagNO;
        public String HandoverDone;
        public String DispatchDate;
        public String ILOInwardAtBVCFacility;
        public String TAHMemoDate;
        public String CustomerAppointmentConfimationDetails;
        public String BVCDeliveryStatus;
        public String DeliveryDate;
        public String BVCREMARK;
        public String InwardDate;
        public String JewelleryCategory;
        public String Success;
        public String SaleValue;
        public String PaymentMode;
        public String JSA;
        public String REVERSE;
        public String CustomerNumber;
        public String TotalInvoiceValue;
        public String VisitOutcome;
        public String OriginDestinationPairing;
        public String ProductCategory;
        public String BVCService;       
	} 
}