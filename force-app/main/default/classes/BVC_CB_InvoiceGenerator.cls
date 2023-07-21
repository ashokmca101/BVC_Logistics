public class BVC_CB_InvoiceGenerator {
    
    //
    //TEST CLASS- PreTaxTriggerHandlerTest
    //
    
	public static void createShipmentInvoice(Map<Id,Order> orderMap, Map<Id,List<OrderItem>> orderProductMap){
        List<blng__Invoice__c> newInvoices = new List<blng__Invoice__c>();
        //List<Object_Mapping__mdt> objectMappings = Object_Mapping__mdt.getAll().Values();
        List<BVC_CB_Object_Mapping__c> objectMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='Order' and Is_Active__c = true];
        for(Order o : orderMap.values()){
            blng__Invoice__c inv = new blng__Invoice__c();
            inv.blng__Account__c = o.AccountId;
            inv.blng__Order__c = o.Id;
            inv.blng__InvoiceDate__c = Date.today();
            inv.BVC_Branch__c = o.BVC_Branch__c;
            inv.BVC_Billing_Entity__c = o.BVC_Billing_Entity__c;
            inv.BVC_Entity__c = o.BVC_Entity__c;
            inv.BVC_CB_COA_SOURCE_CODE__c = 44;
            inv.blng__BillToContact__c = o.Account.blng__BillToContact__c;
           /* if(o.Billing_Address__c != null){
                inv.Billing_Address__c = o.Billing_Address__c;
            }
            else if(o.Billing_Address__c == null && o.Account != null){
                        inv.Billing_Address__c = o.Account.Billing_Address__c;
                    }*/
            inv.Origin_Address__c = o.Origin_Address__c;
            inv.BVC_CB_Is_CB_Invoice__c = true;
            for(BVC_CB_Object_Mapping__c fieldMapping : objectMappings){
                        inv.put(fieldMapping.Target_Field_API_Name__c, o.get(fieldMapping.Source_Field_API_Name__c));       
             } 
            newInvoices.add(inv);
        }
        
        if(newInvoices.size() > 0 && newInvoices != null){
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoice Lines were Inserted'+result.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
        }
        Map<Id,Id> orderInvMap = new Map<Id,Id>();
        if(newInvoices.size() > 0 && newInvoices != null){
        for(blng__Invoice__c inv : newInvoices){
            if(inv.blng__Order__c != null && inv.Id != null){
                orderInvMap.put(inv.blng__Order__c,inv.Id);     
            }
            
        }
    }
        List<blng__InvoiceLine__c> lines = new List<blng__InvoiceLine__c>();
        List<BVC_CB_Object_Mapping__c> orderItemMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='OrderItem'];
        
        for(Id key : orderMap.keyset()){
            if(orderProductMap.containsKey(key)){
                for(OrderItem oi : orderProductMap.get(key)){
                    
                    if(orderInvMap.containsKey(oi.OrderId)){
                        blng__InvoiceLine__c li = new blng__InvoiceLine__c();
                        li.blng__OrderProduct__c = oi.Id;
                        li.blng__Product__c = oi.Product2Id;
                        li.blng__Invoice__c = orderInvMap.get(oi.OrderId);
                        li.Name = oi.Product2.Name;
                        li.blng__Quantity__c = oi.Quantity;
                        li.blng__CalculatedQuantity__c = oi.Quantity;
                        li.blng__Subtotal__c = oi.TotalPrice;
                       // li.blng__Subtotal__c = 78.3;
                        li.blng__UnitPrice__c = oi.UnitPrice;
                        
                        li.blng__BillingRule__c = oi.Product2.blng__BillingRule__c;
                        li.blng__TaxRule__c = oi.Product2.blng__TaxRule__c;
                        li.blng__LegalEntity__c = oi.blng__LegalEntity__c;
                        li.blng__BillingTreatment__c = oi.blng__BillingTreatment__c;
                        li.blng__StartDate__c = oi.ServiceDate;
                        li.blng__EndDate__c = oi.EndDate;
                        li.blng__ChargeDate__c = Date.today();
                        for(BVC_CB_Object_Mapping__c fieldMapping : orderItemMappings){
                            li.put(fieldMapping.Target_Field_API_Name__c, oi.get(fieldMapping.Source_Field_API_Name__c));       
                        } 
                        lines.add(li);
                        
                    }
                } 
            }
            
        }
        
        Database.SaveResult[] lsr = Database.insert(lines);
        for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoice Lines were Inserted'+result.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
        
    }
}