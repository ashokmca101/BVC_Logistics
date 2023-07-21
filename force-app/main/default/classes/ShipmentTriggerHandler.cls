public class ShipmentTriggerHandler {
    /*
    Public static Void UpdateShipmentShipper(List<Shipment__c> newShipment) {
        Id PortalUserAccountId=Utility.getCommunityUserAccountId();
        Map<Id,String> ShipmentIdWithShipperName=new  Map<Id,String>();
        Id shipperaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping Account Community').getRecordTypeId();
        Map<Id,String> ShipmentIdWithShipperEmailId=new  Map<Id,String>();
        Set<String> NewShipperNameSet=new Set<String>();
        Set<String> NewShipperEmailSet=new Set<String>();
        Map<String,Id> ShipperNameWithAccountId=new  Map<String,Id>();
        Map<String,Id> ShipperEmailIdWithAccountId=new  Map<String,Id>();
        //Fetch shipper details from new shipment
        for(Shipment__c ship:newShipment) {
            ShipmentIdWithShipperName.put(ship.Id, ship.Shipper__c);
            ShipmentIdWithShipperEmailId.put(ship.Id, ship.Shipper_Email_ID__c);
            NewShipperNameSet.add(ship.Shipper__c);
            NewShipperEmailSet.add(ship.Shipper_Email_ID__c);
        }
        //Query shipper Account from new shipment data
        List<Account> shipperAccount=new List<Account>();
        Map<String,String> NoShippershipperemailwithshippername=new Map<String,String>();
        If(NewShipperEmailSet!=null && NewShipperNameSet!=null){
            shipperAccount=[Select id,Name,Primary_Customer_Email__c from Account where Primary_Customer_Email__c IN:NewShipperEmailSet AND Name IN:NewShipperNameSet AND Recordtypeid=:shipperaccountRecordTypeId AND ParentId=:PortalUserAccountId];
        }
        system.debug('shipperAccount'+shipperAccount);
        Boolean Found;
        List<Account> newAccountlist=new List<Account>();
        If(shipperAccount.size()>0){
            for(Shipment__c ship:newShipment){
                Found=False;
                for(Account acc:shipperAccount){
                    //Existing Shipper found Map to shipment lookup.
                    if(acc.Name==ship.shipper__c && acc.Primary_Customer_Email__c==ship.Shipper_Email_ID__c){
                        ship.Ship_To__c=acc.id;
                        Found=True;
                    }
                }
                If(Found==False){
                    //Existing Shipper Not Found Map of email and shipper name. To avoid duplicacy of shipper account creation.
                    if(ship.shipper__c!=null && ship.Shipper_Email_ID__c!=null){
                        NoShippershipperemailwithshippername.put(ship.Shipper_Email_ID__c,ship.Shipper__c);
                    }
                }
            }
        }
        else{
            for(Shipment__c ship:newShipment){
                if(ship.shipper__c!=null && ship.Shipper_Email_ID__c!=null){
                    NoShippershipperemailwithshippername.put(ship.Shipper_Email_ID__c,ship.Shipper__c);
                }
            }
        }
        system.debug('NoShippershipperemailwithshippername'+NoShippershipperemailwithshippername);
        for(String str:NoShippershipperemailwithshippername.keyset()){
            Account newacc=new Account();
            newacc.Name=NoShippershipperemailwithshippername.get(str);
            newacc.Primary_Customer_Email__c=str;
            newacc.RecordTypeId=shipperaccountRecordTypeId;
            newacc.ParentId=Utility.getCommunityUserAccountId();
            newAccountlist.add(newacc); 
        }
        insert newAccountlist;
        For(Shipment__c ship:newShipment){
            if(ship.Ship_To__c==null && ship.shipper__c!=null && ship.Shipper_Email_ID__c!=null){
                for(Account acc:newAccountlist){
                    if(acc.Name==ship.shipper__c && acc.Primary_Customer_Email__c==ship.Shipper_Email_ID__c){
                        ship.Ship_To__c=acc.id;
                    }
                }
            }
        }
        
    }
   /* 
    Public static Void UpdateShipmentConsignee(List<Shipment__c> newShipment) {
        Id PortalUserAccountId=Utility.getCommunityUserAccountId();
        Id shipperaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping Account Community').getRecordTypeId();
        Map<Id,String> ShipmentIdWithConsigneeName=new  Map<Id,String>();
        Map<Id,String> ShipmentIdWithConsigneeEmailId=new  Map<Id,String>();
        Set<String> NewConsigneeNameSet=new Set<String>();
        Set<String> NewConsigneeEmailSet=new Set<String>();
        Map<String,Id> ConsigneeNameWithAccountId=new  Map<String,Id>();
        Map<String,Id> ConsigneeEmailIdWithAccountId=new  Map<String,Id>();
        //Fetch Consignee details from new shipment
        for(Shipment__c ship:newShipment) {
            ShipmentIdWithConsigneeName.put(ship.Id, ship.Consignee_Name__c);
            ShipmentIdWithConsigneeEmailId.put(ship.Id, ship.Consignee_Email_ID__c);
            NewConsigneeNameSet.add(ship.Consignee_Name__c);
            NewConsigneeEmailSet.add(ship.Consignee_Email_ID__c);
        }
        //Query onsignee Account from new shipment data
        List<Account> consigneeAccount=new List<Account>();
        Map<String,String> NoConsigneeConsigneeemailwithConsigneename=new Map<String,String>();
        If(NewConsigneeNameSet!=null && NewConsigneeEmailSet!=null){
            consigneeAccount=[Select id,Name,Primary_Customer_Email__c from Account where Primary_Customer_Email__c IN:NewConsigneeEmailSet AND Name IN:NewConsigneeNameSet AND RecordtypeId=:shipperaccountRecordTypeId AND ParentId=:PortalUserAccountId];
        }
        Boolean Found;
        List<Account> newAccountlist=new List<Account>();
        If(consigneeAccount.size()>0){
            for(Shipment__c ship:newShipment){
                Found=False;
                for(Account acc:consigneeAccount){
                    //Existing Consignee found Map to shipment lookup.
                    if(acc.Name==ship.Consignee_Name__c && acc.Primary_Customer_Email__c==ship.Consignee_Email_ID__c){
                        ship.Community_Consignee_Account__c=acc.id;
                        Found=True;
                    }
                }
                If(Found==False){
                    //Existing Shipper Not Found Map of email and shipper name. To avoid duplicacy of shipper account creation.
                    if(ship.Consignee_Name__c!=null && ship.Consignee_Email_ID__c!=null){
                        NoConsigneeConsigneeemailwithConsigneename.put(ship.Consignee_Email_ID__c,ship.Consignee_Name__c);
                    }
                }
            }
        }
        else{
            for(Shipment__c ship:newShipment){
                if(ship.Consignee_Name__c!=null && ship.Consignee_Email_ID__c!=null){
                    NoConsigneeConsigneeemailwithConsigneename.put(ship.Consignee_Email_ID__c,ship.Consignee_Name__c);
                }
            }
            
        }
        for(String str:NoConsigneeConsigneeemailwithConsigneename.keyset()){
            Account newacc=new Account();
            newacc.Name=NoConsigneeConsigneeemailwithConsigneename.get(str);
            newacc.Primary_Customer_Email__c=str;
            newacc.RecordTypeId=shipperaccountRecordTypeId;
            newacc.ParentId=Utility.getCommunityUserAccountId();
            newAccountlist.add(newacc); 
        }
        insert newAccountlist;
        For(Shipment__c ship:newShipment){
            if(ship.Community_Consignee_Account__c==null && ship.Consignee_Name__c!=null && ship.Consignee_Email_ID__c!=null){
                for(Account acc:newAccountlist){
                    if(acc.Name==ship.Consignee_Name__c && acc.Primary_Customer_Email__c==ship.Consignee_Email_ID__c){
                        ship.Community_Consignee_Account__c=acc.id;
                    }
                }
            }
        }
        
    }
    */
    public static void updateShipmentLotCheckbox(List<Shipment__c> newShipment){
        Set<Id> shipLotId = new Set<Id>();
        List<Shipment_Lot__c> shipmentLotToUpdate  = new List<Shipment_Lot__c>();
        Boolean shortURLPresent = true;
        for(Shipment__c shipObj : newShipment){
            shipLotId.add(shipObj.Shipment_Lot__c);
        }
        List<Shipment_Lot__c> lstShipLot =[SELECT Id,Name,(SELECT Id,Name,Short_URL__c,Shipment_Lot__c FROM Shipments__r) FROM Shipment_Lot__c WHERE id IN :shipLotId];
        
        for(Shipment_Lot__c shipLotObj : lstShipLot){
            shortURLPresent = true;
            for(Shipment__c shipObj : shipLotObj.Shipments__r){
                if(shipObj.Short_URL__c == null){
                    shortURLPresent = false;
                }
            }  
            if(shortURLPresent){
                Shipment_Lot__c lot= new Shipment_Lot__c(Id = shipLotObj.Id,Amount_Calculated_For_All_Shipment__c = true);
                shipmentLotToUpdate.add(lot);
            }else{
                Shipment_Lot__c lot= new Shipment_Lot__c(Id = shipLotObj.Id,Amount_Calculated_For_All_Shipment__c = false);
                shipmentLotToUpdate.add(lot);
            }
        }
        update shipmentLotToUpdate;
    }
    /*
    public static void updateShipmentBillTo(List<Shipment__c> newShipment){
        Id PortalUserAccountId=Utility.getCommunityUserAccountId();
        Id BillingaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id ParentaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Set<String> PanNumberSet=new Set<String>();
        Set<String> BillToPinSet=new Set<String>();
        Set<String> BillingEntityNameSet=new Set<String>();
        //Extract all pan number of entity
        for(Shipment__c ship:newShipment){
            PanNumberSet.add(ship.Bill_To_Party_PAN__c); 
            BillToPinSet.add(ship.Bill_To_Party_Pincode__c);
            BillingEntityNameSet.add(Ship.Billing_Entity_Name__c);
        }
        List<Account> ParentAccountBasedOnPANList=new List<Account>();
        List<Account> ChildAccountBasedOnBillingPincodeAndEntityName=new List<Account>();
        MAP<ID,STRING> MAPofACCOUNTIDandPAN=new MAP<ID,STRING>();
        MAP<ID,STRING> MAPofParentACCOUNTIDandPIN=new MAP<ID,STRING>();
        MAP<ID,STRING> MAPofParentACCOUNTIDandEntityName=new MAP<ID,STRING>();
        MAP<ID,ID> MAPofParentACCOUNTIDandAccountId=new MAP<ID,ID>();
        if(PanNumberSet.size()>0){
            ParentAccountBasedOnPANList=[Select id,PAN_Number_of_Entity__c from Account where PAN_Number_of_Entity__c IN :PanNumberSet/* AND RecordTypeId=:ParentaccountRecordTypeId*/ /*];
       /*     ChildAccountBasedOnBillingPincodeAndEntityName=[Select id,ParentId,BillingPostalCode,Name_As_Per_PAN_Manual_Input__c from Account where Name_As_Per_PAN_Manual_Input__c IN:BillingEntityNameSet AND BillingPostalCode IN :BillToPinSet AND RecordtypeId=:BillingaccountRecordTypeId AND ParentId=:PortalUserAccountId];
        }
        For(Account acc:ParentAccountBasedOnPANList){
            MAPofACCOUNTIDandPAN.put(acc.id,acc.PAN_Number_of_Entity__c); 
        }
        For(Account acc:ChildAccountBasedOnBillingPincodeAndEntityName){
            MAPofParentACCOUNTIDandPIN.put(acc.ParentId,acc.BillingPostalCode);
            MAPofParentACCOUNTIDandEntityName.put(acc.ParentId,acc.Name_As_Per_PAN_Manual_Input__c);
            MAPofParentACCOUNTIDandAccountId.put(acc.ParentId,acc.Id);
        }
        Boolean Found;
        List<Account> NewlycreatedAccount=new List<Account>();
        For(Shipment__c ship:newShipment){
            Found=False;
            for(Account acc:ParentAccountBasedOnPANList){
                if(ship.Bill_To_Party_PAN__c==acc.PAN_Number_of_Entity__c){
                    if(ship.Bill_To_Party_Pincode__c==MAPofParentACCOUNTIDandPIN.get(acc.Id) && ship.Billing_Entity_Name__c==MAPofParentACCOUNTIDandEntityName.get(acc.Id)){
                        ship.Bill_To__c=MAPofParentACCOUNTIDandAccountId.get(acc.Id);
                        Found=True;
                    } 
                } 
            }
            /*IF(Found==False && ship.Bill_To_Party_Pincode__c!=null && ship.Billing_Entity_Name__c!=null ){

}*//*
        }
        
    }*/
    public static void setPayer(List<Shipment__c> newShipmentList){
        Id communityRecrodTypeId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Community Shipment').getRecordTypeId();
        Id operationRecrodTypeId = Schema.SObjectType.Shipment__c.getRecordTypeInfosByName().get('Operations Shipment').getRecordTypeId();
        for(Shipment__c shipment:newShipmentList){
            if(shipment.RecordTypeId== communityRecrodTypeId ){
                if(shipment.Bill_to_1__c == 'Shipper'){
                    shipment.Payer__c =  shipment.Ship_To__c;
                } else if(shipment.Bill_to_1__c == 'Consignee'){
                    shipment.Payer__c =   shipment.Community_Consignee_Account__c;
                }
            }
            else if(shipment.RecordTypeId== operationRecrodTypeId){
                if(shipment.Bill_to_1__c == 'Shipper'){
                    shipment.Payer__c =   shipment.Shipper_Name_TMS__c;
                } else if(shipment.Bill_to_1__c == 'Consignee'){
                    shipment.Payer__c =   shipment.Consignee_Name_TMS__c;
                }
            }
        }
    }
     public static void cannotDeleteShipment(List<Shipment__c> ShipList){
        for(shipment__c ship12: ShipList){
            if(ship12.Status__c=='ACR Consumed' ||ship12.Status__c=='Picked for Billing' ||ship12.Status__c=='Billed' ||ship12.Status__c=='Verified For Billing' ){
               ship12.addError('You cannot delete this shipment. Please Contact Billing team'); 
            	}
            }
        }
    }