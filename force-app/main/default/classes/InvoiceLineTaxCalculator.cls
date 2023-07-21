public class InvoiceLineTaxCalculator {
    public static void lineTaxCalculator(Map<Id,blng__Invoice__c> invMap){
        List<Id> razorpayIds = new  List<Id>();
        for(blng__Invoice__c inList:invMap.values()){
          razorpayIds.add(inList.id);  
        }
        Map<Id,blng__Invoice__c> invoicesStatusUpdate = new Map<Id,blng__Invoice__c>();
        List<blng__InvoiceLine__c> lines = [SELECT Id,Commission_Charges__c,Logistics_Charges__c,Secure_Logistics_Charges__c,Name,blng__Subtotal__c,Liability_Charges__c,blng__Invoice__c,Freight_Charges__c,ST_Offline_Charge__c,
                                            BVC_Valuation_Charges__c, Docket_Charges__c,Fuel_Charges__c,Holiday_Charges__c,Weight_Charges__c,Fuel_Surcharge__c,Vaulting_Charges__c
                                            FROM blng__InvoiceLine__c
                                            WHERE blng__Invoice__c IN :invMap.keySet()];
        system.debug(':::Invoice Line:::'+lines);
        List<blng__InvoiceLine__c> invLines = new List<blng__InvoiceLine__c>();
        for(blng__InvoiceLine__c li : lines){
            blng__Invoice__c inv = invMap.get(li.blng__Invoice__c);
            system.debug('Invoice tax Percent : Calc Class'+inv.ST_Tax_Percent__c);
            system.debug('Invoice freight tax Percent : Calc Class'+inv.Total_Freight_Tax__c + ' : '+inv.Total_Offline_Tax__c);
            li.blng__TaxAmount__c = 0.0;
            Decimal taxPercent = inv.ST_Tax_Percent__c;
          
             	if(inv.Total_Freight_Tax__c != null &&li.Freight_Charges__c != null && inv.Total_Freight_Charges__c != null && inv.Total_Freight_Charges__c >0 ){
                li.Freight_Tax_Amount__c = li.Freight_Charges__c * taxPercent; 
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Freight_Charges__c * taxPercent);
            }
            
            if(inv.Total_Offline_Tax__c != null && li.ST_Offline_Charge__c != null && inv.Total_Offline_Charges__c != null && inv.Total_Offline_Charges__c > 0){
                li.Offline_tax_Amount__c = li.ST_Offline_Charge__c*taxPercent;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.ST_Offline_Charge__c * taxPercent);
            }
            
            if(inv.Total_Liability_Charge_Tax__c != null && li.Liability_Charges__c != null && inv.Total_Liability_Charge__c != null && inv.Total_Liability_Charge__c > 0){
                li.Liability_Coverage_Tax__c = li.Liability_Charges__c * taxPercent;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Liability_Charges__c * taxPercent);
            }
            if(inv.Total_BVC_Valuation_Charge_Tax__c != null && li.BVC_Valuation_Charges__c != null && inv.Total_BVC_Valuation_Charges__c    != null && inv.Total_BVC_Valuation_Charges__c > 0){                
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.BVC_Valuation_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            }
            if(inv.Total_Docket_Charge_Tax__c != null && li.Docket_Charges__c != null && inv.Total_Docket_Charges__c != null && inv.Total_Docket_Charges__c > 0){              
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Docket_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            }
            if(inv.Total_Fuel_Charge_Tax__c != null && li.Fuel_Charges__c != null && inv.Total_Fuel_Charges__c   != null && inv.Total_Fuel_Charges__c > 0){               
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Fuel_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            }
            if(inv.Total_Holiday_Charge_Tax__c != null && li.Holiday_Charges__c != null && inv.Total_Holiday_Charges__c  != null && inv.Total_Holiday_Charges__c > 0){             
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Holiday_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            }
            if(inv.Total_Weight_Charge_Tax__c != null && li.Weight_Charges__c != null && inv.Total_Weight_Charges__c     != null && inv.Total_Weight_Charges__c > 0){            
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Weight_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            }  
               //Prat
              system.debug(inv.Total_Fuel_surcharge_Tax__c);
              if(inv.Total_Fuel_surcharge_Tax__c != null && li.Fuel_Surcharge__c != null && inv.Total_Fuel_Surcharge__c!= null && inv.Total_Fuel_Surcharge__c > 0){
                li.Fuel_Surcharge_Tax_amount__c = li.Fuel_Surcharge__c*taxPercent;
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Fuel_Surcharge__c * taxPercent);
            }   
               if(inv.Total_Vaulting_tax__c != null && li.Vaulting_Charges__c != null && inv.Total_Vaulting_Charges__c!= null && inv.Total_Vaulting_Charges__c > 0){                
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Vaulting_Charges__c * taxPercent);
                System.debug('Tax Amount '+li.blng__TaxAmount__c);
            } 
        
            
            // FOR BATH AND ESHIP
 
            if(inv.Total_Commission_Tax__c != null && li.Commission_Charges__c != null && inv.Total_Commission_Charges__c     != null && inv.Total_Commission_Charges__c > 0){
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.Commission_Tax_Amount__c = li.Commission_Charges__c * taxPercent; 
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Commission_Charges__c * taxPercent);
                
            }
            if(inv.Total_Logistics_Tax_Amount__c != null && li.Logistics_Charges__c != null && inv.Total_Logistics_Charges__c     != null && inv.Total_Logistics_Charges__c > 0){
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.Logistics_Tax_Amount__c = li.Logistics_Charges__c * taxPercent; 
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Logistics_Charges__c * taxPercent);
               
            }
            
            if(inv.Total_Secure_Logistics_Tax_Amount__c != null && li.Secure_Logistics_Charges__c != null && inv.Total_Secure_Logistics_Charges__c     != null && inv.Total_Secure_Logistics_Charges__c > 0){
                //li.Liability_Coverage_Tax__c = (li.Liability_Charges__c/inv.Total_Liability_Charge__c)*inv.Total_Liability_Charge_Tax__c;
                li.Secure_Logistics_Tax_Amount__c = li.Secure_Logistics_Charges__c * taxPercent; 
                li.blng__TaxAmount__c = li.blng__TaxAmount__c + (li.Secure_Logistics_Charges__c * taxPercent);
                              
            }
            invLines.add(li);
        }
       
        if(invLines.size() >0){
            update invLines;
            //if(!SheduledInv){
               //system.enqueueJob(new RazorpayQueueable(razorpayIds)); 
            //}
        }
    }
}