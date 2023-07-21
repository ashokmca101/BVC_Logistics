public class ChargeHeadTaxTriggerHandler {
    public static void invoiceTaxCalculator(List<Charge_Head_Tax__c> chargeHeads){
        Set<Id> invoiceIds = new Set<id>();
        List<blng__Invoice__c> invoicestoUpdate = new List<blng__Invoice__c>();
        Map<Id,blng__Invoice__c> invoicestoUpdateMap = new Map<Id,blng__Invoice__c>();
        for(Charge_Head_Tax__c cht : chargeHeads){
            invoiceIds.add(cht.Invoice__c);
            
        }
         
        Map<Id,blng__Invoice__c> invoiceMap = new map<Id,blng__Invoice__c>([SELECT Id,BVC_CB_Invoice_Type__c,(select id,Name,BVC_CB_ChargeType__c from blng__InvoiceInvoiceLines__r),Total_Freight_Tax__c,Total_Offline_Tax__c,Total_Liability_Charge_Tax__c, 
                                                                            Total_BVC_Valuation_Charge_Tax__c,Total_Docket_Charge_Tax__c,Total_Fuel_Charge_Tax__c,
                                                                            Total_Holiday_Charge_Tax__c,Total_Weight_Charge_Tax__c,Total_Secure_Logistics_Tax_Amount__c,Total_Logistics_Tax_Amount__c,Total_Commission_Tax__c
                                                                            ,Total_Fuel_surcharge_Tax__c,Total_Vaulting_tax__c
                                                                            FROM blng__Invoice__c
                                                                            WHERE Id IN :invoiceIds]);
        list<Charge_Head_Tax__c> CBchargetypeCH = new list<Charge_Head_Tax__c>();
        for(Charge_Head_Tax__c cht : chargeHeads){
            system.debug('Charge Head tax amount Name::'+cht.Name+'::Amount::'+cht.Tax_Amount__c);
            if(cht.Name == 'FREIGHT CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal freightTax = inv.Total_Freight_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Freight_Tax__c;
                   if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Freight_Tax__c = freightTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Freight_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
                
            }
            else if(cht.Name == 'OFFLINE CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal offLineTax = inv.Total_Offline_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Offline_Tax__c;
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                        invoicestoUpdateMap.get(inv.Id).Total_Offline_Tax__c = offLineTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Offline_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                    
                }
            }
            else if(cht.Name == 'LIABILITY CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal liabilityTax = inv.Total_Liability_Charge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Liability_Charge_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Liability_Charge_Tax__c = liabilityTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Liability_Charge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            //Prat
            else if(cht.Name == 'FUEL SURCHARGE'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal FSurchargeTax = inv.Total_Fuel_surcharge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Fuel_surcharge_Tax__c;
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                        invoicestoUpdateMap.get(inv.Id).Total_Fuel_surcharge_Tax__c = FSurchargeTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Fuel_surcharge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                    
                }
            }
            else if(cht.Name == 'VAULTING CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal valutingTax = inv.Total_Vaulting_tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Vaulting_tax__c;
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                        invoicestoUpdateMap.get(inv.Id).Total_Vaulting_tax__c = valutingTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Vaulting_tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                    
                }
            }
            //Prat end
            else if(cht.Name == 'BVC VALUATION CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal bvcValuationTax = inv.Total_BVC_Valuation_Charge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_BVC_Valuation_Charge_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_BVC_Valuation_Charge_Tax__c = bvcValuationTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_BVC_Valuation_Charge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            else if(cht.Name == 'DOCKET CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal docketTax = inv.Total_Docket_Charge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Docket_Charge_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Docket_Charge_Tax__c = docketTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Docket_Charge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            else if(cht.Name == 'FUEL CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal fuelTax = inv.Total_Fuel_Charge_Tax__c  == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Fuel_Charge_Tax__c    ;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Fuel_Charge_Tax__c    = fuelTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Fuel_Charge_Tax__c     = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            else if(cht.Name == 'HOLIDAY CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal holidayTax = inv.Total_Holiday_Charge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Holiday_Charge_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Holiday_Charge_Tax__c = holidayTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Holiday_Charge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            else if(cht.Name == 'WEIGHT CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal weightTax = inv.Total_Weight_Charge_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Weight_Charge_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Weight_Charge_Tax__c = weightTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Weight_Charge_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            //BY SONU FOR BATH AND ESHIP
            else if(cht.Name == 'COMMISSION'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal commissionTax = inv.Total_Commission_Tax__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Commission_Tax__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Commission_Tax__c = commissionTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Commission_Tax__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
            else if(cht.Name == 'LOGISTICS CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal logisticsTax = inv.Total_Logistics_Tax_Amount__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Logistics_Tax_Amount__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Logistics_Tax_Amount__c = logisticsTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Logistics_Tax_Amount__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }
             else if(cht.Name == 'SECURE LOGISTICS CHARGES'){
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    Decimal SecurelogisticsTax = inv.Total_Secure_Logistics_Tax_Amount__c == null ? 0.0 : invoiceMap.get(cht.Invoice__c).Total_Secure_Logistics_Tax_Amount__c;
                    
                    if(invoicestoUpdateMap.containsKey(inv.Id)){
                         invoicestoUpdateMap.get(inv.Id).Total_Secure_Logistics_Tax_Amount__c = SecurelogisticsTax + cht.Tax_Amount__c;
                    }
                    else{
                        inv.Total_Secure_Logistics_Tax_Amount__c = cht.Tax_Amount__c;
                        invoicestoUpdateMap.put(inv.Id,inv);
                    }
                   
                }
            }else{
                if(invoiceMap.containsKey(cht.Invoice__c)){
                    blng__Invoice__c inv = invoiceMap.get(cht.Invoice__c);
                    if(inv.BVC_CB_Invoice_Type__c == 'Tax Invoice'){
                        list<blng__InvoiceLine__c> invlines=inv.blng__InvoiceInvoiceLines__r;
                        for(blng__InvoiceLine__c invli :invlines){
                            if(cht.name == invli.Name && cht.BVC_CB_ChargeType__c == null){
                                Charge_Head_Tax__c ch = new Charge_Head_Tax__c(Id=cht.Id);
                                ch.BVC_CB_ChargeType__c = invli.BVC_CB_ChargeType__c;
                                CBchargetypeCH.add(ch);
                            }
                        }                    
                    }
                }
            }
            
        }
        if(CBchargetypeCH.size()>0){
            system.debug(CBchargetypeCH);
            update CBchargetypeCH;
        }
        if(invoicestoUpdateMap.size() > 0){
            system.debug('Invoice to Update'+invoicestoUpdateMap.values());
            try{
                update invoicestoUpdateMap.values();
            }catch(Exception ex){
                system.debug('invoice Update failed::'+ex.getMessage());
            }
            
        }
    }
    public static void chargeHeadCode(List<Charge_Head_Tax__c> chargeHeads){
        for(Charge_Head_Tax__c cht : chargeHeads){
            system.debug('Charge Head tax amount Name::'+cht.Name+'::Amount::'+cht.Tax_Amount__c);
            if(cht.Name == 'FREIGHT CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Freight_Charges').COA_Revenue_Sub_Account__c;
                  
            }
            if(cht.Name == 'OFFLINE CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Offline_Charges').COA_Revenue_Sub_Account__c;
            }
            //Prat
            if(cht.Name == 'FUEL SURCHARGE'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Fuel_Surcharge').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'VAULTING CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Vaulting_Charges').COA_Revenue_Sub_Account__c;
            }
//Prat end
            if(cht.Name == 'BVC VALUATION CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'LIABILITY CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'DOCKET CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'FUEL CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'HOLIDAY CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'WEIGHT CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Liability_Charges').COA_Revenue_Sub_Account__c;
            }
            // FOR BATH AND ESHIP
            if(cht.Name == 'COMMISSION'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Commission').Charge_Code__c; 
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Commission').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'LOGISTICS CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Logistics_Charges').COA_Revenue_Sub_Account__c;
            }
            if(cht.Name == 'SECURE LOGISTICS CHARGES'){
                cht.Charge_Head_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').Charge_Code__c;
                cht.COA_Revenue_Account_Code__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Account_Code__c;
                cht.COA_Revenue_Sub_Account__c = EY_Master_Data__mdt.getInstance('Secure_Logistics_Charges').COA_Revenue_Sub_Account__c;
            }
        }
    }
}