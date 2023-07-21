public with sharing class EyManualTaxCalculationClass {
    
    @AuraEnabled
    public static string invoiceEyIntegration(String recordId){ 
        Datetime startTime = Datetime.now();
        try {
           
            List<blng__Invoice__c> invoiceObj = [Select id,BVC_CB_Is_CB_Invoice__c,Total_Fuel_Surcharge__c,Total_Vaulting_Charges__c,Total_Vaulting_tax__c,Total_Fuel_surcharge_Tax__c,Total_Docket_Charge_Tax__c,Total_Commission_Tax__c,Total_Logistics_Tax_Amount__c,Total_Secure_Logistics_Tax_Amount__c,Total_Secure_Logistics_Charges__c,Total_Logistics_Charges__c,Total_Commission_Charges__c,Total_Weight_Charge_Tax__c,Total_Fuel_Charge_Tax__c,Total_Holiday_Charge_Tax__c,Total_BVC_Valuation_Charge_Tax__c,Total_Liability_Charge_Tax__c,Total_Offline_Tax__c,Total_Freight_Tax__c,ST_Tax_Percent__c,blng__InvoiceStatus__c ,BVC_Branch__c,BVC_Billing_Entity__c,Billing_Address__c,Total_Liability_Charge__c,Total_Offline_Charges__c,Total_Freight_Charges__c from blng__Invoice__c where id=:recordId];
            if(invoiceObj[0].blng__InvoiceStatus__c != 'Draft'){
                throw new applicationException('Invice stage should be draft');
            } 
            else if(invoiceObj[0].BVC_Branch__c == null || invoiceObj[0].BVC_Billing_Entity__c == null ){
                throw new applicationException('Invalid Billing Information, Please validate Branch,Billing Entity and Billing Address Values');
            }else if(invoiceObj[0].BVC_CB_Is_CB_Invoice__c == False && (invoiceObj[0].Total_Liability_Charge__c == null || invoiceObj[0].Total_Liability_Charge__c == 0) && 
            (invoiceObj[0].Total_Offline_Charges__c == null || invoiceObj[0].Total_Offline_Charges__c == 0)&& 
            (invoiceObj[0].Total_Freight_Charges__c == null || invoiceObj[0].Total_Freight_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Fuel_Surcharge__c == null || invoiceObj[0].Total_Fuel_Surcharge__c == 0)&&//Prat
            (invoiceObj[0].Total_Vaulting_Charges__c == null || invoiceObj[0].Total_Vaulting_Charges__c == 0)&&//Prat
            (invoiceObj[0].Total_Logistics_Charges__c == null || invoiceObj[0].Total_Logistics_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Commission_Charges__c == null || invoiceObj[0].Total_Commission_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Secure_Logistics_Charges__c == null || invoiceObj[0].Total_Secure_Logistics_Charges__c == 0.00)
            ){
                throw new applicationException('Invalid Amount, Please validate Liability, Frieght and Offline chanrges before applying Tax');
            }else{
                List<Id> invIds = new List<Id>{Id.valueOf(recordId)}; 
                List<Id> razorpayInvoiceIds = new List<Id>();
                if(invIds.size() >0){
                    system.debug('here in invoice');
                    razorpayInvoiceIds.addAll(QueryUtilityManual.invoiceQuery(invIds));
                }
                //List<blng__Invoice__c> invoiceObjMap = [Select id,Total_Logistics_Tax_Amount__c,Total_Secure_Logistics_Tax_Amount__c,Total_Docket_Charge_Tax__c,Total_Weight_Charge_Tax__c,Total_Commission_Tax__c,Total_Fuel_Charge_Tax__c,Total_Holiday_Charge_Tax__c,Total_BVC_Valuation_Charge_Tax__c,Total_Liability_Charge_Tax__c,Total_Offline_Tax__c,Total_Freight_Tax__c,ST_Tax_Percent__c,Total_Secure_Logistics_Charges__c,blng__InvoiceStatus__c ,BVC_Branch__c,BVC_Billing_Entity__c,Total_Logistics_Charges__c,Total_Commission_Charges__c,Billing_Address__c,Total_Liability_Charge__c,Total_Offline_Charges__c,Total_Freight_Charges__c from blng__Invoice__c where id=:recordId];
                //Map<id,blng__Invoice__c> mapInvoiceList =new Map<id,blng__Invoice__c>();
                //for(blng__Invoice__c inv:invoiceObjMap){
                   //mapInvoiceList.put(inv.id,inv); 
                //}
                
                if(razorpayInvoiceIds.size() > 0){
                    //InvoiceLineTaxCalculator.lineTaxCalculator(mapInvoiceList);
                    //system.enqueueJob(new InvoiceLineTaxUpdateQueueable(mapInvoiceList));
                    system.enqueueJob(new RazorpayQueueable(razorpayInvoiceIds));
                    
                }
                Datetime endTime = Datetime.now();
				System.debug('final time: ' + startTime+':::::::::::::::'+endTime);
                return 'Tax Calculation Completed Succesfully, Please refresh the Page';
            }
            
        } catch (Exception e) {
            System.debug('Error Message.  '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public EyManualTaxCalculationClass() {

    }
}