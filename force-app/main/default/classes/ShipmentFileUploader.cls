/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ShipmentFileUploader {
    public string nameFile          {get;set;}
    public Blob contentFile         {get;set;}
    String[] filelines = new String[]{};
        List<Shipment__c> shipmentstoupload;
    
    /***This function reads the CSV file and inserts records into the Account object. ***/
    public Pagereference ReadFile(){
        Set<String> nonExistingCustomers = new Set<String>();
        Set<String> nonExistingBillingAccs = new Set<String>();
        //Set<String> nonExistingbillingAddrs = new Set<String>();
        Set<String> nonExistingShippingAccs = new Set<String>();
        //Set<String> nonExistingOriginAddrs = new Set<String>();
        Set<String> nonExistingConsigneeAccs = new Set<String>();
        //Set<String> nonExistingDestinationAddrs = new Set<String>();
        try{
            //Convert the uploaded file which is in BLOB format into a string
            nameFile =blobToString( contentFile,'ISO-8859-1');
            
            //Now sepatate every row of the excel file
            filelines = nameFile.split('\n');
            
            //Iterate through every line and create a Account record for each row
            Set<String> CustomerNames = new Set<String>();
            Set<String> AddressNames = new Set<String>();
            Map<string,string> CustomerNameMap = new Map<string,string>();
            /*Map<string,string> AddressNameMap = new Map<string,string>();*/
            // System.debug('size: '+filelines.size());
            for (Integer i=1;i<filelines.size();i++){
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                // System.debug('inputvalues: '+inputvalues);
                if(inputvalues[0]!=null && inputvalues[0]!='')
                    CustomerNames.add(inputvalues[0]);
                // System.debug('inputvalues[0]: '+inputvalues[0]);
                if(inputvalues[1]!=null && inputvalues[1]!='')
                    CustomerNames.add(inputvalues[1]);
                /*if(inputvalues[2]!=null && inputvalues[2]!='')
                    AddressNames.add(inputvalues[2]);*/
                if(inputvalues[3]!=null && inputvalues[3]!='')
                    CustomerNames.add(inputvalues[3]);
                /*if(inputvalues[4]!=null && inputvalues[4]!='')
                    AddressNames.add(inputvalues[4]);*/
                if(inputvalues[5]!=null && inputvalues[5]!='')
                    CustomerNames.add(inputvalues[5]);
                /*if(inputvalues[6]!=null && inputvalues[6]!='')
                    AddressNames.add(inputvalues[6]);*/
            }
            
            if(CustomerNames!=null && CustomerNames.size()>0){
                for(Account ac:[select id,name FROM Account WHERE Name=:CustomerNames]){
                    CustomerNameMap.put(ac.name,ac.Id);
                }
            }
            
            /*if(AddressNames!=null && AddressNames.size()>0){
                for(AddressBook__c ab:[select id,name FROM AddressBook__c WHERE Name=:AddressNames]){
                    AddressNameMap.put(ab.name,ab.Id);
                }
            }*/
            
            shipmentstoupload = new List<Shipment__c>();
            for (Integer i=1;i<filelines.size();i++){
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                
                Shipment__c s = new Shipment__c();
                
                if(inputvalues[0]!=null && inputvalues[0]!=''){
                    if(CustomerNameMap.containsKey(inputvalues[0]))
                        s.Customer__c = CustomerNameMap.get(inputvalues[0]);
                    else
                        nonExistingCustomers.add(inputvalues[0]);
                }
                
                if(inputvalues[1]!=null && inputvalues[1]!=''){
                    if(CustomerNameMap.containsKey(inputvalues[1]))
                        s.Billing_Account__c = CustomerNameMap.get(inputvalues[1]);
                    else
                        nonExistingBillingAccs.add(inputvalues[1]);
                }
                
                /*if(inputvalues[2]!=null && inputvalues[2]!=''){
                    if(AddressNameMap.containsKey(inputvalues[2]))
                        s.Billing_Address__c = AddressNameMap.get(inputvalues[2]);
                    else
                        nonExistingbillingAddrs.add(inputvalues[2]);
                }*/
                
                if(inputvalues[2]!=null && inputvalues[2]!='')
                    s.Billing_Address__c = inputvalues[2];
                
                if(inputvalues[3]!=null && inputvalues[3]!=''){
                    if(CustomerNameMap.containsKey(inputvalues[3]))
                        s.Shipper_Name_TMS__c = CustomerNameMap.get(inputvalues[3]);
                    else
                        nonExistingShippingAccs.add(inputvalues[3]);
                }
                
                /*if(inputvalues[4]!=null && inputvalues[4]!=''){
                    if(AddressNameMap.containsKey(inputvalues[4]))
                        s.Origin_Address_Name__c = AddressNameMap.get(inputvalues[4]);
                    else
                        nonExistingOriginAddrs.add(inputvalues[4]);
                }*/
                
                if(inputvalues[4]!=null && inputvalues[4]!='')
                    s.Origin_Address_Name__c= inputvalues[4];
                
                if(inputvalues[5]!=null && inputvalues[5]!=''){
                    if(CustomerNameMap.containsKey(inputvalues[5]))
                        s.Consignee_Name_TMS__c = CustomerNameMap.get(inputvalues[5]);
                    else
                        nonExistingConsigneeAccs.add(inputvalues[5]);
                }
                
                /*if(inputvalues[6]!=null && inputvalues[6]!=''){
                    if(AddressNameMap.containsKey(inputvalues[6]))
                        s.Destination_Address_Name__c = AddressNameMap.get(inputvalues[6]);
                    else
                        nonExistingDestinationAddrs.add(inputvalues[6]);
                }*/
                
                if(inputvalues[6]!=null && inputvalues[6]!='')
                    s.Destination_Address_Name__c = inputvalues[6];
                    
                if(inputvalues[7]!=null && inputvalues[7]!='')
                    s.Shipment_Date__c = Date.valueOf(inputvalues[7]);
                if(inputvalues[8]!=null && inputvalues[8]!='')
                    s.Shipping_Note_Number__c = inputvalues[8];
                if(inputvalues[9]!=null && inputvalues[9]!='')
                    s.Shipment_Value__c = Decimal.valueOf(inputvalues[9]);
                if(inputvalues[10]!=null && inputvalues[10]!='')
                    s.Net_Weight__c = Decimal.valueOf(inputvalues[10]);
                if(inputvalues[11]!=null && inputvalues[11]!='')
                    s.Gross_Weight__c = Decimal.valueOf(inputvalues[11]);
                if(inputvalues[12]!=null && inputvalues[12]!='')
                    s.Insurance_By__c = inputvalues[12];
                
                shipmentstoupload.add(s);
            }
        }
        catch(Exception e){
            // System.debug('line: '+e.getLineNumber()+' msg: '+e.getMessage());
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file: '+e.getLineNumber()+e.getMessage());
            ApexPages.addMessage(errormsg);
            return null;
        }       
        //Finally, insert the collected records
        try{
            List<Database.Error> errorList = new List<Database.Error>();
            Database.SaveResult[] srList = Database.insert(shipmentstoupload, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    //// System.debug('ID: ' + sr.getId() );
                } else {
                    // This condition will be executed for failed records
                    for(Database.Error objErr : sr.getErrors()) {
                        //// System.debug('The following error has occurred.');
                        errorList.add(objErr);
                        //// System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        //// System.debug('Invoice oject field which are affected by the error:' + objErr.getFields());
                    }
                }
            }
            if(nonExistingCustomers !=null && nonExistingCustomers.size()>0){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Customer not found: '+nonExistingCustomers);
            	ApexPages.addMessage(errormsg);
            }
            if(errorList.size()==0 ){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'Records inserted successfully!');
            	ApexPages.addMessage(errormsg);
            }else{
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error on- '+errorList[0].getFields() + ' : '+errorList[0].getMessage());
            	ApexPages.addMessage(errormsg);
            }
            
        }
        catch (Exception e){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Something went wrong: '+e.getLineNumber()+e.getMessage());
            ApexPages.addMessage(errormsg);
            return null;
        }    
        return null;
    }
    
    /**** This function sends back to the visualforce page the list of account records that were inserted ****/ 
    public List<Shipment__c> getuploadedShipments(){
        List<Shipment__c> returnShipList = new List<Shipment__c>();
        if(shipmentstoupload!= null && shipmentstoupload.size() > 0){
            for(Shipment__c sh:shipmentstoupload){
                if(sh.id !=null)
                    returnShipList.add(sh);
            }
        }
        return returnShipList;
    }  
    /**
This function convers the input CSV file in BLOB format into a string
@param input    Blob data representing correct string in @inCharset encoding
@param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
*/
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }         
}