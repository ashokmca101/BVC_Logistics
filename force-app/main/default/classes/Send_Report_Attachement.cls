public class Send_Report_Attachement {
   @InvocableMethod
 public static void createAnnexureAccount(list<id> Account1){
        
       
          List<Account> AccountList = [SELECT id,name,Primary_Customer_Email__c, Active_Contract__c,PAN_Number_of_Entity__c,Active_Contract__r.ContractNumber,
                                      (select id,Shipping_Note_Number__c,Shipment_Date__c,Shipment_Value__c,Net_weight_in_Gram__c,Gross_weight_in_Gram__c,Product_Code__c,
                                       Product_Description__c, Shipper_Name_TMS__c,Consignee_Name_TMS__c ,/* Docket_No__c,No_Of_Attempts__c,Payment_Mode__c,*/Shipment_Type__c
                                       /*,From_City__c,To_City__c*/  from Shipments__r), 
                                      (SELECT id, Freight_Charges__c,Weight_Charges__c,Offline_Charges__c,Liability_charges__c,BVC_Valuation_Charges__c,Total_Charge__c,
                                       Origin_City__c,Origin_Type__c,Destination_City__c,Destination_type__c,Shipment__c FROM ACR_Consumption__r  ) FROM Account WHERE ID= :Account1];
     
     map<id,list<ST_ACR_Consumption__c >> mapIdACR = new map<id,list<ST_ACR_Consumption__c >> ();
     for(ST_ACR_Consumption__c  c:AccountList[0].ACR_Consumption__r){
         if(mapIdACR.containsKey(c.Shipment__c)){
              mapIdACR.get(c.shipment__c).add(c);
         }
         else{ mapIdACR.put(c.shipment__c,new list<ST_ACR_Consumption__c> {c});}    
     }
        string header = 'customer name, PAN Number,Contract Number, contract amount, contract number,Shipping Note Number, Shipment Date, Shipment Value, Net Weight in Gram,Gross Weight in Gram, Freight Charges, Weight Charges, Offline Charges, Liability Charges, BVC Valuation Charges, Total Charges, BVC Product Code,Product Description,Shipper Account,Consignee Account, Origin City, Origin Type, Destination City, Dectination Type, Shipment Type  \n';
        string finalstr = header ;
        string recordString;
        
        if(AccountList.size()>0 ){
          for(shipment__c ship:AccountList[0].shipments__r){
              if(mapIdACR.containsKey(ship.Id)){
              for(ST_ACR_Consumption__c acrcon :mapIdACR.get(ship.Id)){
                  String SampleText = null;
                  SampleText = '"'+AccountList[0].name+'","'+AccountList[0].PAN_Number_of_Entity__c+'","'+AccountList[0].Active_Contract__r.ContractNumber+'","'+ship.Shipping_Note_Number__c+'","'+ship.Shipping_Note_Number__c+'","'+ship.Shipment_Date__c+'","'+ship.Shipment_Value__c+'","'+ship.Net_weight_in_Gram__c+'","'+ship.Gross_weight_in_Gram__c+'","'+acrcon.Freight_Charges__c+'","'+acrcon.Weight_Charges__c+'","'+acrcon.Offline_Charges__c+'","'+acrcon.Liability_charges__c+'","'+acrcon.BVC_Valuation_Charges__c+'","'+acrcon.Total_Charge__c+'","'+ship.Product_Code__c+'","'+ship.Product_Description__c+'","'+ship.Shipper_Name_TMS__c+'","'+ship.Consignee_Name_TMS__c+'","'+acrcon.Origin_City__c+'","'+acrcon.Origin_Type__c +'","'+acrcon.Destination_City__c +'","'+acrcon.Destination_type__c+'","'+ship.Shipment_Type__c+'" \n';    
                  recordString= recordString + SampleText;
                  system.debug('recordString++++++++'+SampleText);
                  finalStr += recordString;
                 }
              }
               }
           }
      //   finalstr = finalstr +recordString;
     system.debug('finalstr++++++++'+finalstr);
         /*if(recordString.length()>0){
             Contact setOfContactId = [select id from contact where AccountId = :Account1];
             Messaging.SingleEmailMessage[] messages = 
             new List<Messaging.SingleEmailMessage> {};
             Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
             EmailTemplate emailTemplate =[Select Id,Subject,Description,
                                     HtmlValue,DeveloperName,Body
                                     from EmailTemplate where name =
                                     'Contract Consumption Expiry HTML'];
             message.setTemplateId(emailTemplate.id);
             message.setTargetObjectId(setOfContactId.Id);
             message.setToAddresses(new String[] { AccountList[0].Primary_Customer_Email__c });
             List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
             Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                  efa.setFileName('ACR Report.csv');
                  efa.setBody(Blob.valueOf(finalstr));
                  efa.setContentType('text/csv');
                  attachments.add(efa);
              message.setFileAttachments(attachments);
              messages.add(message);
              Messaging.sendEmail(messages);
            
            }*/
   /*  try{
     	ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Consumption Details.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Consumption Details.csv'; // Display name of the files
         Blob textData = Blob.valueOf(finalstr);
        conVer.VersionData = textData;
        insert conVer;    //Insert ContentVersion
     
     
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = Account1[0]; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
     }
     
     catch(exception ex){
         system.debug(ex.getMessage());
     }*/
     list<ContentVersion> ContVerList = new list<ContentVersion>();
     ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Consumption Details.txt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Consumption Details.txt'; // Display name of the files
        Blob textData = Blob.valueOf(finalstr);
        conVer.Customer__c= account1[0];   
        conVer.VersionData = textData;
        system.debug('before insertion++++++'+conVer);
        ContVerList.add(conVer);    //Insert ContentVersion
     
     	
    try{
        insert ContVerList;
         system.debug('after insertion++++++'+ContVerList);
    }
     catch(exception ex){
         system.debug(ex.getMessage());
     }
  }
}