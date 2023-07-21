global class UpdateOrderBillnow {

@InvocableMethod(label='Update Order Billnow' description='Update Billnow' category='order')
    public static void orderBillnow(List<Id> orderids) {
        List<order> listOrder = [Select Id, ST_Bill_Now__c, blng__BillNow__c FROM order WHERE Id In :orderids];
        
        for(order Orders : listOrder){
            Orders.blng__BillNow__c = true;
        }        
        Database.update(listOrder, false);
    } 
}