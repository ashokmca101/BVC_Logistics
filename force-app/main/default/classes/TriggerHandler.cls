public interface TriggerHandler {
	void beforeInsert(List<Shipment__c> newShipment, Map<ID, Shipment__c> oldShipmentMap);
    void beforeUpdate(List<Shipment__c> oldshipment, List<Shipment__c> newShipment, Map<ID, Shipment__c> oldShipmentMap, Map<ID, Shipment__c> newShipmentMap);
    void beforeDelete(List<Shipment__c> oldshipment, Map<ID, Shipment__c> oldShipmentMap);
    void afterInsert(List<Shipment__c> newShipment, Map<ID, Shipment__c> newShipmentMap);
    void afterUpdate(List<Shipment__c> oldshipment, List<Shipment__c> newShipment, Map<ID, Shipment__c> oldShipmentMap, Map<ID, Shipment__c> newShipmentMap);
    void afterDelete(List<Shipment__c> oldshipment, Map<ID, Shipment__c> oldShipmentMap);
    void afterUndelete(List<Shipment__c> newShipment, Map<ID, Shipment__c> newShipmentMap);
}