/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-04-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-10-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class TMS_ShipmentStatusListView {
 

@AuraEnabled  
public static List<Shipment__c> shipmentFilterList(List<Shipment__c> shipmentList){
    try {
        List<Shipment__c> tempShipmentList = new List<Shipment__c>(); 
        Set<Id> shipmentId = new Set<Id>();
        if(shipmentList.size() > 0){

            for(Shipment__c shipment : shipmentList ){
                shipmentId.add(shipment.Id);
            }

            for(Shipment__c shipmentRecord : [
            SELECT Id,Customer_Product_Category__c,Shipping_Note_Number__c,Customer__r.name,Product_Code__c,Billing_Account__r.name,Billing_Address__r.name,Shipment_Date__c,Shipper_Name_TMS__r.name,
            Origin_Address_Name__r.name,Consignee_Name_TMS__r.name,Destination_Address_Name__r.name,Product_Description__c,Shipment_Value__c,Net_Weight__c,Net_Weight_UOM_TMS__c,Gross_Weight__c,Gross_Weight_UOM_TMS__c,
            Insurance_By__c,Origin_Hub__r.name,Origin_Type__c,Destination_Hub__r.name,Destination_Type__c,Billing_Status__c,IsExhibition__c,Exhibition__r.name,Exhibition_Movement_Type__c
            FROM Shipment__c 
            WHERE Id IN : shipmentId
            ]){ 
                tempShipmentList.add(shipmentRecord);
            } 
        }
        
        return tempShipmentList;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static List<Shipment__c> searchShipment(String account, String billingAccount, String bvcBranch, String bvcProduct, String exhibitionName, Date shipmentDateTo, Date shipmentDateFrom, String readyforRebilling, String readyforbilling){
    try {
        List<ShipmentWrap> shipmentWrapList = new List<ShipmentWrap>();
        String selectSOQL ='SELECT Id,Shipping_Note_Number__c,Customer__c,Customer__r.name,Billing_Account__c,Billing_Account__r.name,Product_Code__c,Verified_for_Billing__c,Billing_Status__c FROM Shipment__c';
        string whereClause = createSOQLWhere(account, billingAccount, bvcBranch, bvcProduct, exhibitionName, shipmentDateTo, shipmentDateFrom, readyforRebilling, readyforbilling);
        if(whereClause !=null && whereClause!= ''){
            selectSOQL += ' WHERE '+whereClause;
        }
        selectSOQL += ' ORDER BY CreatedDate DESC LIMIT 100';
        Integer recordCount = 1;
        System.debug('============= Search SOQL ================: '+selectSOQL); 
        for(Shipment__c shipmentRecord : Database.query(selectSOQL) ){
            ShipmentWrap tempData = new ShipmentWrap();
            tempData.selectShipment = false;
            tempData.shipmentRecord = shipmentRecord;
            tempData.srno = recordCount;
            recordCount++;
            shipmentWrapList.add(tempData); 
        }

        return Database.query(selectSOQL);

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}


@AuraEnabled
public static List<Shipment__c> saveDraftValues(Object data) {
    System.debug('======= saveDraftValues ======= : d'+data);
    List<Shipment__c> listOfShipments = (List<Shipment__c>) JSON.deserialize(
        JSON.serialize(data),
        List<Shipment__c>.class
    );
    update listOfShipments;
    return listOfShipments;
}
public static String createSOQLWhere(String account, String billingAccount, String bvcBranch, String bvcProduct, String exhibitionName, DateTime shipmentDateTo, DateTime shipmentDateFrom, String readyforRebilling, String readyforbilling){
    //System.debug('========account ==========='+account);
    //System.debug('========billingAccount ==========='+billingAccount);
    //System.debug('========bvcBranch ==========='+bvcBranch); 
    //System.debug('========bvcProduct ==========='+bvcProduct);
    //System.debug('========exhibitionName ==========='+exhibitionName);
    //System.debug('========shipmentDateTo ==========='+shipmentDateTo);
    //System.debug('========shipmentDateFrom ==========='+shipmentDateFrom);
    //System.debug('========readyforRebilling ==========='+readyforRebilling);
    //System.debug('========readyforbilling ==========='+readyforbilling);
    String soqlWere = '';
    if(account != null && account != ''){
        soqlWere += ' AND Customer__c = \''+account+'\'';
    }

     if(billingAccount != null && billingAccount!=''){
        soqlWere += ' AND Billing_Account__c = \''+billingAccount+'\'';
    }

     if(bvcBranch != null && bvcBranch!=''){
        soqlWere += ' AND Origin_Hub__c = \''+bvcBranch+'\'';
    }

     if(bvcProduct != null && bvcProduct!=''){
        soqlWere += ' AND Product_Name__c = \''+bvcProduct+'\'';
    }

     if(exhibitionName != null && exhibitionName!=''){
        soqlWere += ' AND Exhibition__c = \''+exhibitionName+'\'';
    }

    if(shipmentDateTo != null ){
        soqlWere += ' AND ( Shipment_Date__c <=  '+shipmentDateTo.format('yyyy-MM-dd');
    }

    if(shipmentDateFrom != null){
        soqlWere += ' AND Shipment_Date__c >= '+shipmentDateFrom.format('yyyy-MM-dd') +' ) ';
    }

    if(readyforRebilling != null && readyforRebilling!=''){
        if(readyforRebilling == 'Yes'){
            soqlWere += ' AND Ready_for_Rebilling__c = true';
        }else{
            soqlWere += ' AND Ready_for_Rebilling__c = false';
        }
        
    }

    if(readyforbilling != null && readyforbilling!=''){
        if(readyforbilling == 'Yes'){
            soqlWere += ' AND Verified_for_Billing__c =true';
        }else{
            soqlWere += ' AND Verified_for_Billing__c = false';
        }
        
    }
   

    System.debug('==== soqlWere==== : '+soqlWere.removeStart(' AND'));
    return soqlWere.removeStart(' AND');
}

   public class ShipmentWrap {
        @AuraEnabled
        public Boolean selectShipment {get;set;}

        @AuraEnabled
        public Integer srno {get;set;}

        @AuraEnabled
        public Shipment__c shipmentRecord {get;set;}
    }


}