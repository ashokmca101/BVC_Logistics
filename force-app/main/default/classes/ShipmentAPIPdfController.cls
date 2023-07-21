/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ShipmentAPIPdfController {
    public List<Secure_Packaging__c> SelectedLabelList {get;set;}
    public static  List<Shipment__c> shipmentList{get;set;}
    public ShipmentAPIPdfController(){
        String ShipId = ApexPages.currentPage().getParameters().get('id');
        shipmentList = new List<Shipment__c>();
        if(string.isNotBlank(ShipId)){
            Shipment__c ship = new Shipment__c();
            ship = [Select Id, name, Shipment_Date__c,Origin_Address_City__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,
                                Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,
                                Number_of_Packages__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                                Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,
                                Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                                Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                                SNN_Bar_Code__c,Shipment_Type__c,Gross_Weight__c,Product_Description__c, Billing_Account__r.name,
                                Billing_Address__r.ADDRESS1__c,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                                Billing_Address__r.PINCODE__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c
                                FROM Shipment__c WHERE Id =:ShipId limit 1];
            shipmentList.add(ship);
            shipmentList.add(ship);
 
        }else{
            string pageType = ApexPages.currentPage().getParameters().get('type');
            if(pageType=='pre'){
                String[] ids = ApexPages.currentPage().getParameters().get('list').split(',');
                SelectedLabelList = [select id, name,Status__c FROM Secure_Packaging__c WHERE id=:ids];
            }
            else if(pageType=='post'){
                String[] ids = ApexPages.currentPage().getParameters().get('list').split(',');
                List<Shipment__c> ShipList = new List<Shipment__c>();
                ShipList = [Select Id, name,Shipment_Date__c, Origin_Address_City__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,
                                Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,
                                Number_of_Packages__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                                Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,
                                Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                                Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                                SNN_Bar_Code__c,Shipment_Type__c,Gross_Weight__c,Product_Description__c,Billing_Account__r.name,
                                Billing_Address__r.ADDRESS1__c,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                                Billing_Address__r.PINCODE__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c
                                FROM Shipment__c WHERE Id in:ids  order by createddate DESC limit 50000];
                for(Shipment__c sh:ShipList){
                    shipmentList.add(sh);
                    shipmentList.add(sh); 
                }
            }
        }
    }
}