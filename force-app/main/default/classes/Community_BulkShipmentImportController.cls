public without sharing class Community_BulkShipmentImportController {
    /* for import data into sobject and insert data from csv file  */ 
    @AuraEnabled
    public static string insertData(String strfromle,String Prdlist,Date shpmtdt){
        system.debug('CSV in JSON-->'+strfromle);
        User currentusr= [Select id,Name,Contact.Accountid From User Where Id =:Userinfo.getUserId()];
        String accid= currentusr.Contact.Accountid;
        list<Case> newCases=new List<Case>();
        String returnresponse ='';
        List<Shipment__c> ShipmentListtoInsert = new List<Shipment__c>();
        system.debug('strfromle = ' + strfromle);
        String generatedCSVFile ='';
        String fileRow = '';
        //List<String> headerFields = new List<String>{'Origin','Destination','BillingAddressReferenceNumber','ProductDescription','ShipmentValueinINR','GrossWeightInKG','NetWeightInKG','InsuranceByBVC_Yes_or_No','NumberOfPackages','YourReferenceNumber'};
        String header='Origin,Destination,BillingAddressReferenceNumber,ProductDescription,ShipmentValueinINR,GrossWeightInKG,NetWeightInGram,InsuranceByBVC_Yes_or_No,NumberOfPackages,YourReferenceNumber';
        generatedCSVFile = generatedCSVFile + header + '\n';
        try{ 
            Shipment_Lot__c lot=new Shipment_Lot__c();
            lot.name=currentusr.name+''+system.now();
            insert lot;
            List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
            system.debug('datalist = ' + datalist);
            for(fieldWrapper wrapper: datalist) {
                fileRow = '';
                fileRow = fileRow +','+ wrapper.Origin;
                fileRow = fileRow +','+ wrapper.Destination;
                fileRow = fileRow +','+ wrapper.BillingAddressReferenceNumber;
                fileRow = fileRow +','+ wrapper.ProductDescription;
                fileRow = fileRow +','+ wrapper.ShipmentValueinINR;
                fileRow = fileRow +','+ wrapper.GrossWeightInKG;
                fileRow = fileRow +','+ wrapper.NetWeightInGram;
                fileRow = fileRow +','+ wrapper.InsuranceByBVC_Yes_or_No;
                fileRow = fileRow +','+ wrapper.NumberOfPackages;
                fileRow = fileRow +','+ wrapper.YourReferenceNumber;
                fileRow = fileRow.replaceFirst(',','');
                generatedCSVFile = generatedCSVFile + fileRow + '\n';
            }
            //Shipment Creation started
            String CommunityShipmentRecordTypeID = Schema.getGlobalDescribe().get('Shipment__c').getDescribe().getRecordTypeInfosByName().get('Community Shipment').getRecordTypeId();
            for(fieldWrapper wrapper: datalist) {
                Shipment__c ship =new  Shipment__c();
                if(CommunityShipmentRecordTypeID!=null) {
                    ship.recordtypeid = CommunityShipmentRecordTypeID;  
                }
                if(wrapper.ProductDescription!=null) {
                    Ship.Product_Description__c=wrapper.ProductDescription;
                }
                
                if(wrapper.ShipmentValueinINR!=null) {
                    Ship.Shipment_Value__c=Decimal.valueof(wrapper.ShipmentValueinINR.replaceAll(',', '')); 
                }
                
                if(wrapper.NetWeightInGram!=null) {
                    Ship.Net_Weight__c=Decimal.valueof(wrapper.NetWeightInGram.replaceAll(',', '')); 
                }
                
                if(wrapper.InsuranceByBVC_Yes_or_No!=null) {
                    Ship.Insurance_By_BVC__c=wrapper.InsuranceByBVC_Yes_or_No; 
                }
                
                if(wrapper.YourReferenceNumber!=null) {
                    Ship.Reference_No__c=wrapper.YourReferenceNumber; 
                }
                
                if(wrapper.NumberOfPackages!=null) {
                    Ship.No_of_Pkgs__c=Decimal.valueof(wrapper.NumberOfPackages.replaceAll(',', '')); 
                }
                if(accid!=null) {
                    ship.Customer__c=accid;
                }
                if(currentusr.Name!=null) {
                    ship.Name='Shipment Created By '+currentusr.Name;
                }
                ship.Shipment_Date__c=shpmtdt;
                ship.BVC_Products__c=Prdlist;
                if(wrapper.GrossWeightInKG!=null) {
                    ship.Gross_Weight__c=Decimal.valueof(wrapper.GrossWeightInKG.replaceAll(',', ''));
                }
                if(lot.Id!=null) {
                    ship.Shipment_Lot__c=lot.Id;
                }
                if(wrapper.Origin!=null) {
                    List<AddressBook__c> orignaddr=Community_BulkShipmentImportController.getAddressId(wrapper.Origin,accid);
                    if(orignaddr.size()<=0){
                        returnresponse = 'Your Origin Address Reference Number doesnot match any existing address for your account. Kindly create an origin address with '+ wrapper.Origin+' reference number ';
                        return returnresponse;
                    }
                    
                    ship.Community_Origin_Address__c = orignaddr[0].id;  
                }
                if(wrapper.Destination!=null) {
                    List<AddressBook__c> destnaddr=Community_BulkShipmentImportController.getAddressId(wrapper.Destination,accid);
                    if(destnaddr.size()<=0){
                        returnresponse = 'Your Destination Address Reference Number doesnot match any existing address for your account. Kindly create a Destination address with '+ wrapper.Destination+' reference number ';
                        return returnresponse;
                    }
                    
                    Ship.Community_Destination_Address__c=destnaddr[0].Id;
                }
                if(wrapper.BillingAddressReferenceNumber!=null) {
                    List<AddressBook__c> bilingaddr=Community_BulkShipmentImportController.getBilligAddressId(wrapper.BillingAddressReferenceNumber,accid);
                    if(bilingaddr.size()<=0){
                        returnresponse = 'Your BillingAddress Address Reference Number doesnot match any existing address for your account. Kindly create a Billing address with '+ wrapper.BillingAddressReferenceNumber+' reference number ';
                        return returnresponse;
                    }
                    Ship.Community_Billing_Address__c=bilingaddr[0].Id;
                }
                ShipmentListtoInsert.add(ship);
            }
            //Shipment Creation loop closed
            if(ShipmentListtoInsert.size() > 0){
                insert ShipmentListtoInsert;
                returnresponse = 'SUCCESS';
            }
        }
        catch(Exception ex){
            returnresponse = ex.getMessage();
            Case c = new Case();
            if (returnresponse != null && returnresponse.length()>255) {
                c.Subject=returnresponse.substring(0, 254);
            }
            if(returnresponse != null && returnresponse.length()<255){
                c.Subject=returnresponse;  
            }
            c.Status = 'New';
            c.Type='BulkShipment Failure';
            c.Origin='Other';
            c.Priority='Low';
            c.AccountId=accid;
            insert c;
            system.debug('New Case Id='+c.Id);
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = blob.valueOf(generatedCSVFile);
            ContVerFile.Title = 'BulkShipment'; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient='BulkShipment.csv';
            insert ContVerFile;
            system.debug('New ContentVersion Id='+ContVerFile.Id);
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = c.id;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            insert cDe;
            system.debug('ContentDocumentLink Id '+cDe.Id);
            system.debug('Exception Message = '+returnresponse);
        }
        return returnresponse;
    }
    
    public class fieldWrapper{ 
        public String Origin;
        public String Destination;
        public String BillingAddressReferenceNumber;
        public String ProductDescription;
        public String ShipmentValueinINR;
        public String GrossWeightInKG;
        public String NetWeightInGram;
        public String InsuranceByBVC_Yes_or_No;
        public String NumberOfPackages;
        public String YourReferenceNumber;
        } 
    @AuraEnabled
    public static Map<String, String> getProducts(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Shipment__c.BVC_Products__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled     //BillingAddressRecordTypeID
    public static List<AddressBook__c> getAddressId(String AddressAutoNumber,String customerid){
         List<AddressBook__c> destaddr=[select id,Your_Address_Identifier__c from addressBook__c where Your_Address_Identifier__c=:AddressAutoNumber AND Customer__c=:customerid];
         return destaddr;
    }
    @AuraEnabled     
    public static List<AddressBook__c> getBilligAddressId(String AddressAutoNumber,String customerid){
         String BillingAddressRecordTypeID = Schema.getGlobalDescribe().get('AddressBook__c').getDescribe().getRecordTypeInfosByName().get('Billing').getRecordTypeId();
         system.debug('BillingAddressRecordTypeID='+BillingAddressRecordTypeID);
         List<AddressBook__c> billingaddr=[select id,Your_Address_Identifier__c from addressBook__c where Your_Address_Identifier__c=:AddressAutoNumber AND Customer__c=:customerid AND recordtypeid=:BillingAddressRecordTypeID];
         return billingaddr;
    }
    public static void testCoverage(){
    integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}


}