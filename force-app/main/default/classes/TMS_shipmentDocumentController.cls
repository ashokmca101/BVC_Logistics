/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TMS_shipmentDocumentController {
    public static  List<Shipment__c> shipmentList{get;set;}
    public static String shipmentJson {get; set;} 
    public List<ShipmentLabelWrapper> LabelWrapList {get;set;}
    public List<Secure_Packaging__c> SelectedLabelList {get;set;}
    
    public TMS_shipmentDocumentController(){
        shipmentList=null;
        shipmentJson='';
        String RequestType = apexpages.currentpage().getparameters().get('ReqType');
        //System.debug('RequestType: '+RequestType);
        LabelWrapList = new List<ShipmentLabelWrapper>();
        if(RequestType=='PreShipment'){ 
            String Origin ;
            try{
                Origin =  TMS_LinehaulClass.currentUserHub();
            }catch(exception e){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please set your primary hub');
                ApexPages.addMessage(errormsg);
                //return null;
            }
            
            //System.debug('origin: '+Origin);
            if(Origin!=null && string.isNotBlank(Origin)){
                Id RecId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
                for(Secure_Packaging__c Label : [select id, name,Status__c FROM Secure_Packaging__c WHERE RecordTypeId=:RecId AND 
				Allocated_To_Hub__r.name =:Origin AND Status__c='Available']){
                    ShipmentLabelWrapper wr = new ShipmentLabelWrapper();
                    wr.selected = false;
                    wr.sp = Label;
                    LabelWrapList.add(wr);
                }
            }
            //System.debug('size: '+LabelWrapList.size());
            //System.debug('LabelWrapList: '+LabelWrapList);
        }
    }
    @AuraEnabled  Public static List<Shipment__c> getShipmentData(String ShippAcc,String OriginHubId, String DestHubId, Date ShipmentDate){
        List<Shipment__c> ShipList = new List<Shipment__c>();
        string query='Select Id, name,Billing_Account__r.Name,BVC_Products__c,Shipment_Date__c,PDF_Generation__c,Ready_for_Billing__c,Ready_for_Rebilling__c,PDF_Generation_Status__c, Shipping_Note_Number__c,Shipper_Name_TMS__r.Name, Origin_Address_Name__r.Name,CreatedBy.Name FROM Shipment__c WHERE Name !=null';
        if(string.isNotBlank(ShippAcc))
            query +=' AND Shipper_Name_TMS__c=:ShippAcc';
        if(string.isNotBlank(OriginHubId))
            query +=' AND Origin_Hub__c=:OriginHubId';
        if(string.isNotBlank(DestHubId))
            query +=' AND Destination_Hub__c=:DestHubId';
        if(ShipmentDate!=null)
            query +=' AND Shipment_Date__c=:ShipmentDate';
        
        query +=' order by createddate DESC limit 500';
        //System.debug('query: '+query);
        ShipList = Database.query(query);
        //System.debug('List size: '+ShipList.size());
        return ShipList;
    }
    
    public static PageReference openAsPdf(){
        list<Shipment__c> SRecords = new list<Shipment__c>();
        List<string> shipmentIdList=( List<string>) JSON.deserialize(shipmentJson,  List<string>.class);
        /*shipmentList=   [Select Id, name, Origin_Address_City__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,
                         Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,
                         Number_of_Packages__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,
                         Shipping_Note_Number__c, Consignee_Name_TMS__c, Destination_Address_Line1__c,
                         Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,
                         Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,BVC_Service__r.Name,
                         Seal_Number__c,
                         (select Bar_Code__c from Secure_Packagings__r Limit 1),
                         (Select Length__c, Height__c, Breadth__c, BVC_Vehicle__c,Name,  BVC_Vehicle__r.Vehicle_Number__c From  Line_Hauls__r LIMIT 1)
                         FROM Shipment__c WHERE Id in:shipmentIdList  order by createddate DESC limit 50000];*/
        for(string s : shipmentIdList)
        {
            Shipment__c s1 = new Shipment__c();
            s1.Id = s;
            s1.PDF_Generation__c = 'Generated';
            SRecords.add(s1);
        }try{
            update SRecords;
        }
        catch(exception e){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error: '+e.getMessage());
            ApexPages.addMessage(errormsg);
            return null;
        }
        System.PageReference pageRef = new System.PageReference('/apex/TMS_ShippingPdfPage?list='+String.join(shipmentIdList, ',')+'&type=post');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    public PageReference GeneratePreShipmentPdf(){
        SelectedLabelList = new List<Secure_Packaging__c>();
        List<string> LabelIdSet = new List<string>();
        for(ShipmentLabelWrapper wr:LabelWrapList){
            if(wr.selected){
                LabelIdSet.add(wr.sp.id);
                SelectedLabelList.add(wr.sp);
            }
        }
        if(LabelIdSet==null || LabelIdSet.size()==0){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Please select at least one row to continue');
            ApexPages.addMessage(errormsg);
            return null;
        }
        if(SelectedLabelList !=null && SelectedLabelList.size()>0){
            for(Secure_Packaging__c sp:SelectedLabelList){
                sp.Status__c='Consumed';
            }
        }
        try{
            update SelectedLabelList;
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'error: '+e.getMessage()));
        }
        System.PageReference pageRef = new System.PageReference('/apex/TMS_PreShipmentPdf?list='+String.join(LabelIdSet, ',')+'&type=pre');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    public class ShipmentLabelWrapper{
        public Secure_Packaging__c sp{get;set;}
        public boolean selected {get;set;}
    }
    
}