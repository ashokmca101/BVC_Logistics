public class Community_RazorpayQueueableCrtInv implements Queueable,Database.AllowsCallouts{
    List <Shipment__c> invoices2RazorPay= new List<Shipment__c>();
    Map<Id,Shipment__c> oldInvMap = new Map<Id,Shipment__c>();
    public Community_RazorpayQueueableCrtInv (List<Shipment__c> invList )
    {
        invoices2RazorPay = invList ;
        //oldInvMap = oldMap;
    }
    public void execute(QueueableContext ctx){
        List<ID> lstShipId = new List<ID>();
        for(Shipment__c inv : invoices2RazorPay){
            /* if(inv.blng__InvoiceStatus__c== 'Posted'
               && oldInvMap.get(inv.Id).blng__InvoiceStatus__c!= inv.blng__InvoiceStatus__c){*/
                     String invName = inv.Id;
            system.debug('invName::'+invName);
             //BVC_RazorPayAPIController.authurl(invName);
               lstShipId.add(inv.Id);   
               //}
           
        }
        Community_BVC_RazorPayAPIController.authurl(lstShipId);
    }
}