@isTest
public class ShipmentLotTriggerTest {
    Static TestMethod Void ShipmentLotTriggerTestMethod(){
        Shipment_Lot__c ShipLot = New Shipment_Lot__c();
        ShipLot.Name = 'Test';
        ShipLot.Amount_Calculated_For_All_Shipment__c = TRUE;
        Insert ShipLot;
        Shipment_Lot__c ShipLotUpdate = [SELECT Name FROM Shipment_Lot__c Where Name = 'Test'];
        ShipLotUpdate.Name = 'NewName';
        Update ShipLotUpdate;
    }

}