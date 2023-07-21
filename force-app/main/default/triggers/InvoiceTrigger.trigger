trigger InvoiceTrigger on blng__Invoice__c (after update,after insert,before update, before insert) {
    public static boolean recursionBath=false;
    // GST Based serial Number calculation
    if(Trigger.isBefore && Trigger.isInsert ){
        InvoiceTriggerHandler.invoiceBillingDetailUpdate(trigger.new);
        InvoiceTriggerHandler.updateEmailRecepients(trigger.new);
                    
        //InvoiceTriggerHandler.gstSerialNumberUpdate(trigger.new);
        //NumberTOWordConvertion numtoword = new NumberTOWordConvertion ();
        //trigger.new[0].NumberToWord__c = numtoword.getNumberTOWordConvertion(trigger.new[0].blng__TotalAmount__c);
    }
    if(Trigger.isBefore && Trigger.isUpdate ){
        
            InvoiceTriggerHandler.amountsInWordConversion(trigger.new,trigger.oldMap);
            InvoiceTriggerHandler.gstSerialNumberUpdate(trigger.new);
        if(!UtilClass.recursionCheck){ 
            system.debug('Trigger 17 line worked');
            //InvoiceTriggerHandler.populateOracleSiteId(trigger.newMap);
            system.debug('Trigger 19 line worked'+trigger.newMap);
            UtilClass.recursionCheck = true;
           
        }
        InvoiceTriggerHandler.postInvoice(trigger.newMap, trigger.oldMap);  
        
    }
 
    if(Trigger.isAfter && Trigger.isInsert){
     
        //if(!UtilClass.triggerLoop){
            List<blng__Invoice__c> eyInvoiceList = new List<blng__Invoice__c>();
            for(blng__Invoice__c inv : trigger.New){
                if(inv.blng__InvoiceRunCreatedBy__c == null){
                    eyInvoiceList.add(inv);
                }
               
                if( (inv.BVC_Service__c=='BATH' || inv.BVC_Service__c=='eSHIP') && inv.blng__InvoiceRunCreatedBy__c == null){
                    InvoiceTriggerHandler.populateinvoiceBathEship(trigger.new); // updated by SONU
                }
            }
            system.debug('UtilClass.triggerLoop::: Invoice Trigger '+UtilClass.triggerLoop);
        if(eyInvoiceList.size() > 0 && eyInvoiceList != null){
            system.enqueueJob(new EY_TaxIntegrationQueueable(eyInvoiceList));   
        }
            
            //UtilClass.triggerLoop = true;
       // }
        
        //NumberTOWordConvertion numtoword = new NumberTOWordConvertion ();
        //trigger.new[0].NumberToWord__c = numtoword.getNumberTOWordConvertion(trigger.new[0].blng__TotalAmount__c);
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('===Invoice trigger called');
        Set<Id> BathIncList = new Set<Id>();
        for(blng__Invoice__c INV:trigger.new){
            if(INV.BVC_Service__c=='BATH' && INV.Total_Logistics_Charges__c>0 && INV.blng__InvoiceStatus__c=='Draft'){
                BathIncList.add(INV.Id);
            }
        }
        if(BathIncList.size()>0 && recursionBath==false){
            recursionBath=true;
            List<blng__InvoiceLine__c> Inlines2UpdatePD =[select id,Product_Description__c from blng__InvoiceLine__c where  blng__Invoice__c IN :BathIncList And Logistics_Charges__c >0 and ST_Customer_Product_Category__c!='BATH' ];
        	for(blng__InvoiceLine__c Lines:Inlines2UpdatePD){
            	Lines.ST_Customer_Product_Category__c='BATH';
        	}
        	if(Inlines2UpdatePD.size()>0){update Inlines2UpdatePD;
        	}
        }
        if(trigger.new[0].BVC_Service__c!='BATH'&& trigger.new[0].BVC_Service__c!='eSHIP'){
            InvoiceTriggerHandler.generateDocument(trigger.new,trigger.oldMap);
        }
        /*if(trigger.new[0].blng__InvoiceRunCreatedBy__c==null){
            boolean SheduledInv=true;
            InvoiceTriggerHandler.taxCalculator(trigger.newMap,trigger.oldMap,SheduledInv);
        }*/
        
        InvoiceTriggerHandler.updateflags(trigger.newMap,trigger.oldMap);
		InvoiceTriggerHandler.createroundoffinvoiceline(trigger.new,trigger.oldMap);
        //CB Method
        InvoiceTriggerHandler.taxCalculator(trigger.newMap,trigger.oldMap);
        Map<Id,Id> invOrderMap = new Map<Id,Id>();
        Map<Id,Id> acrCancelledMap = new  Map<Id,Id>();
        List<blng__Invoice__c> invList = new List<blng__Invoice__c>();
        Set<Id> invIds = new Set<Id>();
        
        for(blng__Invoice__c inv : trigger.new){
           blng__Invoice__c oldInv = Trigger.oldMap.get(inv.Id);
            if(inv.blng__PaymentStatus__c== 'Paid' && oldInv.blng__PaymentStatus__c!= inv.blng__PaymentStatus__c){invIds.add(inv.Id);
            }
           
        }
        if(invIds.size() > 0){invList.addAll([SELECT Id,Name,blng__PaymentStatus__c,blng__Account__r.Phone,blng__Credits__c, blng__Order__c,blng__Order__r.Business_Type__c,blng__InvoiceStatus__c,blng__TotalAmount__c,blng__Account__c,ACR_Cancelled__c, blng__Account__r.Name FROM blng__Invoice__c  WHERE Id IN :invIds AND blng__Order__r.Business_Type__c = 'ACR']) ;
        }
     
        for(blng__Invoice__c inv  : invList ){
            
            //NumberTOWordConvertion numtoword = new NumberTOWordConvertion ();
            //trigger.new[0].NumberToWord__c = numtoword.getNumberTOWordConvertion(trigger.new[0].blng__TotalAmount__c);
            
            blng__Invoice__c oldInv = Trigger.oldMap.get(inv.Id);
            
            if(inv.ACR_Cancelled__c == false){invOrderMap.put(inv.Id,inv.blng__Order__c);
               }
            if(inv.ACR_Cancelled__c == true && inv.blng__TotalAmount__c == inv.blng__Credits__c){
                   acrCancelledMap.put(inv.Id,inv.blng__Order__c);
               }
        }
        if(invOrderMap.size()>0){
            system.debug('===Update method');system.enqueueJob(new ActivateACRContractQueueable(invOrderMap));
            
        }
        if(acrCancelledMap.size() >0){ InvoiceTriggerHandler.acrCancellation(acrCancelledMap);
        }
        
             if(trigger.new[0].blng__InvoiceStatus__c=='Posted' && trigger.new[0].blng__InvoiceStatus__c!=trigger.old[0].blng__InvoiceStatus__c){
                  if(trigger.new[0].BVC_Service__c=='BATH' || trigger.new[0].BVC_Service__c=='eSHIP'){
                     CreateAnnexure.generateDocumentBathEShip(trigger.new[0].id);
                     if(trigger.new[0].Business_Type__c==null|| trigger.new[0].Business_Type__c=='Shipment'){
                         CreateAnnexure.createAnnexureInvoice(trigger.new[0].id);  
                     }
                  
                  }
              }
      
         if(trigger.new[0].Invoice_Doc_URL__c!=null && trigger.old[0].Invoice_Doc_URL__c!=trigger.new[0].Invoice_Doc_URL__c){
            
              if(trigger.new[0].Business_Type__c==null || trigger.new[0].Business_Type__c=='Shipment'){
                  if(trigger.new[0].BVC_Service__c=='BATH' || trigger.new[0].BVC_Service__c=='eSHIP'){
                      sendAnnaxureEmail.SendContractDetails(trigger.new[0].id);
                  }
                     
              }
             if(trigger.new[0].Business_Type__c=='ACR'){
                 if(trigger.new[0].BVC_Service__c=='BATH' || trigger.new[0].BVC_Service__c=='eSHIP'){
                     sendAnnaxureEmail.SendACRInvoice(trigger.new[0].id);
                 } 
             }
        }
        
    }
}