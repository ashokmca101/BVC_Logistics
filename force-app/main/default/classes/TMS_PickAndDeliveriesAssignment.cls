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
public class TMS_PickAndDeliveriesAssignment {

    public static Boolean isFirstUpdate = true;  

    @InvocableMethod
    public static void  pickupAssignment(List< Pickup__c> newPickupList ){
        Map<Id, List<Pickup__c>> pickupWithRoute = new Map<Id, List<Pickup__c>>(); 
        Map<Id, List<Pickup__c>> pickupWithHub = new Map<Id, List<Pickup__c>>();
        Map<Id, List<Route_Assignment__c>> addressWithRoute = new Map<Id, List<Route_Assignment__c>>();        
        Map<Id, List<FSE_Sales__c>> addressWithFSESales = new Map<Id, List<FSE_Sales__c>>();
        Map<Id, Pickup__c> updatePickupMap = new Map<Id, Pickup__c>();
        Map<Id, FSE_Sales__c> temprobin_A = new Map<Id, FSE_Sales__c>();
        Map<Id,Route_Assignment__c> temprobin_B =  new Map <Id, Route_Assignment__c>();

        Integer fseCount = 0;
        Integer pickupCount = newPickupList.size();
        List<FSE_Sales__c> routeAssignment_A = new List<FSE_Sales__c>();

        List<Route_Assignment__c> routeAssignment_B =  new List <Route_Assignment__c>();


        for( Pickup__c pickupRecord : newPickupList){
           
            if(pickupRecord.Pickup_Route_Number__c != null){
                if(pickupWithRoute.containsKey(pickupRecord.Pickup_Route_Number__c ) ){
                    pickupWithRoute.get(pickupRecord.Pickup_Route_Number__c).add(pickupRecord);
                }else{
                    pickupWithRoute.put(pickupRecord.Pickup_Route_Number__c, new List<Pickup__c>{pickupRecord});
                } 
            }

            if(pickupRecord.BVC_Origin_Hub__c != null){
                if(pickupWithHub.containsKey(pickupRecord.BVC_Origin_Hub__c ) ){
                    pickupWithHub.get(pickupRecord.BVC_Origin_Hub__c).add(pickupRecord);
                }else{
                    pickupWithHub.put(pickupRecord.BVC_Origin_Hub__c, new List<Pickup__c>{pickupRecord});
                }
            } 
        }

        for( Route_Assignment__c addressrouteAssignment : [
            SELECT Id, Name, Round_Robin__c, Pickup_Delivery_Route__c, Route_Assigned_To__c, Route_Assigned_By__c, Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_1__c,
                Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_2__c,Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_3__c, Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_1__c, 
                Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_2__c,Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_3__c 
            FROM Route_Assignment__c
            WHERE Pickup_Delivery_Route__c IN: pickupWithRoute.keySet() 
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
            for( Pickup__c pickupRecord : newPickupList){
               if(pickupRecord.Pickup_Route_Number__c != null){ 

                    if(addressWithRoute.containsKey(pickupRecord.Pickup_Route_Number__c)){ 
                        
                        routeAssignment_B = addressWithRoute.get(pickupRecord.Pickup_Route_Number__c);
                        routeAssignment_B[fseCount].Round_Robin__c += 1 ;
                        temprobin_B.put(routeAssignment_B[fseCount].Id, routeAssignment_B[fseCount]);

                        Pickup__c temp = new  Pickup__c();
                        temp.id= pickupRecord.Id;
                    
                        
                        temp.Pickup_Assigned_To__c = routeAssignment_B[0].Route_Assigned_To__c;
                        temp.Pickup_Assigned_By__c = routeAssignment_B[0].Route_Assigned_By__c;
                        
                        Datetime created;
                        if(pickupRecord.CreatedDate !=null)
                            created = pickupRecord.CreatedDate;
                        else
                            created = system.now();
                        Datetime fromslot1;
                        Datetime Toslot1;
                        Datetime fromslot2;
                        Datetime Toslot2;
                        Datetime fromslot3;
                        Datetime Toslot3;
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_1__c !=null)
                            fromslot1 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_1__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_1__c !=null)
                            Toslot1 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_1__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_2__c !=null)
                            fromslot2 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_2__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_2__c !=null)
                            Toslot2 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_2__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_3__c !=null)
                            fromslot3 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_From_3__c);
                        if(routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_3__c !=null)
                            Toslot3 = DateTime.newInstance(Date.today(), routeAssignment_B[0].Pickup_Delivery_Route__r.Pickup_Route_Time_Slot_To_3__c);
                        if(fromslot1!= null && Toslot1!=null && created.getTime() >= fromslot1.getTime() && created.getTime() < Toslot1.getTime()){
                            temp.Assigned_Date_and_Time__c = fromslot1;
                        }else if(fromslot2!= null && Toslot2!=null && created.getTime() >= fromslot2.getTime() && created.getTime() < Toslot2.getTime()){
                            temp.Assigned_Date_and_Time__c = fromslot2;
                        }else if(fromslot3!= null && Toslot3!=null && created.getTime() >= fromslot3.getTime() && created.getTime() < Toslot3.getTime()){
                            temp.Assigned_Date_and_Time__c = fromslot3;
                        }else if(fromslot1!=null){
                            temp.Assigned_Date_and_Time__c = fromslot1;
                        }
                        
