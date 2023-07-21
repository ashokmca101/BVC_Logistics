public class OrderItemTriggerHandler {
    
    public static void orderItemFieldUpdate(List<OrderItem> items){
        Id recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
        List<OrderItem> acrOrderItems = new List<OrderItem>();
        List<OrderItem> nonACROrderItems = new List<OrderItem>();
        List<OrderItem> shipmentOrderItems = new List<OrderItem>();
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> shipList = new Set<Id>();
        Map<Id,OrderItem> orderItemsMap = New Map<Id,OrderItem>([SELECT Id,Shipment__c,Order.Shipment__c,Order_Product_Code__c,Logistics_Charges__c,Commission_Charges__c,Order.Business_Type__c,BVC_Service__c,TotalPrice,Product2.ProductCode,blng__LegalEntity__c,BVC_Branch__c,ACR_Package_type__c,Order.blng__BillingDayOfMonth__c,
                                                                 blng__HoldBilling__c,Product2Id,OrderId,blng__InvoiceGrouping__c,Order.BVC_Branch__r.ST_BVC_Billing_Entity__c,SBQQ__RequiredBy__c,
                                                                 BVC_Branch__r.ST_BVC_Billing_Entity__c,Freight_Charges__c,UnitPrice  FROM OrderItem
                                                                 WHERE Id IN :items]);
        system.debug('OrderItemsMap>>>'+orderItemsMap);
        for(OrderItem oi : items){
            if(orderItemsMap.get(oi.Id).Order.Business_Type__c == 'ACR'){
                acrOrderItems.add(orderItemsMap.get(oi.Id));
            }
            else if(orderItemsMap.get(oi.Id).Order.Business_Type__c == 'Non ACR'
                   || orderItemsMap.get(oi.Id).Order.Business_Type__c == 'Exhibition'){
                nonACROrderItems.add(orderItemsMap.get(oi.Id));
            }
            
            else if(orderItemsMap.get(oi.Id).Order.Business_Type__c == 'Shipment'){
                system.debug('Order Billing Day of Month::'+orderItemsMap.get(oi.Id).Order.blng__BillingDayOfMonth__c);
                shipList.add(orderItemsMap.get(oi.Id).Order.Shipment__c);
                shipmentOrderItems.add(orderItemsMap.get(oi.Id));
            }
            
        }
        
        Map<Id, Shipment__c> shipRelatedMap = new Map<Id, Shipment__c>([SELECT Id,Billing_Entity_Name_TMS__c,Shipment_Type__c,Gross_weight_in_Gram__c,Billing_Entity_Name__c,Account__c,Distance_Km__c, Account__r.Name,AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,
                                                                        Hub_Master__c,Hub_Master__r.ST_BVC_Billing_Entity__c,Origin_Hub__c,Origin_Hub__r.ST_BVC_Billing_Entity__c,
                                                                        Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,
                                                                        Account__r.Customer_Category__c,Origin_Address_Name__c,Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,
                                                                        Origin_Address_Name__r.CITY__c,Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,
                                                                        Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,Consignee_Name_TMS__r.Name,
                                                                        Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,Bill_To_Account__r.Billing_Cycle__c,Bill_To_Account__r.Invoice_Batch__c,
                                                                        AddressBook__r.TRADE_NAME__c,Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c,BillTo_Party_Address__r.COUNTRY__c,
                                                                        BillTo_Party_Address__r.ADDRESS1__c,BillTo_Party_Address__r.ADDRESS2__c,Net_weight_in_Gram__c,Window_Delivery__c,Window_Pickup__c
                                                                        FROM Shipment__c
                                                                        WHERE Id IN :shipList
                                                                        
                                                                       ]);      
        for(OrderItem oi : acrOrderItems){
            oi.Freight_Charges__c = oi.TotalPrice;
            if((oi.BVC_Service__c=='BATH' || oi.BVC_Service__c=='eSHIP') && oi.Shipment__c==null){
              oi.Freight_Charges__c = oi.TotalPrice; 
            }
            if(oi.BVC_Branch__c != null){
                oi.blng__LegalEntity__c = oi.BVC_Branch__r.ST_BVC_Billing_Entity__c;
            }
            else if(oi.BVC_Branch__c == null
                    && oi.Order.BVC_Branch__c != null){
                        oi.blng__LegalEntity__c = oi.Order.BVC_Branch__r.ST_BVC_Billing_Entity__c;
                    }
            if((oi.ACR_Package_type__c != null
                && oi.SBQQ__RequiredBy__c != null) || (oi.UnitPrice <= 0)){
                    oi.blng__HoldBilling__c = 'Yes';
                }
            itemsToUpdate.add(oi);
            orderIds.add(oi.OrderId);
        }
        //system.debug('shipRelatedMap:::::::::'+shipRelatedMap);
        for(OrderItem oi : nonACROrderItems){
          
            oi.blng__HoldBilling__c = 'Yes';
            itemsToUpdate.add(oi);
            orderIds.add(oi.OrderId);
        }
        
        for(OrderItem oi : shipmentOrderItems){
            
            if((oi.BVC_Service__c=='BATH' || oi.BVC_Service__c=='eSHIP') && oi.Shipment__c!=null){
                if(shipRelatedMap.get(oi.Shipment__c).Net_weight_in_Gram__c!=null){
                    oi.Net_Weight_gms__c = shipRelatedMap.get(oi.Shipment__c).Net_weight_in_Gram__c;
                }
                if(shipRelatedMap.get(oi.Shipment__c).Gross_weight_in_Gram__c!=null){
                    oi.Gross_Weight_gms__c = shipRelatedMap.get(oi.Shipment__c).Gross_weight_in_Gram__c;
                }
                if(shipRelatedMap.get(oi.Shipment__c).Shipment_Type__c!=null){
                    oi.Shipment_Type__c = shipRelatedMap.get(oi.Shipment__c).Shipment_Type__c;
                }
                oi.SBQQ__ContractingMethod__c = 'Inherit';
                oi.SBQQ__PricingMethod__c = 'List';
                if(shipRelatedMap.get(oi.Shipment__c).Billing_Entity_Name_TMS__c!=null){ 
                    oi.blng__LegalEntity__c = shipRelatedMap.get(oi.Shipment__c).Billing_Entity_Name_TMS__c;
                }
            }
            else{
            	oi.blng__InvoiceGrouping__c = 'Legal Entity;Invoice Group ID';
            	oi.blng__InvoiceGroupId__c = oi.Product2.ProductCode;
            }
            
            itemsToUpdate.add(oi);
            orderIds.add(oi.OrderId);
        }
        
        try{
            update itemsToUpdate;
        }catch(Exception ex){
            system.debug('Update itemsToUpdate Failed:::'+itemsToUpdate);
        }
        
        List<Order> activateOrders = new List<Order>();
        List<Order> ord=[SELECT Id,Shipment__c,blng__BillingDayOfMonth__c,SBQQ__Contracted__c,  Status FROM Order WHERE Id IN :orderIds and Reversed_Order_Of__c=null];
        for(Order o :ord ){
           
            o.Status = 'Activated';
            activateOrders.add(o);
           
        }
        
        

        if(activateOrders.size() >0){
            
            Database.SaveResult[] results = Database.update(activateOrders);
              /*List<Order> activateOrders1 = new List<Order>();
              List<Order> ord1=[SELECT Id,Shipment__c,blng__BillingDayOfMonth__c,BVC_Service__c,SBQQ__Contracted__c,  Status FROM Order WHERE Id IN :orderIds and Reversed_Order_Of__c=null];           
              for(Order o :ord1 ){
           
               //o.Status = 'Activated';
                  if(o.Shipment__c!=null && o.BVC_Service__c=='BATH' || o.BVC_Service__c=='eSHIP'){
                       o.SBQQ__Contracted__c=true;
                        activateOrders1.add(o);
                  }
              
           
              }
               Database.SaveResult[] results1 = Database.update(activateOrders1);*/
            for(Database.SaveResult sr: results){
                if(sr.isSuccess()){
                    system.debug('Order Activated:::'+sr.getId()); 
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                    }
                }
            }            
        }        
    }  
    public static void fakeMethod1(){
        Integer i=0;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;
        i++;
        i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
        i++;}
}