trigger ShipmentTriggerBVC on Shipment__c (Before Update,Before Insert,After insert,after update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        for ( Shipment__c shipment: Trigger.new ){ 
            if(shipment.Verified_for_Billing__c==true && trigger.oldmap.get(shipment.Id).Verified_for_Billing__c == false && shipment.Verified_for_Billling__c!='Yes'){
               if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                   Shipment.Verified_for_Billling__c='No';    
                } 
            }
       } 
    }
     if(Trigger.isAfter && Trigger.isUpdate){ 
         set<id> shipid = new set<id>();
         Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>();
         for(Shipment__c shipment1: Trigger.new){ 
         if(shipment1.Quick_Calculate_Shipment__c == true){
              shipid.add(shipment1.id);
            }  
         }
         if(shipid.size()>0){
            ShipmentTriggerBVCHelper.updateQuote(shipid);
         }
         for ( Shipment__c shipment: Trigger.new ){ 
            if ( shipment.Verified_for_Billing__c != Trigger.oldMap.get( shipment.Id ).Verified_for_Billing__c){
                if(shipment.Verified_for_Billing__c==true && Shipment.Verified_for_Billling__c=='No'){
                    if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                        //shipment trigger when check box 'true' to create Quote and order records
                        //ShipmentTriggerBVCHelper.createOrder(trigger.new);
                        ShipmentTriggerBVCHelper.createOrderNew(trigger.new);
                    } 
                }
            }
             if(shipment.Shipment_Type__c != Trigger.oldMap.get( shipment.Id ).Shipment_Type__c ||
                shipment.Product_Category__c != Trigger.oldMap.get( shipment.Id ).Product_Category__c ||
                shipment.Gross_Weight__c != Trigger.oldMap.get( shipment.Id ).Gross_Weight__c ||
                shipment.Total_Invoice_Value__c != Trigger.oldMap.get( shipment.Id ).Total_Invoice_Value__c ||
                shipment.Visit_Outcome__c != Trigger.oldMap.get( shipment.Id ).Visit_Outcome__c ||
                shipment.Customer__c != Trigger.oldMap.get( shipment.Id ).Customer__c ||
                shipment.No_Of_Attempts__c!= Trigger.oldMap.get( shipment.Id ).No_Of_Attempts__c ||
                shipment.Net_Weight__c!= Trigger.oldMap.get( shipment.Id ).Net_Weight__c ){
                    
                 if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){                     
                     ShipmentTriggerBVCHelper.deleteOldQuote(trigger.new);    
                     ShipmentTriggerBVCHelper.insertRecord(trigger.new);
                     //shipment.adderror('Only a single people on a deal can be an Authorised Signatory');
                 }  
             }
             if(shipment.Ready_for_Rebilling__c != Trigger.oldMap.get( shipment.Id ).Ready_for_Rebilling__c && shipment.Ready_for_Rebilling__c==true){
                 if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                     ShipmentTriggerBVCHelper.rebillingOrder(trigger.new);
                 }  
             }
         }     
    }
    if(Trigger.isAfter && Trigger.isInsert){
        for ( Shipment__c shipment: Trigger.new ){
            if(shipment.Is_Uploaded__c==false){
                if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                    ShipmentTriggerBVCHelper.insertRecord(trigger.new);    
                }  
            } 
        }
    }
    if(Trigger.isBefore && Trigger.isInsert){
        String Uid = UserInfo.getUserId();
        User Usr = [select id,Name,International_Billing_Branch__c,BATH_eSHIP_Billing_Branch__c from User where Id=:Uid];
        List<Hub__c> BVCbranchBatheShip = [select id,Billing_Entity_Name__c,Name from Hub__c where Name=:Usr.BATH_eSHIP_Billing_Branch__c];
        for ( Shipment__c shipment: Trigger.new ){
            if(shipment.Is_Uploaded__c==false){
                if(shipment.Customer_Product_Category__c=='eSHIP' || shipment.Customer_Product_Category__c=='BATH'){
                    if(BVCbranchBatheShip.size()>0){
                         if(BVCbranchBatheShip[0].Billing_Entity_Name__c!=null){
                            Shipment.Status__c='Pending Billing';
                            Shipment.Bill_To_Account__c=shipment.Customer__c;
                            Shipment.Billing_Entity_Name_TMS__c=BVCbranchBatheShip[0].Billing_Entity_Name__c;
                        }
                    } 
                }  
            } 
        }
    }
}