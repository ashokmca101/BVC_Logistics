/****************************************************************
* Class                 : QueryUtility
* Function              : Utility class to do SOQL Query
* Developer             : Adel Paloli
* Organisation          : Standav
* Version               : 1.0
*****************************************************************/
public class QueryUtilityManual {
    //Query the Invoice,Related fields for EY Integration & Razorpay Integration
    public static List<Id> invoiceQuery(List<Id> invIds){
        List<blng__Invoice__c> eyInvoices = new List<blng__Invoice__c>();
        List<Id> razorpayInvoiceIds =  new List<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        List<blng__Invoice__c> invoiceList = [SELECT Id,Name,Total_Secure_Logistics_Charges__c,Total_Logistics_Charges__c,Total_Commission_Charges__c,Consignee_Name__c ,blng__Order__r.BillingAddress,blng__Order__r.Account.Name,blng__Account__r.Billing_Address__c,
                                              blng__Order__r.blng__BillingAccount__r.Name,blng__Order__r.BillingCity,blng__Account__r.Name,blng__Account__r.ShippingAddress,
                                              blng__Order__r.BillingState,blng__Order__r.BillingCountry,blng__Order__r.ShippingAddress,blng__InvoiceDate__c,
                                              blng__Order__r.ShippingCity,blng__Order__r.ShippingState,blng__Order__r.ShippingCountry,ST_Invoice_Series__c,
                                              blng__Order__r.Billing_Address__r.CITY__c,blng__Order__r.Billing_Address__r.ADDRESS1__c,blng__Account__r.Billing_Address__r.GST_Registered_Status__c,
                                              blng__Order__r.Billing_Address__r.ADDRESS2__c,blng__Order__r.Billing_Address__r.STATE__c,blng__Order__r.Business_Type__c,
                                              blng__Order__r.Billing_Address__r.COUNTRY__c,blng__Order__r.Billing_Address__c,blng__InvoiceRunCreatedBy__c,Place_Of_Supply__c,
                                              BVC_Branch__c,BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,BVC_Branch__r.Hub_City__c,BVC_Entity__c,
                                              BVC_Branch__r.Hub_State__c,BVC_Branch__r.Hub_Country__c,BVC_Branch__r.Hub_Pincode__c,Billing_Address__r.GST_Registered_Status__c,
                                              blng__Account__r.Invoice_Pre_Approval__c,blng__Account__r.Parent.Invoice_Pre_Approval__c,blng__Account__r.PAN_Number_of_Entity__c,
                                              BVC_Billing_Entity__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c,
                                              BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c,BVC_Branch__r.Name,blng__Account__r.GSTIN__c,Billing_Address__r.Dealer_Type__c,
                                              BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,blng__Account__r.BillingAddress,blng__Account__r.Billing_Address__r.Dealer_Type__c,
                                              Origin_Address__c,Origin_Address__r.CITY__c,Origin_Address__r.STATE__c,Origin_Address__r.ADDRESS1__c,Origin_Address__r.ADDRESS2__c,Origin_Address__r.COUNTRY__c,Billing_Address__r.GSTIN__c,
                                              Destination_Address__c,Destination_Address__r.CITY__c,Destination_Address__r.STATE__c,Destination_Address__r.ADDRESS1__c,Destination_Address__r.ADDRESS2__c,Destination_Address__r.COUNTRY__c,
                                              BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Country__c,
                                              Destination_Address__r.PINCODE__c,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c,
                                              Total_BVC_Valuation_Charges__c,BVC_CB_Is_CB_Invoice__c,toLabel(Invoice_Type__c),BVC_CB_Invoice_Type__c,Total_Docket_Charges__c ,Total_Fuel_Charges__c ,Total_Holiday_Charges__c ,Total_Weight_Charges__c ,
                                              Total_Freight_Charges__c,Total_Liability_Charge__c,Total_Offline_Charges__c,BVC_Billing_Entity__r.GSTIN__c,Total_Fuel_Surcharge__c,Total_Vaulting_Charges__c FROM blng__Invoice__c 
                                              WHERE Id In :invIds AND BVC_Branch__c != null AND BVC_Billing_Entity__c != null
                                              AND ST_Invoice_Series__c != null];
        system.debug('invoiceList Query Utility'+invoiceList);
        for(blng__Invoice__c inv : invoiceList){
             if(inv.BVC_CB_Is_CB_Invoice__c == True && inv.Invoice_Type__c !='Commercial Invoice'){
                   invoiceIds.add(inv.Id); 
                   eyInvoices.add(inv);
             }else if(inv.BVC_CB_Is_CB_Invoice__c == True && inv.Invoice_Type__c =='Commercial Invoice'){
                 razorpayInvoiceIds.add(inv.Id);
             }else{
                 invoiceIds.add(inv.Id); 
                 eyInvoices.add(inv);
             }
            
        }
        if(eyInvoices.size() >0){
            List<Id> ids = CPQ_EYController.bearerTokenGenerator(eyInvoices);
                system.debug('Ids>>>'+ids.size());
            if(ids.size() >0){
                
                razorpayInvoiceIds.addAll(ids) ;
            }
            
            
        }
        return razorpayInvoiceIds;
    }
}