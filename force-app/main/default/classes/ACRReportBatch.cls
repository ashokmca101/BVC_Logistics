public class ACRReportBatch implements Database.Batchable<sObject>{
	public final String Query;
    public ACRReportBatch(){
          query='select id,name,Primary_Customer_Email__c, Active_Contract__c,PAN_Number_of_Entity__c,Active_Contract__r.ContractNumber,(select id,Shipping_Note_Number__c,Shipment_Date__c,Shipment_Value__c,Net_weight_in_Gram__c,Gross_weight_in_Gram__c,Product_Code__c,Product_Description__c, Shipper_Name_TMS__c,Consignee_Name_TMS__c ,Shipment_Type__c from Shipments__r),(SELECT id, Freight_Charges__c,Weight_Charges__c,Offline_Charges__c,Liability_charges__c,BVC_Valuation_Charges__c,Total_Charge__c,Origin_City__c,Origin_Type__c,Destination_City__c,Destination_type__c FROM ACR_Consumption__r) from Account where Customer_Category_Static__c =\'ACR\' and Active_Contract__c !=null';
              }
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   	}
    public void execute(Database.BatchableContext BC, List<Account> scope){
        list<ContentDocumentLink> conLinkList= new list<ContentDocumentLink>();
        list<ContentVersion> ContVerList = new list<ContentVersion>();
        
        for(Account a:scope){
       	string header = 'customer name, PAN Number,Contract Number, contract amount, contract number,Shipping Note Number, Shipment Date, Shipment Value, Net Weight in Gram,Gross Weight in Gram, Freight Charges, Weight Charges, Offline Charges, Liability Charges, BVC Valuation Charges, Total Charges, BVC Product Code,Product Description,Shipper Account,Consignee Account, Origin City, Origin Type, Destination City, Dectination Type, Shipment Type  \n';
        string finalstr = header ;
        string recordString= null;
       // recordString= '"'+a.name+'","'+a.PAN_Number_of_Entity__c+'","'+a.Active_Contract__r.ContractNumber+'" \n';
        for(shipment__c ship:a.shipments__r){
              for(ST_ACR_Consumption__c acrcon :a.ACR_Consumption__r){
                 recordString = '"'+a.name+'","'+a.PAN_Number_of_Entity__c+'","'+a.Active_Contract__r.ContractNumber+'","'+ship.Shipping_Note_Number__c+'","'+ship.Shipping_Note_Number__c+'","'+ship.Shipment_Date__c+'","'+ship.Shipment_Value__c+'","'+ship.Net_weight_in_Gram__c+'","'+ship.Gross_weight_in_Gram__c+'","'+acrcon.Freight_Charges__c+'","'+acrcon.Weight_Charges__c+'","'+acrcon.Offline_Charges__c+'","'+acrcon.Liability_charges__c+'","'+acrcon.BVC_Valuation_Charges__c+'","'+acrcon.Total_Charge__c+'","'+ship.Product_Code__c+'","'+ship.Product_Description__c+'","'+ship.Shipper_Name_TMS__c+'","'+ship.Consignee_Name_TMS__c+'","'+acrcon.Origin_City__c+'","'+acrcon.Origin_Type__c +'","'+acrcon.Destination_City__c +'","'+acrcon.Destination_type__c+'","'+ship.Shipment_Type__c+'" \n';   
              system.debug('RecordString++++++'+recordString); 
				}
               }
           
         finalstr = finalstr +recordString;
        
     	ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Consumption Details.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Consumption Details.csv'; // Display name of the files
        Blob textData = Blob.valueOf(finalstr);
        conVer.Customer__c= a.Id;   
        conVer.VersionData = textData;
        system.debug('before insertion++++++'+conVer);
        ContVerList.add(conVer);    //Insert ContentVersion
     
     	}
    try{
        insert ContVerList;
         system.debug('after insertion++++++'+ContVerList);
    }
     catch(exception ex){
         system.debug(ex.getMessage());
     }
        /*for(ContentVersion c:ContVerList){
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = c.Customer__c; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = c.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            conLinkList.add(conDocLink);
        }
        try{
        insert conLinkList;
         system.debug('after insertion++++++'+conLinkList);
    }
     catch(exception ex){
         system.debug(ex.getMessage());
     }*/
          
    }
    public void finish(Database.BatchableContext BC){
       
   }
}