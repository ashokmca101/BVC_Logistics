/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-01-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class TMS_ShipmentAssignment {

    public static Boolean isFirstUpdate = true;   

    @InvocableMethod
    public static void  shipmentAssignment(List< Shipment__c> newShipmentList ){
        try{
		////System.debug('======= shipmentAssignment ==== '+newShipmentList.size());
        Map<Id, List<Shipment__c>> shipmentWithRoute = new Map<Id, List<Shipment__c>>(); 

        Map<Id, List<Shipment__c>> shipmentWithHub = new Map<Id, List<Shipment__c>>();

        Map<Id, List<Route_Assignment__c>> addressWithRoute = new Map<Id, List<Route_Assignment__c>>();
        
        Map<Id, List<FSE_Sales__c>> addressWithFSESales = new Map<Id, List<FSE_Sales__c>>();
         
        Map<Id, Shipment__c> updateShipmentMap = new Map<Id, Shipment__c>();
        Map<Id,FSE_Sales__c> temprobin_A = new Map<Id,FSE_Sales__c>();
        Map<Id, Route_Assignment__c> temprobin_B =  new Map <Id, Route_Assignment__c>();

        Integer fseCount = 0;
        Integer shipmentCount = newShipmentList.size();
        List<FSE_Sales__c> routeAssignment_A = new List<FSE_Sales__c>();

        List<Route_Assignment__c> routeAssignment_B =  new List <Route_Assignment__c>();


        for( Shipment__c shipmentRecord : newShipmentList){

            if(shipmentRecord.Delivery_Route_Number__c != null){
                if(shipmentWithRoute.containsKey(shipmentRecord.Delivery_Route_Number__c ) ){
                    shipmentWithRoute.get(shipmentRecord.Delivery_Route_Number__c).add(shipmentRecord);
                }else{
                    shipmentWithRoute.put(shipmentRecord.Delivery_Route_Number__c, new List<Shipment__c>{shipmentRecord});
                } 
            }

            if(shipmentRecord.Destination_Hub__c != null){
                if(shipmentWithHub.containsKey(shipmentRecord.Destination_Hub__c ) ){
                    shipmentWithHub.get(shipmentRecord.Destination_Hub__c).add(shipmentRecord);
                }else{
                    shipmentWithHub.put(shipmentRecord.Destination_Hub__c, new List<Shipment__c>{shipmentRecord});
                }
            } 
        } 


        for( Route_Assignment__c addressrouteAssignment : [
            SELECT Id, Name, Round_Robin__c, Pickup_Delivery_Route__c, Route_Assigned_To__c, Route_Assigned_By__c, Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c,
                Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c,Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c, Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c, 
                Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c,Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c 
            FROM Route_Assignment__c
            WHERE Pickup_Delivery_Route__c IN: shipmentWithRoute.keySet() 
            ORDER BY Round_Robin__c ASC ]){

            if(addressWithRoute.containsKey(addressrouteAssignment.Pickup_Delivery_Route__c ) ){
                addressWithRoute.get(addressrouteAssignment.Pickup_Delivery_Route__c).add(addressrouteAssignment);
            }else{
                addressWithRoute.put(addressrouteAssignment.Pickup_Delivery_Route__c, new List<Route_Assignment__c>{addressrouteAssignment});
            }
        }

        ////System.debug('========== addressWithRoute ==================='+addressWithRoute);

        Boolean flag = false;
        if(addressWithRoute.size() > 0){
            ////System.debug('============== If addressWithRoute ================');
            for( Shipment__c shipmentRecord : newShipmentList){
               if(shipmentRecord.Delivery_Route_Number__c != null){ 

                    if(addressWithRoute.containsKey(shipmentRecord.Delivery_Route_Number__c)){ 
                        
                        routeAssignment_B = addressWithRoute.get(shipmentRecord.Delivery_Route_Number__c);
                        routeAssignment_B[fseCount].Round_Robin__c += 1 ;
                        temprobin_B.put(routeAssignment_B[fseCount].Id,routeAssignment_B[fseCount]);

                        Shipment__c temp = new  Shipment__c();
                        temp.id= shipmentRecord.Id;
                    
                        
                        temp.Delivery_Route_Assigned_To__c = routeAssignment_B[0].Route_Assigned_To__c;
                        temp.Delivery_Route_Assigned_BY__c = routeAssignment_B[0].Route_Assigned_By__c;
                        
                        Datetime created;
                        if(shipmentRecord.CreatedDate !=null)
                            created = shipmentRecord.CreatedDate;
                        else
                            created = system.now();
                        Datetime fromslot1;
                        Datetime Toslot1;
                        Datetime fromslot2;
                        Datetime Toslot2;
                        Datetime fromslot3;
                        Datetime Toslot3;
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c !=null)
                            fromslot1 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c !=null)
                            Toslot1 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c !=null)
                            fromslot2 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c !=null)
                            Toslot2 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c !=null)
                            fromslot3 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c !=null)
                            Toslot3 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c);
                        if(fromslot1!= null && Toslot1!=null && created.getTime() >= fromslot1.getTime() && created.getTime() < Toslot1.getTime()){
                            temp.Delivery_Time_Date__c = fromslot1;
                        }else if(fromslot2!= null && Toslot2!=null && created.getTime() >= fromslot2.getTime() && created.getTime() < Toslot2.getTime()){
                            temp.Delivery_Time_Date__c = fromslot2;
                        }else if(fromslot3!= null && Toslot3!=null && created.getTime() >= fromslot3.getTime() && created.getTime() < Toslot3.getTime()){
                            temp.Delivery_Time_Date__c = fromslot3;
                        }else if(fromslot1!=null){
                            temp.Delivery_Time_Date__c = fromslot1;
                        }
                        
                        if( fseCount == routeAssignment_B.size() - 1){
                            fseCount = 0;
                        }else{
                            fseCount++;
                        } 
                        updateShipmentMap.put(temp.Id, temp);
                    }
               }
            }  
        }else{ 
            ////System.debug('============== else addressWithRoute ================'+shipmentWithHub);
            if(shipmentWithHub.size() > 0){
                for( FSE_Sales__c fseSales : [
                    SELECT Id, Name, Hub__c, Pickup_Route__c, Delivery_Route__r.Delivery_Route_Time__c, Delivery_Route_Assigned_To__c, Type__c ,Delivery_Route__r.Delivery_Route_Assigned_By__c,
                    Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c,Round_Robin__c,
                    Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c, Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c, Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c,
                    Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c, Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c
                    FROM FSE_Sales__c
                    WHERE  Hub__c IN: shipmentWithHub.keySet()
                    AND Type__c = 'FSE'
                        /*AND Delivery_Route__c != null*/
                    ORDER BY Round_Robin__c ASC NULLS FIRST
                ]){ 

                    if(addressWithFSESales.containsKey(fseSales.Hub__c ) ){
                        addressWithFSESales.get(fseSales.Hub__c).add(fseSales);
                    }else{
                        addressWithFSESales.put(fseSales.Hub__c, new List<FSE_Sales__c>{fseSales});
                    }
                }

                if(addressWithFSESales.size() > 0){
                    for( Shipment__c shipmentRecord : newShipmentList){
                        if(shipmentRecord.Destination_Hub__c != null){
                            //if(shipmentRecord.Shipment_Stage__c=='Received at Destination'){
                                if(addressWithFSESales.containsKey(shipmentRecord.Destination_Hub__c)){
                                    
                                    routeAssignment_A = addressWithFSESales.get(shipmentRecord.Destination_Hub__c);
                                    if(routeAssignment_A.size() > 0){
                                        if(routeAssignment_A[fseCount].Round_Robin__c != null){
                                            routeAssignment_A[fseCount].Round_Robin__c += 1 ;
                                        }else{
                                            routeAssignment_A[fseCount].Round_Robin__c = 1 ;
                                        }
                                        temprobin_A.put(routeAssignment_A[fseCount].Id,routeAssignment_A[fseCount]);
                                    }
                                    
                                    Shipment__c temp = new  Shipment__c();
                                    temp.id= shipmentRecord.Id;
                                    
                                    temp.Delivery_Route_Assigned_To__c = routeAssignment_A[fseCount].Delivery_Route_Assigned_To__c;
                                    temp.Delivery_Route_Assigned_BY__c = routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Assigned_By__c;
                                    //shipmentRecord.Delivery_Time_Date__c = routeAssignment_A.Delivery_Route__r.Delivery_Route_Time__c;
                                    Datetime created;
                                    if(shipmentRecord.CreatedDate !=null)
                                        created = shipmentRecord.CreatedDate;
                                    else
                                        created = system.now();
                                    Datetime fromslot1;
                                    Datetime Toslot1;
                                    Datetime fromslot2;
                                    Datetime Toslot2;
                                    Datetime fromslot3;
                                    Datetime Toslot3;
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c !=null)
                                        fromslot1 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_1__c);
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c !=null)
                                        Toslot1 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_1__c);
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c !=null)
                                        fromslot2 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_2__c);
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c !=null)
                                        Toslot2 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_2__c);
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c !=null)
                                        fromslot3 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_From_3__c);
                                    if(routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c !=null)
                                        Toslot3 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Delivery_Route__r.Delivery_Route_Time_Slot_To_3__c);
                                    if(fromslot1!= null && Toslot1!=null && created.getTime() >= fromslot1.getTime() && created.getTime() < Toslot1.getTime()){
                                        temp.Delivery_Time_Date__c = fromslot1;
                                    }else if(fromslot2!= null && Toslot2!=null && created.getTime() >= fromslot2.getTime() && created.getTime() < Toslot2.getTime()){
                                        temp.Delivery_Time_Date__c = fromslot2;
                                    }else if(fromslot3!= null && Toslot3!=null && created.getTime() >= fromslot3.getTime() && created.getTime() < Toslot3.getTime()){
                                        temp.Delivery_Time_Date__c = fromslot3;
                                    }else if(fromslot1!=null){
                                        temp.Delivery_Time_Date__c = fromslot1;
                                    }
                                    if( fseCount == routeAssignment_A.size() - 1){
                                        fseCount = 0;
                                    }else{
                                        fseCount++;
                                    } 
                                    ////System.debug('======= Temp ======'+temp);
                                    updateShipmentMap.put(temp.Id, temp); 
                                } 
                            //} 
                        } 
                    } 
                } 
            } 
        }

        ////System.debug('==updateShipmentMap.size()======='+updateShipmentMap.size());
        if(updateShipmentMap != null){ 
            Update updateShipmentMap.values();
        }
 

        if(temprobin_A != null){  
            Update temprobin_A.values();
        } 

        if(temprobin_B != null){  
            Update temprobin_B.values();
        } 
        }catch(exception e){
            ////System.debug('line: '+e.getLineNumber());
            ////System.debug('err: '+e.getMessage());
        }
    }
}