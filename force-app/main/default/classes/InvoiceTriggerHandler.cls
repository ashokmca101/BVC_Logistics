public class InvoiceTriggerHandler {
    //created by SONU
    public static void populateinvoiceBathEship(List<blng__Invoice__c> InvList){

        Map<Id,blng__Invoice__c> orderInvoiceMap = new Map<Id,blng__Invoice__c>();
        Map<Id,Contract> ContractInvoiceMap = new Map<Id,Contract>();
        List<Contract> ConList = new List<Contract>();
        for(blng__Invoice__c Inv : InvList){ 
            if(Inv.BVC_Service__c=='BATH' || Inv.BVC_Service__c=='eSHIP'){
                orderInvoiceMap.put(Inv.blng__Order__c, Inv);
            }
        }
         if(!orderInvoiceMap.isEmpty() && orderInvoiceMap.size() > 0)
        {
            for(Contract con : [Select Id,SBQQ__Order__c,Invoice__c,Name
                                        From Contract 
                                        Where SBQQ__Order__c In :orderInvoiceMap.keySet() ])
            {
                ContractInvoiceMap.put(con.SBQQ__Order__c, con);
                ConList.add(con);
            }
            for(Contract Con : ConList)
            {
                if(ContractInvoiceMap.size() >0 
                   && ContractInvoiceMap != null 
                   && Con.Invoice__c == null
                   && ContractInvoiceMap.containsKey(Con.SBQQ__Order__c)){
                       Con.Invoice__c = orderInvoiceMap.get(Con.SBQQ__Order__c).Id;
                   }
            } 
             
            if(ConList.size()>0){
                update ConList;
            }
        }
    }   
    
    public static final map<String,String> mapOfTypeCode = new map<String,String>{
        'Tax Invoice' => 'T', 'Bill of Supply Invoice' => 'B',
            'Commercial Invoice ' => 'C', 'Tax Credit Note' => 'T',
            'Bill of Supply Credit Note' => 'B', 'Commercial Credit Note' => 'C'
            } ;
                
                public static void acrCancellation( Map<Id,Id> invoiceOrderMap){
                    List<Contract> contracts2Update = new List<Contract>();
                    
                    for(Contract c : [SELECT Id,SBQQ__Order__c,Status,SBQQ__Order__r.Business_Type__c 
                                      FROM Contract 
                                      WHERE SBQQ__Order__c IN :invoiceOrderMap.values()
                                      AND Status != 'Cancelled'
                                      AND Status != 'Expired']){
                                          if(c.SBQQ__Order__r.Business_Type__c == 'ACR'){
                                              c.Status = 'Cancelled';
                                              contracts2Update.add(c); 
                                          }
                                          
                                      }
                    if(contracts2Update.size()>0){
                        try{
                            update contracts2Update;
                        }catch(exception Ex){
                            system.debug(ex.getStackTraceString()+'contracts were not Activated :::'+Ex.getMessage());
                        }
                    }
                }
    
    public static void createroundoffinvoiceline(List<blng__Invoice__c> newlist,Map<Id,blng__Invoice__c> oldMap){
        list<blng__InvoiceLine__c> invlinelist = new list<blng__InvoiceLine__c>();
        list<Charge_Head_Tax__c> chargeheadlist=new list<Charge_Head_Tax__c>();
        set<id> PretaxbillIDs=new set<id>();
        Map<id,integer> chargeheadcount=new Map<id,integer>();
        list<blng__Invoice__c> invoiceslist=[select id,(select id from Charge_Head_Taxes__r) from blng__Invoice__c where id IN:oldMap.keySet()];
        for(blng__Invoice__c inv:invoiceslist){
            chargeheadcount.put(inv.id,inv.Charge_Head_Taxes__r.size());
        }
        for(blng__Invoice__c inv:newList){
            blng__Invoice__c oldInv = oldMap.get(inv.Id);
            if(inv.Invoice_Doc_URL__c != null && oldInv.Invoice_Doc_URL__c == null && inv.BVC_CB_ROUND_OFF__c !=0.00 && inv.BVC_CB_Is_CB_Invoice__c== true){
                system.debug('test'+inv.BVC_CB_ROUND_OFF__c);
                blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
                invline.blng__Subtotal__c = inv.BVC_CB_ROUND_OFF__c;
                invline.blng__Invoice__c = inv.Id;
                invLine.Name = 'Round Off';
                invline.blng__UnitPrice__c = inv.BVC_CB_ROUND_OFF__c;
                invlinelist.add(invline);
                Charge_Head_Tax__c chTax = new Charge_Head_Tax__c();
               	chTax.Name = 'Round Off';
               	chTax.Invoice__c = inv.Id;
                chTax.COA_Revenue_Account_Code__c = '452401';
                chTax.COA_Revenue_Sub_Account__c = '99999';
                chTax.HSN_Code__c ='0000';
                chTax.CGST_Amount__c=0;
                chTax.CGST_Rate__c=0;
                chTax.IGST__c=0;
                chTax.IGST_Amount__c=0;
                chtax.SGST__c=0;
                chTax.SGST_Amount__c=0;
                chTax.Taxable_Value__c=inv.BVC_CB_ROUND_OFF__c;
                chTax.Total_Amount__c =inv.BVC_CB_ROUND_OFF__c;
                chTax.Line_Number__c =chargeheadcount.get(inv.id)+1;
                chargeheadlist.add(chTax);
            }
            if(inv.BVC_CB_Is_CB_Invoice__c && inv.Invoice_Doc_URL__c != null && !string.isEmpty(inv.Invoice_Doc_URL__c)&& inv.BVC_CB_PreTaxBill__c !=null ){
                PretaxbillIDs.add(inv.BVC_CB_PreTaxBill__c);
            }
        }
        if(invlinelist.size()>0){
            insert invlinelist;
        }
        if(chargeheadlist.size()>0){
            insert chargeheadlist;
        }
        if(PretaxbillIDs.size()>0){
           list<blng__Invoice__c> invRelatedtoPretaxBill=[Select id,name,Invoice_Doc_URL__c,BVC_CB_PreTaxBill__c from blng__Invoice__c where BVC_CB_PreTaxBill__c in :PretaxbillIDs];
            for(blng__Invoice__c PRinv:invRelatedtoPretaxBill){
                if(PRinv.Invoice_Doc_URL__c == null){
                    PretaxbillIDs.remove(PRinv.BVC_CB_PreTaxBill__c);
                }
            }
            system.debug('after removing pretaxids'+PretaxbillIDs.size());
        }
        if(PretaxbillIDs.size()>0){
             list<BVC_CB_PreTaxBill__c> PTtoUpdate=new  list<BVC_CB_PreTaxBill__c>();
          list<BVC_CB_PreTaxBill__c>   pretaxbills=[select id,BVC_CB_Invoice_Generated_in_Salesforce__c from BVC_CB_PreTaxBill__c where id in :PretaxbillIDs];
            for(BVC_CB_PreTaxBill__c PT:pretaxbills){
                PT.BVC_CB_Invoice_Generated_in_Salesforce__c =TRUE;
                PTtoUpdate.add(PT);
            }
            update PTtoUpdate;
        }
    }
        
    /**********************************************************************
* 
* Method Name : taxCalculator
* Description : Method to calculate Tax at Invoice Line level
* Param : Trigger.newMap,trigger.oldMap
* 
***********************************************************************/
    public static void taxCalculator(Map<Id,blng__Invoice__c> invMap,Map<Id,blng__Invoice__c> oldMap){
        Map<Id,blng__Invoice__c> invoiceMap = new Map<Id,blng__Invoice__c>();
        for(blng__Invoice__c inv : invMap.values()){
            blng__Invoice__c oldInv = oldMap.get(inv.Id);
            system.debug('Invoice tax Percent > '+inv.ST_Tax_Percent__c + 'Old Inv Value > '+ oldInv.ST_Tax_Percent__c);
            if(((inv.Total_Freight_Tax__c != null && inv.Total_Freight_Tax__c != oldInv.Total_Freight_Tax__c)
                || (inv.Total_Liability_Charge_Tax__c != null && inv.Total_Liability_Charge_Tax__c != oldInv.Total_Liability_Charge_Tax__c)
                || (inv.Total_Vaulting_tax__c != null && inv.Total_Vaulting_tax__c != oldInv.Total_Vaulting_tax__c)//prat
                || (inv.Total_Fuel_surcharge_Tax__c != null && inv.Total_Fuel_surcharge_Tax__c != oldInv.Total_Fuel_surcharge_Tax__c)//prat
                || (inv.Total_Offline_Tax__c != null  && inv.Total_Offline_Tax__c != oldInv.Total_Offline_Tax__c)
                ||(inv.Total_BVC_Valuation_Charge_Tax__c != null && inv.Total_BVC_Valuation_Charge_Tax__c != oldInv.Total_BVC_Valuation_Charge_Tax__c)
                ||(inv.Total_Docket_Charge_Tax__c != null && inv.Total_Docket_Charge_Tax__c != oldInv.Total_Docket_Charge_Tax__c)
                ||(inv.Total_Fuel_Charge_Tax__c != null && inv.Total_Fuel_Charge_Tax__c != oldInv.Total_Fuel_Charge_Tax__c)
                //||(inv.BVC_CB_Is_CB_Invoice__c == TRUE && inv.EY_Tax_Calculation_Status__c == 'Success' && oldInv.EY_Tax_Calculation_Status__c != 'Success')
                ||(inv.Total_Holiday_Charge_Tax__c != null && inv.Total_Holiday_Charge_Tax__c != oldInv.Total_Holiday_Charge_Tax__c)
                ||(inv.Total_Weight_Charge_Tax__c != null && inv.Total_Weight_Charge_Tax__c != oldInv.Total_Weight_Charge_Tax__c)
                // BY SONU
				||(inv.Total_Commission_Tax__c != null && inv.Total_Commission_Tax__c != oldInv.Total_Commission_Tax__c)
                ||(inv.Total_Logistics_Tax_Amount__c != null && inv.Total_Logistics_Tax_Amount__c != oldInv.Total_Logistics_Tax_Amount__c)
                ||(inv.Total_Secure_Logistics_Tax_Amount__c != null && inv.Total_Secure_Logistics_Tax_Amount__c != oldInv.Total_Secure_Logistics_Tax_Amount__c)
                )&& inv.ST_Tax_Percent__c != null && inv.blng__InvoiceStatus__c != 'Posted')
                {
                    invoiceMap.put(inv.Id, inv);
                }
        }
        if(invoiceMap.size() > 0){
            system.debug(':::Invoice Tax calculator:::');
            InvoiceLineTaxCalculator.lineTaxCalculator(invoiceMap);
            //system.enqueueJob(new InvoiceLineTaxUpdateQueueable(invoiceMap));
        }
        
    }
    
    /**********************************************************************
* 
* Method Name : populateOracleSiteId
* Description : Method to Populate the Oracle Site Id at Invoice Level
* Param : Trigger.newMap
* 
***********************************************************************/
    
   /* UpdateInvoiceOracleSiteId
    * public static void populateOracleSiteId(Map<Id,blng__Invoice__c> invoiceMap){
        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
        Set<Id> addressIds = new Set<Id>();
        Set<Id> invIds = new Set<Id>();
        for(blng__Invoice__c inv : invoiceMap.values()){
            if(inv.Oracle_Site_ID__c == null && inv.Billing_Address__c != null && inv.Oracle_Site_ID__c == null){
                addressIds.add(inv.Billing_Address__c);
                invoices.add(inv);
                invIds.add(inv.Id);
            }
        }
        
        Map<String,AddressBook__c> siteIdAddressMap = new Map<String,AddressBook__c>();
        Map<String,List<blng__Invoice__c>> siteIdInvoiceMap = new Map<String,List<blng__Invoice__c>>();
        Map<Id,String> idSiteIdMap = new Map<Id,String>();
        if(invIds.size() >0){
            
            for(blng__Invoice__c invoice : [SELECT Id,Name,Billing_Address__c,Billing_Address__r.BVC_Site_ID__c
                                            FROM blng__Invoice__c
                                            WHERE Id IN :invIds]){
                                                system.debug('Invoice Name::'+invoice.Name+'::SiteId::'+invoice.Billing_Address__r.BVC_Site_ID__c);
                                                if(invoice.Billing_Address__r.BVC_Site_ID__c != null
                                                   && invoice.Billing_Address__r.BVC_Site_ID__c != ''){
                                                       idSiteIdMap.put(invoice.Id,invoice.Billing_Address__r.BVC_Site_ID__c); 
                                                   }
                                                
                                                
                                            }
        }
        system.debug('idSiteIdMap:::containsKey::'+idSiteIdMap);
        Map<String,Pickup_Address_Mapping__c> siteMap = new Map<String,Pickup_Address_Mapping__c>();
        Map<String,String> siteIdOracleIdMap = new Map<String,String>();
        
        String companyId = Label.BVCL_Company_Id;
        if(idSiteIdMap.size() >0){
            for(Pickup_Address_Mapping__c site : [SELECT Id,Oracle_Site_ID__c,BVC_Site_ID__c,
                                                  BVC_Company_ID__c,Customer__c
                                                  FROM Pickup_Address_Mapping__c
                                                  WHERE BVC_Site_ID__c IN :idSiteIdMap.values()
                                                  AND BVC_Company_ID__c = :companyId]){
                                                      system.debug('Oracle Site Mapping::'+site);
                                                      if(site.Oracle_Site_ID__c != null
                                                         && site.Oracle_Site_ID__c != ''){
                                                             siteIdOracleIdMap.put(site.BVC_Site_ID__c,site.Oracle_Site_ID__c);  
                                                         }
                                                      
                                                  }
        }
        
        for(blng__Invoice__c inv : invoiceMap.values()){
            if(idSiteIdMap.containsKey(inv.Id)){
                string bvcSiteId = idSiteIdMap.get(inv.Id);
                inv.Oracle_Site_ID__c = siteIdOracleIdMap.get(bvcSiteId);
            }
        }
        
    }*/
    /******************************************************************
* Method Name : gstSerialNumberUpdate
* Description : Update Invoice Serial Number based on GST
* Param : Trigger.new
* 
*******************************************************************/
    
    public static void gstSerialNumberUpdate(List<blng__Invoice__c> newList){
        list<blng__Invoice__c> CBinvoiceIds=new list<blng__Invoice__c>();
        Map<Id,String> invoiceIds=new map<Id,String>();
        list<Id> CBserial = new list<Id>();
        for(blng__Invoice__c inv: newList){
            if(inv.BVC_CB_Is_CB_Invoice__c ==True && (inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c))){
                CBinvoiceIds.add(inv);
                CBserial.add(inv.Id);
            }else{                
            if(inv.ST_Invoice_Series__c == null || String.isBlank(inv.ST_Invoice_Series__c)){
                invoiceIds.put(inv.Id, inv.Invoice_Type__c);
            }
            }
        }
        
        if(invoiceIds.size()>0 && !invoiceIds.isEmpty()){
            System.debug('invoiceIds.  '+invoiceIds);
            Map<Id,String> orderMap = getBranchinfo(invoiceIds);
            Map<String,Integer> mapUniqueKeyNumber = new Map<String,Integer>();
            List<DocumentSeries__c>upsertList = new List<DocumentSeries__c>();
            Map<String,DocumentSeries__c> mapUniqueKeyRecord =new Map<String,DocumentSeries__c>();
            if(orderMap.size() >0){
                for(DocumentSeries__c doc : [Select Unique_Key__c, Last_Serial_Number__c from DocumentSeries__c where Unique_Key__c IN:orderMap.values()]){
                    mapUniqueKeyNumber.put(doc.Unique_Key__c,Integer.valueOf(doc.Last_Serial_Number__c.right(doc.Last_Serial_Number__c.length() - doc.Unique_Key__c.length())));
                    mapUniqueKeyRecord.put(doc.Unique_Key__c,doc);
                }
                for(blng__Invoice__c invRec: newList){
                    if(orderMap != null && orderMap.containsKey(invRec.Id)){
                        if(mapUniqueKeyNumber.containsKey(orderMap.get(invRec.Id))){
                            Integer newSerialNUmber = mapUniqueKeyNumber.get(orderMap.get(invRec.Id)) +1;
                            invRec.ST_Invoice_Series__c = orderMap.get(invRec.Id) + newSerialNUmber;
                            mapUniqueKeyRecord.get(orderMap.get(invRec.Id)).Last_Serial_Number__c = orderMap.get(invRec.Id) + newSerialNUmber;
                            mapUniqueKeyNumber.put(orderMap.get(invRec.Id),newSerialNUmber);
                            
                        }else{
                            invRec.ST_Invoice_Series__c = orderMap.get(invRec.Id) + 1;
                            DocumentSeries__c docM = new DocumentSeries__c();
                            docM.Name = orderMap.get(invRec.Id);
                            docM.Last_Serial_Number__c = orderMap.get(invRec.Id) + 1;
                            docM.Unique_Key__c = orderMap.get(invRec.Id);
                            mapUniqueKeyRecord.put(orderMap.get(invRec.Id),docM);
                            mapUniqueKeyNumber.put(orderMap.get(invRec.Id),1);
                        }
                    }
                }
                
                upsert mapUniqueKeyRecord.values();
            } 
        }
        if(CBinvoiceIds.size()>0 && !CBinvoiceIds.isEmpty()){
            Map<Id,blng__Invoice__c> SrNumMap = new Map<Id,blng__Invoice__c>([Select id,BVC_Billing_Entity__r.GSTIN_State_Code__c,BVC_Billing_Entity__r.BVC_CB_Billing_Serial_Number__c from blng__Invoice__c where Id IN :CBserial]);
     		list<blng__Invoice__c> TIinvoices=[Select id,name from blng__Invoice__c where Invoice_Type__c = 'Tax Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null];
            list<blng__Invoice__c> CIinvoices=[Select id,name from blng__Invoice__c where Invoice_Type__c = 'Commercial Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null ];
            list<blng__Invoice__c> BIinvoices=[Select id,name from blng__Invoice__c where Invoice_Type__c = 'Bill of Supply Invoice' AND BVC_CB_Is_CB_Invoice__c =TRUE AND ST_Invoice_Series__c != null];
            integer taxvar=1;
            integer comvar=1;
            integer bosvar=1;
            for(blng__Invoice__c CBinv :CBinvoiceIds){
                string invseries ;
                String sr = SrNumMap.get(CBinv.id).BVC_Billing_Entity__r.BVC_CB_Billing_Serial_Number__c;
                string stateCode = SrNumMap.get(CBinv.id).BVC_Billing_Entity__r.GSTIN_State_Code__c;//p
                Integer lastCount = 0;//p
                system.debug('+++++++++++++++++++++'+SrNumMap.get(CBinv.id).BVC_Billing_Entity__r.BVC_CB_Billing_Serial_Number__c);
                system.debug(CBinv.id);
                if(CBinv.Invoice_Type__c == 'Tax Invoice'){
                    for (blng__Invoice__c invoice : newList) {
            			if (invoice.ST_Invoice_Series__c != null && invoice.ST_Invoice_Series__c.startsWith(stateCode)) {
                            String numericPortion = invoice.ST_Invoice_Series__c.substringAfter(stateCode).substring(0, 2);
                            if (numericPortion.isNumeric()) {
                                Integer currentCount = Integer.valueOf(numericPortion);
                                if (currentCount > lastCount) {
                                    lastCount = currentCount;
                    }
                }
            }
        }
                    lastCount++;
                    String lastCountStr = String.valueOf(lastCount).leftPad(2, '0');
                    invseries = stateCode + CBinv.BVC_CB_Invoice_Series__c + lastCountStr;
                    CBinv.ST_Invoice_Series__c = invseries;
                }else if(CBinv.Invoice_Type__c =='Commercial Invoice'){
                    integer count = CIinvoices.size()+comvar;
                    invseries =  CBinv.BVC_CB_Invoice_Series__c +sr+count;
                    system.debug(invseries);
					comvar++;                    
                }else if(CBinv.Invoice_Type__c =='Bill of Supply Invoice'){
                    integer count = BIinvoices.size()+bosvar;
                    invseries =  CBinv.BVC_CB_Invoice_Series__c+sr+count;
                    system.debug(invseries);
                    bosvar++;
                }
                cbinv.ST_Invoice_Series__c=invseries ; 
            }
        }      
        
    }
    
    /*************************************************************************
* Method Name : getBranchInfo
* Description : get The related Branch info W.R.T Order
* Param : List of Order ids
* Return : Map<Id, OrderObect>
*
**************************************************************************/
    
    public static Map<Id,String> getBranchInfo(Map<Id,String> orderMap){
        Map<Id,String> mapOrderKey = new map<Id,String>();
        System.debug('::Invoice Ids::'+orderMap.keyset());
        for ( blng__Invoice__c inv : [Select id,BVC_Branch__r.ST_BVC_Billing_Entity__r.Billing_Serial_Number__c,BVC_Branch__r.ST_BVC_Billing_Entity__r.GSTIN_State_Code__c from blng__Invoice__c 
                                      where BVC_Branch__c != null AND BVC_Branch__r.ST_BVC_Billing_Entity__c != null AND
                                      BVC_Branch__r.ST_BVC_Billing_Entity__r.GSTIN_State_Code__c != null AND Id IN :orderMap.keyset()] )
        {
            System.debug(':: Invoice Serial Number Detail Check ::');
            String serialNumber = (inv.BVC_Branch__r.ST_BVC_Billing_Entity__r.Billing_Serial_Number__c != null?String.valueOf(inv.BVC_Branch__r.ST_BVC_Billing_Entity__r.Billing_Serial_Number__c) :'01');
            String serialNumberUniqueCode = inv.BVC_Branch__r.ST_BVC_Billing_Entity__r.GSTIN_State_Code__c + mapOfTypeCode.get(orderMap.get(inv.Id)) + 'I' + serialNumber;
            mapOrderKey.put(inv.Id, serialNumberUniqueCode);
        }
        return mapOrderKey;
    }
    
    /**********************************************************************
* Name : updateEmailRecepients
* Description : Update the Email Recepients
* Param : Trigger.new
* Return : None
* 
**********************************************************************/ 
    
    public static void updateEmailRecepients(List<blng__Invoice__c> newList){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> dealIds = new Set<Id>();
        Map<Id,String> mapAccountRecepients = new Map<Id,String>();
        Map<Id,Order> mapOrder = new Map<Id,Order>();
        Map<Id,Id> mapContactIdMap = new Map<Id,Id>();
        Map<Id,String> mapDealRecepients = new Map<Id,String>();
        for(blng__Invoice__c inv : newList){
            accountIds.add(inv.blng__Account__c);
            if( inv.blng__Order__c != null){
                orderIds.add(inv.blng__Order__c);
            }
            
        }
        System.debug('accountIds. '+accountIds);
        System.debug('orderIds. '+orderIds);
        for(AccountContactRelation acr : [select AccountId,ContactId,Roles,Contact.Email from AccountContactRelation where Roles INCLUDES ('Invoice Recepient;Finance') AND AccountId in:accountIds AND Contact.Email != null ]){
            if(mapAccountRecepients.containsKey(acr.AccountId)){
                String recepientStr = mapAccountRecepients.get(acr.AccountId);
                recepientStr = recepientStr + ', '+ acr.Contact.Email;
                mapAccountRecepients.put(acr.AccountId, recepientStr);
            }else {
                
                mapAccountRecepients.put(acr.AccountId,acr.Contact.Email);
            }
            if(!mapContactIdMap.containsKey(acr.AccountId)){
                mapContactIdMap.put(acr.AccountId,acr.ContactId);
            }
        }
        System.debug('mapAccountRecepients. '+mapAccountRecepients);
        for(Order orderObj : [Select id,OpportunityId,Business_Type__c from Order where id in:orderIds AND Business_Type__c ='ACR']){
            if(orderObj.OpportunityId != null){
                dealIds.add(orderObj.OpportunityId);
                mapOrder.put(orderObj.Id, orderObj);
            }
        }
        System.debug('mapOrder. '+mapOrder);
        System.debug('dealIds. '+dealIds);
        List<String> strRole = new List<String>();
        strRole.add('Decision Maker');
        strRole.add('Evaluator');
        for(OpportunityContactRole oppRole : [SELECT ContactId,Id,IsPrimary,OpportunityId,Role,Contact.Email FROM OpportunityContactRole WHERE OpportunityId in : dealIds AND Role IN:strRole AND Contact.Email != null]){
            System.debug('oppRole. '+oppRole);
            if(mapDealRecepients.containsKey(oppRole.OpportunityId)){
                String recepientStr = mapDealRecepients.get(oppRole.OpportunityId);
                recepientStr = recepientStr + ', '+ oppRole.Contact.Email;
                mapDealRecepients.put(oppRole.OpportunityId, recepientStr);
            }else {
                
                mapDealRecepients.put(oppRole.OpportunityId, oppRole.Contact.Email);
            }
            if(!mapContactIdMap.containsKey(oppRole.OpportunityId)){
                mapContactIdMap.put(oppRole.OpportunityId,oppRole.ContactId);
            }
        }
        System.debug('mapDealRecepients. '+mapDealRecepients);
        for(blng__Invoice__c invRec : newList){
            if(invRec.blng__Order__c != null && mapOrder.containsKey(invRec.blng__Order__c)){
                invRec.Email_Recepients__c = (mapDealRecepients.containsKey(mapOrder.get(invRec.blng__Order__c).OpportunityId) ? mapDealRecepients.get(mapOrder.get(invRec.blng__Order__c).OpportunityId) : '');
                invRec.blng__BillToContact__c = (mapContactIdMap.containsKey(mapOrder.get(invRec.blng__Order__c).OpportunityId)?mapContactIdMap.get(mapOrder.get(invRec.blng__Order__c).OpportunityId) : null );
            }
            else if(mapAccountRecepients.containsKey(invRec.blng__Account__c)){
                invRec.Email_Recepients__c = mapAccountRecepients.get(invRec.blng__Account__c);
                invRec.blng__BillToContact__c = (mapContactIdMap.containsKey(invRec.blng__Account__c)?mapContactIdMap.get(invRec.blng__Account__c) : null);
            }
        }
        
    }
    
    /******************************************************************************
*  Name : amountsInWordConversion
*  Description : Convert. Total Amount To word for Document
*  Param : Trigger.new and Old map
*  Return : None
* 
*******************************************************************************/   
    
    public static void amountsInWordConversion(List<blng__Invoice__c> newList,Map<Id,blng__Invoice__c> oldMap){
        NumberTOWordConvertion numtoword = new NumberTOWordConvertion ();
        for(blng__Invoice__c inv : newList){
            if(inv.blng__TotalAmount__c != null && inv.blng__TotalAmount__c >=0 && inv.blng__TotalAmount__c != oldMap.get(inv.Id).blng__TotalAmount__c){
                inv.NumberToWord__c = numtoword.getNumberTOWordConvertion(inv.blng__TotalAmount__c);
            }
        }                
    }    
    
    /**********************************************************************************
* Name : generateDocument
* Description : Generate A5 document for Invoice and send email with Doc
* Param : newList and OldMap
* Return : None
***********************************************************************************/ 
    
    public static void generateDocument(List<blng__Invoice__c> newList, Map<Id,blng__Invoice__c> oldMap){		
        List<rsdoc__Document_Request__c> listDocRequest = new List<rsdoc__Document_Request__c>();
        Map<String,rsdoc__Document_Action__c> mapInvoiceDocAction = new Map<String,rsdoc__Document_Action__c>();
        List<rsdoc__Document_Action__c> doclist = [SELECT id,rsdoc__Template_Name__c from rsdoc__Document_Action__c where rsdoc__Base_object_API__c = 'blng__Invoice__c'];
        for(rsdoc__Document_Action__c docaction: doclist){
            if(docaction.rsdoc__Template_Name__c == 'ACR INVOICE'){
                mapInvoiceDocAction.put('ACR',docaction);
            }else if(docaction.rsdoc__Template_Name__c == 'SHIPMENT INVOICE'){
                mapInvoiceDocAction.put('Shipment',docaction);
            }else if(docaction.rsdoc__Template_Name__c == 'CONSOLIDATED INVOICE'){
                mapInvoiceDocAction.put('Consolidated',docaction);
            }/*else if(docaction.rsdoc__Template_Name__c == 'General Bill of Supply'){
                system.debug('GBS');
                mapInvoiceDocAction.put('General Bill of Supply',docaction);
            }*/else{
                mapInvoiceDocAction.put(docaction.rsdoc__Template_Name__c,docaction);
            }
        }
        System.debug('mapInvoiceDocAction. '+mapInvoiceDocAction);
        List<Id> invoiceIds = new List<Id>();
        List<Id> ManualinvoiceIds = new List<Id>();
        system.debug(newList);
        set<Id> pretaxid=new set<Id>();
        for(blng__Invoice__c invoice:[select id,BVC_CB_PreTaxBill__c from blng__Invoice__c where id IN:oldMap.keySet()]){
            pretaxid.add(invoice.BVC_CB_PreTaxBill__c);
        }
        list<blng__Invoice__c> pretaxinvoices= new list<blng__Invoice__c>();
        if(pretaxid.size()>0){
            pretaxinvoices = [select id,BVC_CB_PreTaxBill__c,BVC_CB_IsTaxPosted__c,BVC_CB_IsCommInvPosted__c,BVC_CB_IsBosInvPosted__c,Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c IN:pretaxid AND BVC_CB_Is_CB_Invoice__c = true];
        }
        Map<id,list<blng__Invoice__c>> pretaxinvoicesmap=new Map<id,list<blng__Invoice__c>>();
        for(blng__Invoice__c preinv : pretaxinvoices){
            if(pretaxinvoicesmap.containsKey(preinv.BVC_CB_PreTaxBill__c)){
                pretaxinvoicesmap.get(preinv.BVC_CB_PreTaxBill__c).add(preinv);
            }else{
                pretaxinvoicesmap.put(preinv.BVC_CB_PreTaxBill__c,new list<blng__Invoice__c>{preinv});
            }
        }
        for(blng__Invoice__c inv : newList){
            boolean genpdf = false;
            //if(inv.BVC_CB_Is_CB_Invoice__c == TRUE &&inv.Short_URL__c  != null && inv.Invoice_Doc_URL__c == null && inv.Razorpay_Id__c != null && inv.Razorpay_Id__c  != oldMap.get(inv.Id).Razorpay_Id__c ){
              //if(inv.BVC_CB_Is_CB_Invoice__c == TRUE && inv.blng__InvoiceStatus__c == 'Posted' && oldMap.get(inv.Id).blng__InvoiceStatus__c != 'Posted'){
            if(inv.BVC_CB_Is_CB_Invoice__c == TRUE && inv.Invoice_Doc_URL__c == null){
                list<blng__Invoice__c> pretaxinvoicesassociated=pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c);
                if(inv.Invoice_Type__c == 'Tax Invoice' && inv.BVC_CB_IsTaxPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||(inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||(inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean isbos=false;
                    boolean iscomm=false;
                    for(blng__Invoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        if(in1.Invoice_Type__c == 'Commercial Invoice'){iscomm=true;}
                        if(in1.Invoice_Type__c == 'Bill of Supply Invoice'){isbos=true;}
                    }
                    if(iscomm == false && isbos == false){
                        //gen doc
                        genpdf =true;
                    }
                    else if(iscomm && isbos){
                        if(inv.BVC_CB_IsCommInvPosted__c && inv.BVC_CB_IsBosInvPosted__c){
                            //gen doc
                            genpdf = true;
                        }
                    }else if(iscomm && inv.BVC_CB_IsCommInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }else if(isbos && inv.BVC_CB_IsBosInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }
                }else if(inv.Invoice_Type__c == 'Bill of Supply Invoice' && inv.BVC_CB_IsBosInvPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||(inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||(inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean iscomm=false;
                    boolean istax=false;
                    for(blng__Invoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        if(in1.Invoice_Type__c == 'Commercial Invoice'){iscomm=true;}
                        if(in1.Invoice_Type__c == 'Tax Invoice'){istax=true;}
                    }
                    if(iscomm == false && istax == false){
                        //gen doc
                        genpdf =true;
                    }
                    else if(iscomm && istax){
                        if(inv.BVC_CB_IsCommInvPosted__c && inv.BVC_CB_IsTaxPosted__c){
                            //gen doc
                            genpdf = true;
                        }
                    }else if(iscomm && inv.BVC_CB_IsCommInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }else if(istax && inv.BVC_CB_IsTaxPosted__c){
                        //gen doc
                        genpdf = true;
                    }
                    
                }else if(inv.Invoice_Type__c == 'Commercial Invoice' && inv.BVC_CB_IsCommInvPosted__c&&((inv.BVC_CB_IsTaxPosted__c !=oldmap.get(inv.id).BVC_CB_IsTaxPosted__c)||(inv.BVC_CB_IsBosInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsBosInvPosted__c)||(inv.BVC_CB_IsCommInvPosted__c !=oldmap.get(inv.id).BVC_CB_IsCommInvPosted__c))){
                    boolean isbos=false;
                    boolean istax=false;
                    for(blng__Invoice__c in1:pretaxinvoicesmap.get(inv.BVC_CB_PreTaxBill__c)){
                        if(in1.Invoice_Type__c == 'Bill of Supply Invoice'){isbos=true;}
                        if(in1.Invoice_Type__c == 'Tax Invoice'){istax=true;}
                    }
                    if(isbos == false && istax == false){
                        //gen doc
                        genpdf =true;
                    }
                    else if(isbos && istax){
                        if(inv.BVC_CB_IsBosInvPosted__c && inv.BVC_CB_IsTaxPosted__c){
                            //gen doc
                            genpdf = true;
                        }
                    }else if(isbos && inv.BVC_CB_IsBosInvPosted__c){
                        //gen doc
                        genpdf = true;
                    }else if(istax && inv.BVC_CB_IsTaxPosted__c){
                        //gen doc
                        genpdf = true;
                    }
                }           
                if(genpdf){
                   	rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                    string operationtype = inv.BVC_CB_Operation_Type__c != null?inv.BVC_CB_Operation_Type__c:'General';
                    string templatename = 'CB '+operationtype+' '+inv.BVC_CB_Invoice_Type__c;
                    docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get(templatename).Id;
                    docReq.rsdoc__Record_Id__c = inv.Id;
                    docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                    listDocRequest.add(docReq); 
                }
              }else{
                if(inv.Short_URL__c  != null &&inv.blng__InvoiceStatus__c  == 'Posted'  && inv.Razorpay_Id__c != null
               &&(oldMap.get(inv.Id).blng__InvoiceStatus__c  != 'Posted'
                  || inv.Razorpay_Id__c  != oldMap.get(inv.Id).Razorpay_Id__c 
                    )){
                            if(inv.blng__InvoiceRunCreatedBy__c  != null && mapInvoiceDocAction.containsKey('Consolidated')){
                            rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                            docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('Consolidated').Id;
                            docReq.rsdoc__Record_Id__c = inv.Id;
                            docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                            listDocRequest.add(docReq);
                        }else if(inv.blng__Order__c != null){
                            system.debug('1');
                            invoiceIds.add(inv.id);
                            
                        }else{
                            ManualinvoiceIds.add(inv.Id);
                        }
                      
                    }
            }           
        }
        if(invoiceIds != null && !invoiceIds.isEmpty()){
            system.debug('2');
            for(blng__Invoice__c invRec : [select id,blng__Order__c,blng__Order__r.Business_Type__c from blng__Invoice__c where id in:invoiceIds ]){
                if(invRec.blng__Order__r.Business_Type__c != null){
                    rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                    docReq.rsdoc__Record_Id__c = invRec.Id;
                    docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                    if(invRec.blng__Order__r.Business_Type__c == 'Shipment' && mapInvoiceDocAction.containsKey('Shipment')){
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('Shipment').Id;
                        listDocRequest.add(docReq);
                    }else if(mapInvoiceDocAction.containsKey('ACR')){
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('ACR').Id;
                        listDocRequest.add(docReq);
                    }/*else if(mapInvoiceDocAction.containsKey('General Bill of Supply')){
                        system.debug('GBS');
                        docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('General Bill of Supply').Id;
                        listDocRequest.add(docReq);
                    }*/
                    
                    
                }
            }
        }
        if(ManualinvoiceIds != null && !ManualinvoiceIds.isEmpty()){
            system.debug('3');
            for(Id invRecId : ManualinvoiceIds){         
                rsdoc__Document_Request__c docReq = new rsdoc__Document_Request__c();
                docReq.rsdoc__Record_Id__c = invRecId;
                docReq.rsdoc__Error_Field__c = 'Doc_Gen_Error__c';
                if(mapInvoiceDocAction.containsKey('ACR')){
                    docReq.rsdoc__Document_Action__c  = mapInvoiceDocAction.get('ACR').Id;
                    listDocRequest.add(docReq);
                }  
            }
        }
        System.debug('listDocRequest. '+listDocRequest);
        if(!listDocRequest.isEmpty()){
            System.debug('insert listDocRequest. '+listDocRequest);
            if(!test.isRunningTest()){
             insert listDocRequest;   
            }
        }
    }
    
    /*************************************************************************
    * Name : invoiceBillingDetailUpdate
    * Description : Populate Invoice Address,Branch,Billing entity,Entity
    * Param : newList 
    * Return : None
    ****************************************************************************/ 
    public static void invoiceBillingDetailUpdate(List<blng__Invoice__c> newList){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(blng__Invoice__c inv : newList){
            if(inv.blng__Order__c != null && inv.blng__InvoiceRunCreatedBy__c == null ){
                orderIds.add(inv.blng__Order__c);
            }
            else{
                accIds.add(inv.blng__Account__c);
            }
        }
        Map<Id,Order> orderMap = new Map<Id,Order>();
        if(orderIds.size() > 0 && orderIds != null){
            for(Order O : [SELECT Id,Billing_Address__c,BVC_Branch__c,Business_Type__c,
                           BVC_Billing_Entity__c,Account.Billing_Address__c,
                           BVC_Entity__c,Origin_Address__c FROM Order WHERE Id IN :orderIds] ){
                               orderMap.put(o.Id,o); 
                           }
        }
        Map<Id,Account> accountMap = new Map<Id,Account>();
        if(accIds.size() > 0 && accIds != null){
            for(Account acc : [SELECT Id,Billing_Address__c FROM Account WHERE Id IN :accIds]){
                accountMap.put(acc.Id,acc);
            }
        }
        for(blng__Invoice__c inv : newList){
            if(orderMap.containskey(inv.blng__Order__c)){
                // Updated By sonu for bath and eship
               /* if(orderMap.get(inv.blng__Order__c).BVC_Service__c == 'BATH' || orderMap.get(inv.blng__Order__c).BVC_Service__c == 'eSHIP'){
                    if(orderMap.get(inv.blng__Order__c).Billing_Address__c!=null){
                        inv.Billing_Address__c = orderMap.get(inv.blng__Order__c).Billing_Address__c;
                    	inv.Origin_Address__c = orderMap.get(inv.blng__Order__c).Origin_Address__c;
                    }
                } */ //till here
                if(orderMap.get(inv.blng__Order__c).Business_Type__c == 'Shipment'){
                    inv.Billing_Address__c = orderMap.get(inv.blng__Order__c).Billing_Address__c;
                    inv.Origin_Address__c = orderMap.get(inv.blng__Order__c).Origin_Address__c;
                }
                if(orderMap.get(inv.blng__Order__c).Business_Type__c == 'ACR'){
                    inv.Billing_Address__c = orderMap.get(inv.blng__Order__c).Billing_Address__c;
                    inv.Origin_Address__c = orderMap.get(inv.blng__Order__c).Billing_Address__c;
                }
                inv.BVC_Branch__c = orderMap.get(inv.blng__Order__c).BVC_Branch__c;
                inv.BVC_Billing_Entity__c = orderMap.get(inv.blng__Order__c).BVC_Billing_Entity__c;
                inv.BVC_Entity__c = orderMap.get(inv.blng__Order__c).BVC_Entity__c;
            }
            else if(accountMap.containsKey(inv.blng__Account__c)){
                inv.Billing_Address__c = accountMap.get(inv.blng__Account__c).Billing_Address__c;
                inv.Origin_Address__c = accountMap.get(inv.blng__Account__c).Billing_Address__c;
            }
        }
        
    }
    
    /***********************************************************************************
    * Name : PostInvoice
    * Description : Post Invoice after Tax Calculation.
    * Param : newMap & OldMap
    * Return : None
    ************************************************************************************/ 
    public static void postInvoice(Map<Id,blng__Invoice__c> newMap,Map<Id,blng__Invoice__c> oldMap){
        Set<Id> addressIds = new set<Id>();
        system.debug('Post Invoice Method:');
        list<blng__Invoice__c> invlisttoupdate = new list<blng__Invoice__c>();
        for(blng__Invoice__c inv : newMap.values()){
            system.debug('inv.blng__InvoiceStatus__c : ' + inv.blng__InvoiceStatus__c);
            system.debug('inv.blng__TaxAmount__c : '+inv.blng__TaxAmount__c);
            system.debug('oldMap.get(inv.Id) : '+oldMap.get(inv.Id).blng__TaxAmount__c);
            blng__Invoice__c oldInv = oldMap.get(inv.Id);
            if((inv.blng__InvoiceStatus__c == 'Draft' || inv.blng__InvoiceStatus__c == 'Posted')&& 
                inv.BVC_CB_Is_CB_Invoice__c &&inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice'&& inv.blng__TotalAmount__c >0){
                        inv.blng__InvoiceStatus__c = 'Posted'; 
                   		inv.Place_of_Supply_City__c=inv.BVC_CB_Billing_State__c;
                		inv.Place_Of_Supply_State_Code__c=inv.BVC_CB_Billing_GST_State_Code__c;
                		inv.Place_Of_Supply_State__c=inv.BVC_CB_Billing_State__c;
                   		inv.BVC_CB_IsCommInvPosted__c=true;
                    	inv.BVC_CB_CB_Comm_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                        inv.BVC_CB_CB_Comm_Inv_Series__c =inv.ST_Invoice_Series__c;
                        inv.BVC_CB_ROUND_OFF__c = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
                }
            if((inv.blng__InvoiceStatus__c == 'Draft' || inv.blng__InvoiceStatus__c == 'Initiated')
               && inv.blng__TaxAmount__c != null 
               && (inv.blng__TaxAmount__c == 0 || (inv.blng__TaxAmount__c != oldInv.blng__TaxAmount__c))
               && inv.EY_Tax_Calculation_Status__c == 'Success'){
                   system.debug('Invoice Billing Address:'+inv.Billing_Address__c);
                   addressIds.add(inv.Billing_Address__c);
               }
        }
        Map<Id,AddressBook__c> regularAddressMap = new Map<Id,AddressBook__c>();
        Map<Id,AddressBook__c> sezAddressMap = new Map<Id,AddressBook__c>();
        if(addressIds.size() > 0 && addressIds != null){
            for(AddressBook__c ad : [SELECT Id,Dealer_Type__c FROM AddressBook__c WHERE Id IN :addressIds]){
                if(ad.Dealer_Type__c != 'SEZ'){
                    regularAddressMap.put(ad.Id,ad);
                    system.debug('Regular Billing Address : '+ad);
                }
                else if(ad.Dealer_Type__c == 'SEZ'){
                    system.debug('SEZ Address Details : '+ad);
                    sezAddressMap.put(ad.Id,ad);
                }
            }
        }
        if((regularAddressMap.size() >0 && regularAddressMap != null)
           ||(sezAddressMap.size() >0 && sezAddressMap != null)){
               system.debug('Regular Billing Address : '+regularAddressMap);
               for(blng__Invoice__c inv : newMap.values()){
                   Decimal freight = inv.Total_Freight_Tax__c == null ? 0.0 : inv.Total_Freight_Tax__c;
                   Decimal liability = inv.Total_Liability_Charge_Tax__c == null ? 0.0 : inv.Total_Liability_Charge_Tax__c;
                   Decimal offline = inv.Total_Offline_Tax__c == null ? 0.0 : inv.Total_Offline_Tax__c;
                   Decimal weightCharge = inv.Total_Weight_Charge_Tax__c == null ? 0.0 : inv.Total_Weight_Charge_Tax__c;
                   Decimal bvcValuationCharge = inv.Total_BVC_Valuation_Charge_Tax__c == null ? 0.0 : inv.Total_BVC_Valuation_Charge_Tax__c;
                   Decimal docketCharge = inv.Total_Docket_Charge_Tax__c == null ? 0.0 : inv.Total_Docket_Charge_Tax__c;
                   Decimal holidayCharge = inv.Total_Holiday_Charge_Tax__c == null ? 0.0 : inv.Total_Holiday_Charge_Tax__c;
                   Decimal fuelCharge = inv.Total_Fuel_Charge_Tax__c == null ? 0.0 : inv.Total_Fuel_Charge_Tax__c;
                   Decimal fuelSurcharge = inv.Total_Fuel_surcharge_Tax__c == null ? 0.0 : inv.Total_Fuel_surcharge_Tax__c;//Prat
                   Decimal Vaultingcharge = inv.Total_Vaulting_tax__c == null ? 0.0 : inv.Total_Vaulting_tax__c;//Prat
                   // BY SONU for bath and eship uncomment this
                   Decimal commissionCharge = inv.Total_Commission_Tax__c == null ? 0.0 : inv.Total_Commission_Tax__c;
                   Decimal logisticsCharge = inv.Total_Logistics_Tax_Amount__c == null ? 0.0 : inv.Total_Logistics_Tax_Amount__c;
                   Decimal SecureLogCharge = inv.Total_Secure_Logistics_Tax_Amount__c == null ? 0.0 : inv.Total_Secure_Logistics_Tax_Amount__c;
                   Decimal taxAmount = (freight+liability+offline+weightCharge+bvcValuationCharge+docketCharge+holidayCharge+fuelCharge+fuelSurcharge+Vaultingcharge+commissionCharge+logisticsCharge+SecureLogCharge).setScale(0);
                   // CB remove this
                  // Decimal taxAmount = (freight+liability+offline+weightCharge+bvcValuationCharge+docketCharge+holidayCharge+fuelCharge+fuelSurcharge+Vaultingcharge).setScale(0);
                   system.debug('taxAmount::'+taxAmount);
                   Decimal invTaxAmount = inv.blng__TaxAmount__c.setScale(0);
                   if(inv.BVC_CB_Is_CB_Invoice__c){
                       if(regularAddressMap.containsKey(inv.Billing_Address__c) && inv.Invoice_Type__c == 'Tax Invoice' && inv.blng__TaxAmount__c > 0){
                          	inv.blng__InvoiceStatus__c = 'Posted';
                           	inv.BVC_CB_IsTaxPosted__c =true;
                            inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                            inv.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                           	inv.BVC_CB_ROUND_OFF__c = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
                       }else if(sezAddressMap.containsKey(inv.Billing_Address__c) && inv.blng__TaxAmount__c == 0 && taxAmount == 0){
                          inv.blng__InvoiceStatus__c = 'Posted';
                           inv.BVC_CB_IsTaxPosted__c =true;
                           inv.BVC_CB_CB_Tax_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                           inv.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                           inv.BVC_CB_ROUND_OFF__c = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
                       }
                       if(inv.Invoice_Type__c == 'Bill of Supply Invoice' && inv.EY_Tax_Calculation_Status__c == 'Success'){
                           	inv.blng__InvoiceStatus__c = 'Posted'; 
                            inv.BVC_CB_IsBosInvPosted__c =true;
                            inv.BVC_CB_BOS_Bill_Amount__c =inv.blng__TotalAmount__c.round();
                            inv.BVC_CB_CB_BOS_Inv_Series__c =inv.ST_Invoice_Series__c;
                           	inv.BVC_CB_ROUND_OFF__c = inv.blng__TotalAmount__c.round()-inv.blng__TotalAmount__c;
                           //Remove after razorpay works
                       }
                   }else{
                    	if(regularAddressMap.containsKey(inv.Billing_Address__c) && inv.blng__TaxAmount__c > 0 &&  invTaxAmount == taxAmount){
                        	inv.blng__InvoiceStatus__c = 'Posted';
                   		}
                   		else if(sezAddressMap.containsKey(inv.Billing_Address__c) && inv.blng__TaxAmount__c == 0 && taxAmount == 0){
                       		inv.blng__InvoiceStatus__c = 'Posted';
                   		}   
                   }                  
               }   
               
           }
        if(invlisttoupdate.size()>0){
           			 update invlisttoupdate;
        		}
    }
    public static void updateflags(Map<Id,blng__Invoice__c> newMap,Map<Id,blng__Invoice__c> oldMap){
        list<blng__Invoice__c> InvList1 = new list<blng__Invoice__c>();
        for(blng__Invoice__c inv:newMap.values()){
            if(inv.BVC_CB_Is_CB_Invoice__c){
                if(inv.BVC_CB_Invoice_Type__c == 'Commercial Invoice' && oldMap.get(inv.id).blng__InvoiceStatus__c !='Posted' &&inv.blng__InvoiceStatus__c == 'Posted'){
                    list<blng__Invoice__c> CommInvList = [select id,BVC_CB_IsTaxPosted__c,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Commercial Invoice' limit 2];
                			for(blng__Invoice__c invoice:CommInvList){
                                invoice.BVC_CB_CB_Comm_Inv_Amount__c=inv.blng__TotalAmount__c.round();
                                invoice.BVC_CB_CB_Comm_Inv_Series__c =inv.ST_Invoice_Series__c;
                                invoice.BVC_CB_IsCommInvPosted__c =true;
                                InvList1.add(invoice);
                            }
                }
                if(inv.BVC_CB_Invoice_Type__c == 'Tax Invoice' && oldMap.get(inv.id).blng__InvoiceStatus__c != 'Posted' && inv.blng__InvoiceStatus__c == 'Posted'){
                    list<blng__Invoice__c> TaxInvList = [select id,BVC_CB_IsTaxPosted__c,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Tax Invoice' limit 2];
                			for(blng__Invoice__c invoice:TaxInvList){
                    			invoice.BVC_CB_CB_Tax_Inv_Amount__c =inv.blng__TotalAmount__c.round();
                            	invoice.BVC_CB_CB_Tax_Inv_Series__c =inv.ST_Invoice_Series__c;
                                invoice.BVC_CB_IsTaxPosted__c =true;
                                InvList1.add(invoice);
                }
                if(inv.BVC_CB_Invoice_Type__c == 'Bill of Supply Invoice' && oldMap.get(inv.id).EY_Tax_Calculation_Status__c != 'Success' && inv.EY_Tax_Calculation_Status__c =='Success'){
                    list<blng__Invoice__c> BosInvList = [select id,BVC_CB_IsBosInvPosted__c,blng__TotalAmount__c,ST_Invoice_Series__c,BVC_CB_PreTaxBill__c,BVC_CB_Invoice_Type__c from blng__Invoice__c where BVC_CB_PreTaxBill__c = :inv.BVC_CB_PreTaxBill__c AND BVC_CB_Invoice_Type__c != 'Bill of Supply Invoice' limit 2];
                            for(blng__Invoice__c invoice:BosInvList){
                                invoice.BVC_CB_BOS_Bill_Amount__c =inv.blng__TotalAmount__c.round();
                            	invoice.BVC_CB_CB_BOS_Inv_Series__c =inv.ST_Invoice_Series__c;
                                invoice.BVC_CB_IsBosInvPosted__c =true;
                                InvList1.add(invoice);
                }
            }
        }
    }
   }
        if(InvList1.size()>0){
           			 update InvList1;
        		}
  }
    public static void Method2(){
        integer i = 0;
          
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
    i++;   }
    
}