                        if( fseCount == routeAssignment_B.size() - 1){
                            fseCount = 0;
                        }else{
                            fseCount++;
                        } 
                        updatePickupMap.put(temp.Id,temp);
                    }
               }
            }  
        }else{  

            ////System.debug('============== else addressWithRoute ================');
            if(pickupWithHub.size() > 0){
                for( FSE_Sales__c fseSales : [
                    SELECT Id, Name, Hub__c, Pickup_Route__c, Pickup_Route__r.Pickup_Route_Time__c, Pickup_Route_Assign_To__c, Type__c ,Pickup_Route__r.Pickup_Route_Assigned_By__c,
                    Pickup_Route__r.Pickup_Route_Time_Slot_From_1__c,Round_Robin__c, 
                    Pickup_Route__r.Pickup_Route_Time_Slot_From_2__c, Pickup_Route__r.Pickup_Route_Time_Slot_From_3__c, Pickup_Route__r.Pickup_Route_Time_Slot_To_1__c,
                    Pickup_Route__r.Pickup_Route_Time_Slot_To_2__c, Pickup_Route__r.Pickup_Route_Time_Slot_To_3__c
                    FROM FSE_Sales__c
                    WHERE  Hub__c IN: pickupWithHub.keySet()
                        AND Type__c = 'FSE' 
                    ORDER BY Round_Robin__c ASC NULLS FIRST
                ]){ 

                    if(addressWithFSESales.containsKey(fseSales.Hub__c ) ){
                        addressWithFSESales.get(fseSales.Hub__c).add(fseSales);
                    }else{
                        addressWithFSESales.put(fseSales.Hub__c, new List<FSE_Sales__c>{fseSales});
                    }
                }
                
                if(addressWithFSESales.size() > 0){
                    for( Pickup__c pickupRecord : newPickupList){ // 5 
                        if(pickupRecord.BVC_Origin_Hub__c != null){
                            if(addressWithFSESales.containsKey(pickupRecord.BVC_Origin_Hub__c)){ //3
                                routeAssignment_A = addressWithFSESales.get(pickupRecord.BVC_Origin_Hub__c); 
                                if(routeAssignment_A[fseCount].Round_Robin__c >0){
                                    routeAssignment_A[fseCount].Round_Robin__c += 1 ;
                                }else{
                                    routeAssignment_A[fseCount].Round_Robin__c = 1 ;
                                }
                                
                                temprobin_A.put(routeAssignment_A[fseCount].Id, routeAssignment_A[fseCount]);

                                Pickup__c temp = new Pickup__c();
                                temp.id= pickupRecord.Id;
                                temp.Pickup_Assigned_To__c = routeAssignment_A[fseCount].Pickup_Route_Assign_To__c;
                                temp.Pickup_Assigned_By__c = routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Assigned_By__c;
                                //pickupRecord.Pickup_Time_Slot__c = routeAssignment_A.Pickup_Route__r.Pickup_Route_Time__c;
                                Datetime created;
                                if(pickupRecord.CreatedDate !=null)
                                    created = pickupRecord.CreatedDate;
                                else
                                    created = system.now();
                                Datetime fromslot1;
                                Datetime Toslot1;
                                Datetime fromslot2;
                                Datetime Toslot2;
                                Datetime fromslot3;
                                Datetime Toslot3;
                                
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_1__c !=null)
                                    fromslot1 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_1__c);
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_1__c !=null)
                                    Toslot1 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_1__c);
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_2__c !=null)
                                    fromslot2 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_2__c);
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_2__c !=null)
                                    Toslot2 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_2__c);
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_3__c !=null)
                                    fromslot3 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_From_3__c);
                                if(routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_3__c !=null)
                                    Toslot3 = DateTime.newInstance(Date.today(), routeAssignment_A[fseCount].Pickup_Route__r.Pickup_Route_Time_Slot_To_3__c);
                                if(fromslot1!=null && Toslot1!=null && created.getTime() >= fromslot1.getTime() && created.getTime() < Toslot1.getTime()){
                                    temp.Pickup_Time_Slot__c = fromslot1;
                                }else if(fromslot2!=null && Toslot2!=null && created.getTime() >= fromslot2.getTime() && created.getTime() < Toslot2.getTime()){
                                    temp.Pickup_Time_Slot__c = fromslot2;
                                }else if(fromslot3!=null && Toslot3!=null && created.getTime() >= fromslot3.getTime() && created.getTime() < Toslot3.getTime()){
                                    temp.Pickup_Time_Slot__c = fromslot3;
                                }else if(fromslot1!=null){
                                    temp.Pickup_Time_Slot__c = fromslot1;
                                }

                                if( fseCount == routeAssignment_A.size() - 1){
                                    fseCount = 0;
                                }else{
                                    fseCount++;
                                }
                                
                                updatePickupMap.put(temp.Id, temp); 
                            }
                        } 
                    } 
                } 

            } 
        } 

        if(updatePickupMap != null){  
            Update updatePickupMap.values();
        } 
        if(temprobin_A != null){
            
            Update temprobin_A.values();
        } 

        if(temprobin_B != null){ 
            Update temprobin_B.values();
        } 
    } 
}