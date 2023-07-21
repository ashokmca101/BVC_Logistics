global class eShipFileBatchClass implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    Public List<Shipment__c> excelShipment;
    
    public eShipFileBatchClass(List<Shipment__c> excelShipment) {
        this.excelShipment=new List<Shipment__c>();
        this.excelShipment = excelShipment;
        
    }
    global List<Shipment__c> start(Database.BatchableContext BC) {
        return this.excelShipment;
    }
    
    global void execute(Database.BatchableContext BC, List<Shipment__c> excelShipment) {
        
        System.debug('excelShipment insert '+excelShipment.size());
        if(excelShipment.size()>0){
            //insert excelShipment;
            try{
               /* Database.SaveResult[] srList = Database.insert(excelShipment, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted shipping. shipment ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Shipping fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
                insert excelShipment;
                
            }catch(Exception e) {
                system.debug('File upload Failed');
                eShipFileUploadHpr newdata = new eShipFileUploadHpr();newdata.sendMail('Hello sir ,eSHIP File upload Failed due to ::'+e.getMessage());
            }
        }
        
        
        /*
        List<SBQQ__Quote__c> newQuoteList =new List<SBQQ__Quote__c>();
        set<Id> accId =new set<Id>();
        set<Id> ShipId =new set<Id>();
        for(Shipment__c ship:excelShipment){
            accId.add(ship.Customer__c);
            ShipId.add(ship.id); 
        }
        List<Account> AccList =[select id,eSHIP_Contract__c,BATH_Contract__c  from Account where Id IN :accId];
        Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        set<Id> ConId =new set<Id>();
        for(Account A:AccList){
            if(A.eSHIP_Contract__c!=null){
                ConId.add(A.eSHIP_Contract__c);
            }
        }
        integer PackageToTest;  
        List<Contract> conList =[select id,Account.Billing_Address__c,BVC_Entity__c,BVC_Billing_Entity__c,Slab_Criteria__c,Is_Legacy_Contract__c,Contract_Amount__c,BVC_Branch__c,Tariff_Plan__c,AccountId,BVC_Service__c,Contracted_ACR_Package__c,Business_Type__c   from Contract where Id IN :ConId];//getting eship contracts
        String gsRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();
        for (Shipment__c shipment : excelShipment){ 
            SBQQ__Quote__c newQuote= new SBQQ__Quote__c();
            if(conList.size()>0){
                for(Contract C:conList){
                    if(C.AccountId==shipment.Customer__c){
                        
                        if(C.Contract_Amount__c!=null){
                            PackageToTest=Integer.valueOf(C.Contract_Amount__c);
                            newQuote.Package_Amount__c=String.valueOf(PackageToTest);
                        }
                        newQuote.Is_Legacy_Contract__c=C.Is_Legacy_Contract__c;
                        if(C.Tariff_Plan__c!=null){newQuote.Tariff_Plan_Bath_Eship__c=C.Tariff_Plan__c;
                                                  }
                        if(C.BVC_Branch__c!=null){newQuote.BVC_Branch__c=C.BVC_Branch__c;
                                                 }
                        if(C.BVC_Billing_Entity__c!=null){newQuote.BVC_Billing_Entity__c=C.BVC_Billing_Entity__c;
                                                         }
                        if(C.BVC_Entity__c!=null){newQuote.BVC_Entity__c=C.BVC_Entity__c;
                                                 }
                        if(C.Slab_Criteria__c!=null){newQuote.Slab_Criteria__c=C.Slab_Criteria__c;  
                                                    }
                        if(C.Account.Billing_Address__c!=null){newQuote.Billing_Address__c=C.Account.Billing_Address__c;
                                                              }
                        newQuote.Business_Type__c=C.Business_Type__c;//mapping from contract eship
                    }
                }                    
            }
            if(shipment.Customer__c!=null){
                newQuote.SBQQ__Account__c=shipment.Customer__c;  
            }
            //system.debug('record type id'+gsRecordTypeID);
            newQuote.RecordTypeId=gsRecordTypeID;
            //system.debug('shipment.Id::::::::::::'+shipment.Id);
            newQuote.Shipment__c=shipment.Id; 
            newQuote.SBQQ__PricebookId__c=BVCPricebook.Id;
            newQuote.SBQQ__SubscriptionTerm__c=12;
            newQuote.Is_Uploaded__c=true;
            newQuote.SBQQ__StartDate__c=Date.today();
            newQuote.Contract_Signed_Date__c=Date.today();
            if(shipment.Total_Invoice_Value__c!=null){
                newQuote.Total_Invoice_Value__c = shipment.Total_Invoice_Value__c;  
            }
            newQuote.BVC_Service__c = shipment.Customer_Product_Category__c;
            if(shipment.Visit_Outcome__c!=null){newQuote.Visit_Outcome__c = shipment.Visit_Outcome__c;  
                                               }            
            if(shipment.Origin_Destination_Pairing__c!=null){ newQuote.Origin_Destination_Pairing__c = shipment.Origin_Destination_Pairing__c;
                                                            }         
            
            if(shipment.Net_Weight__c!=null){
                newQuote.Net_Weight__c = shipment.Net_Weight__c;
            }
            if(shipment.Gross_Weight__c!=null){
                newQuote.BVC_Gross_Weight__c = shipment.Gross_Weight__c;
            }
            if(shipment.Shipment_Type__c!=null){
                newQuote.Shipment_Type__c = shipment.Shipment_Type__c;
            }
            
            if(shipment.Net_Weight_UOM__c!=null){newQuote.Net_Weight_UOM__c = shipment.Net_Weight_UOM__c;
                                                }
            if(shipment.Gross_Weight_UOM__c!=null){newQuote.Gross_Weight_UOM__c = shipment.Gross_Weight_UOM__c;
                                                  }
            newQuoteList.add(newQuote);
        }
        System.debug('newQuoteList dsfsdf :'+newQuoteList.size());
        
        
        if(newQuoteList.size()>0){
            //insert newQuoteList; 
            try{
                insert newQuoteList; 
            }catch(Exception e) {
                system.debug('File upload Failed');
                eShipFileUploadHpr newdata = new eShipFileUploadHpr(); newdata.sendMail('Hello sir ,eSHIP File upload Failed due to ::'+e.getMessage());
            }
            
        }
        
         
        //Pricebook2 BVCPricebook = [select id from Pricebook2 where Name='BVC INR Price Book'];
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Product2> productBath =[select Id,ProductCode from Product2 where Family='Eship freight Charge' limit 1];
        List<PricebookEntry> pbEntry =new List<PricebookEntry>();
        Set<Id> pIDS =new Set<Id>();
        for(Product2 P:productBath){
            pIDS.add(P.Id);
        } 
        //List<SBQQ__Quote__c> newQuoteList =new List<SBQQ__Quote__c>();
        for(PricebookEntry pb : [select id,Product2Id,Pricebook2Id,UnitPrice  from PricebookEntry where Pricebook2Id =:BVCPricebook.id AND Product2Id In:pIDS]){           
            pbEntry.add(pb);
        }


        for(SBQQ__Quote__c quote:newQuoteList){ 
            
            if(quote.BVC_Service__c=='eSHIP' && quote.Shipment__c!=null){
                for(integer i=0;i<productBath.size();i++){
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    for(integer j=0;j<pbEntry.size();j++){    
                        if(pbEntry[j].Product2Id ==productBath[i].id){
                            quoteLine.SBQQ__PricebookEntryId__c=pbEntry[j].Id;
                            quoteLine.SBQQ__NetPrice__c=pbEntry[j].UnitPrice; 
                        }
                    }
                    quoteLine.SBQQ__Product__c=productBath[i].Id;
                    quoteLine.SBQQ__Quantity__c=1;
                    quoteLine.SBQQ__ChargeType__c='One-Time';
                    quoteLine.Shipment__c=quote.Shipment__c;
                    quoteLine.BVC_Gross_weight__c=quote.BVC_Gross_weight__c;
                    quoteLine.BVC_Net_Weight__c=quote.Net_Weight__c;
                    quoteLine.SBQQ__Quote__c=quote.Id;
                    system.debug('quoteLine::::::::::::'+quoteLine);
                    quoteLineList.add(quoteLine);
                }
            } 
        }
        
        system.debug('quoteLineList.size::::::::::::'+quoteLineList.size());
        if(quoteLineList.size()>0){    
            //insert quoteLineList;
            try{
                insert quoteLineList;    
            }catch(Exception e) {
                system.debug('File upload Failed');
                eShipFileUploadHpr newdata = new eShipFileUploadHpr(); 
                newdata.sendMail('Hello sir ,eSHIP File upload Failed due to ::'+e.getMessage());
            }
            //system.debug('quoteLineList::::::::::::'+quoteLineList);
        }*/

        
    }   
    
    global void finish(Database.BatchableContext BC) {
        //eShipFileUploadHpr newdata = new eShipFileUploadHpr();
        //newdata.sendMail('Hello sir , the file you uploded from BATH file uploder is uploded properly');
        //eSHIPFileUploadQuoteHpr ListShipment = new eSHIPFileUploadQuoteHpr(); 
        //ID batchprocessid = database.executeBatch(ListShipment,5);
    }
}