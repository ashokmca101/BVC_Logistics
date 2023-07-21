public without sharing class ShipmentsTriggerHandler implements TriggerHandler{
	private boolean triggerIsExecuting;
    private integer triggerSize;
    public ShipmentsTriggerHelper helper;    
    public ShipmentsTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new ShipmentsTriggerHelper();
     
    }
    
    public void beforeInsert(List<Shipment__c> newShipment, Map<ID, Shipment__c> oldShipmentMap) {
        helper.setPayerBeforeInsert(newShipment);
        helper.updateBillingAccount(newShipment,oldShipmentMap);
      //  helper.updateShipmentStatusBeforeUpdate(newShipment,oldShipmentMap);
    } 
    public void beforeUpdate(List<Shipment__c> oldshipment, List<Shipment__c> newShipment, Map<ID, Shipment__c> oldShipmentMap, Map<ID, Shipment__c> newShipmentMap) {
        helper.setPayerBeforeUpdate(newShipment);
        helper.updateBvcShipmentStage(newShipment,oldShipmentMap);
        helper.validateAndCreateOrders(newShipment,oldShipmentMap);
        helper.updateShipmentStatusBeforeUpdate(newShipment,oldShipmentMap);
        helper.updateBillingAccount(newShipment,oldShipmentMap);
    
    }
    public void beforeDelete(List<Shipment__c> oldshipment, Map<ID, Shipment__c> oldShipmentMap) {
    
    }
    public void afterInsert(List<Shipment__c> newShipment, Map<ID, Shipment__c> newShipmentMap) {
        helper.calculateShipmentAmountAfterInsert(newShipment);
        helper.updateSecurePackaging(newShipment);      
  
    }
    public void afterUpdate(List<Shipment__c> newShipment,List<Shipment__c> oldshipment, Map<ID, Shipment__c> newShipmentMap, Map<ID, Shipment__c> oldShipmentMap) {
        helper.updateDeliveryRouteNo(newShipmentMap, oldShipmentMap);  
        helper.validateAndCreateOrders(newShipment,oldShipmentMap);
        helper.calculateshipmentAmountAfterUpdate(newShipment,oldshipment);
        helper.shareShipmentAfterUpdate(newShipment,oldShipmentMap);
        helper.shareShipmentToEscorterAfterUpdate(newShipment,oldShipmentMap);
        
  
    }
    public void afterDelete(List<Shipment__c> oldshipment, Map<ID, Shipment__c> oldShipmentMap) {
    
    }
    public void afterUndelete(List<Shipment__c> newShipment, Map<ID, Shipment__c> newShipmentMap) {
     
    }
    
     
    
   
}