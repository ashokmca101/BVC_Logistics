public with sharing class gcTracking {

	public class gcException extends Exception{}

    public class params{

        //these parameters are passed in
        public String   action;        
        public String   barcode;   
        public String   location; //Hub, Port, Out for Delivery
        public Id       hubId;
        public Id       sealId;
        public Id       transportId;

        //these parameters are not passed in, they are only returned
        public list<Secure_Bag__c> bags;
        public Secure_Bag__c bag;
        public Secure_Packaging__c seal;

        params(String strParams){
            map<String,Object> mapParams = new map<String,Object>();
            try{
                mapParams = (Map<String, Object>)JSON.deserializeUntyped(encodingUtil.urlDecode(strParams,'UTF-8'));
            }catch(exception e){}

            for(String key : mapParams.keySet()){
                Object val = mapParams.get(key);
                if(val == null)
                    continue;

                switch on key{
                    when 'action'               {this.action                = (String)val;}
                    when 'barcode'              {this.barcode               = (String)val;}
                    when 'location'             {this.location              = (String)val;}
                    when 'hubId'                {this.hubId                 = (Id)val;}
                    when 'sealId'               {this.sealId                = (Id)val;}
                    when 'transportId'          {this.transportId           = (Id)val;}
                }
            }  
        }
    }

    @AuraEnabled
    public static String process(String strParams, list<Id> listIdBag_scanned){

        try{
            params params = new params(strParams);
            process_local(params, listIdBag_scanned);
            return JSON.serialize(params);
        }
        catch(Exception e){
            if(Test.isRunningTest())
                throw new gcException(e.getMessage());
            else
                throw new AuraHandledException(e.getMessage());
        }
    }

    private static void process_local(params params, list<Id> listIdBag_scanned){

        if(params.action == 'scanSeal'){

            params.seal = retrieveSeal(params.barcode);
            params.bags = retrieveBags(params.seal.Id);

        }else if(params.action == 'scanBag'){

            params.bag = retrieveBag(params.barcode);
            params.bags = retrieveBags(params.bag.Shipment__c);

        }else if(params.action == 'complete'){

            complete(params,listIdBag_scanned);

        }else{

            throw new gcException('Invalid params.action: '+(params.action == null ? 'null' : params.action));

        }
    }

    private static void complete(params params, list<Id> listIdBag_scanned){
        
        Datetime trackingTime = dateTime.now();

        set<Id> setIdBag_scanned = new set<Id>(listIdBag_scanned);

        map<Id,Shipment__c> mapShipment = new map<Id,Shipment__c>();
        map<Id,Shipment_Tracking__c> mapShipTrack = new map<Id,Shipment_Tracking__c>(); //map of ShipmentId to Tracking record
        list<Shipment_Tracking__c> listShipTrack = new list<Shipment_Tracking__c>();

        Id sealId = params.sealId;

        String soql = 'SELECT Id ';
        soql += ', Current_Scan_Airport__c';
        soql += ', Current_Scan_Date_and_Time__c';
        soql += ', Current_Scan_Loction__c';
        soql += ', Current_Scan_Hub__c';
        soql += ', Incorrect_Linehaul_Seal__c';
        soql += ', Is_Misrouted__c';
        soql += ', Seal_Id__c';
        soql += ', Shipment__c';
        soql += ', Shipment__r.Id';
        soql += ', Shipment__r.Destination_Hub__c';
        soql += ', Shipment__r.Origin_Hub__c';
        soql += ', Shipment__r.Tracking_Status__c';
        soql += ' FROM Secure_Bag__c';
        soql += ' WHERE Id IN :setIdBag_scanned';
        if(params.sealId != null)
        soql += ' OR Seal_Id__c = :sealId';

        list<Secure_Bag__c> allBags = Database.query(soql);

        //collect the Shipments that are referenced by the Secure Bags that were scanned
        for(Secure_Bag__c bag : allBags){
            if(setIdBag_scanned.contains(bag.Id)){
                mapShipTrack.put(bag.Shipment__c,null);
                mapShipment.put(bag.Shipment__c,bag.Shipment__r);
            }
        }

        //create and insert one Shipment Tracking record for each Shipment
        for(Id idShipment : mapShipTrack.keySet()){
            
            Shipment__c shipment = mapShipment.get(idShipment);
            
            Shipment_Tracking__c tracking = new Shipment_Tracking__c(
                Hub__c = params.hubId,
                Scan_Time__c = trackingTime,
                Shipment__c = idShipment
            );

            if(params.hubId == shipment.Destination_Hub__c){
                tracking.Location__c = 'Destination Hub';
            }else if(params.hubId == shipment.Origin_Hub__c){
                tracking.Location__c = 'Origin Hub';
            }else{
                tracking.Location__c = 'Transit Hub';
            }

            mapShipTrack.put(idShipment,tracking);
            listShipTrack.add(tracking);
        }

        insert listShipTrack;


        //update the Secure Bags that were scanned
        list<Secure_Bag__c> listBagUpdate = new list<Secure_Bag__c>();

        for(Secure_Bag__c bag : allBags){
            
            if(setIdBag_scanned.contains(bag.Id)){

                //bag.Current_Scan_Airport__c = params.transportId;
                bag.Current_Scan_Date_and_Time__c = trackingTime;
                bag.Current_Scan_Hub__c = params.hubId;
                bag.Is_Misrouted__c = false;
                bag.Tracking__c = mapShipTrack.get(bag.Shipment__c).Id;

                if(params.hubId == bag.Shipment__r.Destination_Hub__c){
                    bag.Current_Scan_Loction__c = 'Destination Hub';
                }else if(params.hubId == bag.Shipment__r.Origin_Hub__c){
                    bag.Current_Scan_Loction__c = 'Origin Hub';
                }else{
                    bag.Current_Scan_Loction__c = 'Transit Hub';
                }

                if(params.sealId != null && params.sealId != bag.Seal_Id__c)
                    bag.Incorrect_Linehaul_Seal__c = true;
                
                listBagUpdate.add(bag);
                    
            }else if(params.sealId != null && params.sealId == bag.Seal_Id__c){
                bag.Is_Misrouted__c = true;
                listBagUpdate.add(bag);
            }else{
                //Do not update this bag.
                //The bag was not scanned, and the bag is not the child of the Seal that was scanned.
                //The bag is just in the same Shipment as a bag that was scanned
            }
        }

        if(!listBagUpdate.isEmpty())
            update listBagUpdate;
        
        //if all of the bags in a Shipment are at the same Current Location,
        //then update the Tracking Status of the Shipment.
        map<Id, list<Secure_Bag__c>> mapShipBags = new map<Id, list<Secure_Bag__c>>();
        list<Shipment__c> listShipUpdate = new list<Shipment__c>();

        for(Secure_Bag__c bag : [
            SELECT Id,
                    Current_Scan_Loction__c,
                    Shipment__c
            FROM Secure_Bag__c 
            WHERE Shipment__c IN :mapShipment.keySet()
        ]){
            list<Secure_Bag__c> listBag = mapShipBags.get(bag.Shipment__c);
            if(listBag == null){
                listBag = new list<Secure_Bag__c>();
                mapShipBags.put(bag.Shipment__c,listBag);
            }
            listBag.add(bag);
        }

        for(Id shipmentId : mapShipBags.keySet()){
            list<Secure_Bag__c> listBag = mapShipBags.get(shipmentId);
            String status;
            Boolean allBagsSameStatus = true;
            for(Secure_Bag__c bag : listBag){
                if(status == null){
                    status = bag.Current_Scan_Loction__c;
                }else if(bag.Current_Scan_Loction__c != status){
                    allBagsSameStatus = false;
                    break;
                }
            }
            if(allBagsSameStatus){
                listShipUpdate.add(new Shipment__c(
                    Id = shipmentId,
                    Tracking_Status__c = status
                ));
            }
        }

        if(!listShipUpdate.isEmpty())
            update listShipUpdate;
    }

    public static Secure_Packaging__c retrieveSeal(String barcode){
        if(barcode == null || barcode.isWhitespace()){
            throw new gcException('The barcode may not be blank.');
        }

        Secure_Packaging__c seal;

        for(Secure_Packaging__c spx : [
            SELECT Id,
                    Name
            FROM Secure_Packaging__c 
            WHERE Name = :barcode 
              AND RecordType.DeveloperName = 'Secure_Seal'
        ]){
            return spx;
        }

        throw new gcException('A Secure Seal having barcode ['+barcode+'] was not found in the database.');
    }

    public static list<Secure_Bag__c> retrieveBags(Id filterId){

        String soql = 'SELECT Id';
        soql += ', Name';
        soql += ', Cargo_Type__c';
        soql += ', Current_Scan_Hub__r.Name';
        soql += ', Current_Origin_City__c';
        soql += ', Current_Destination_City__c';
        soql += ', Destination_Hub__c';
        soql += ', Seal_Id__c';
        soql += ', Seal_Id__r.Id';
        soql += ', Seal_Id__r.Name';
        soql += ', Secure_Bag__c';
        soql += ', Secure_Bag__r.Id';
        soql += ', Secure_Bag__r.Name';
        soql += ', Shipment__c';
        soql += ', Shipment__r.Cargo_Type__c';
        soql += ', Shipment__r.Name';
        soql += ', Shipment__r.Shipping_Note_Number__c'; //SN#
        soql += ' FROM Secure_Bag__c';
        
        if(filterId.getSobjectType() == Secure_Packaging__c.SObjectType){
            soql += ' WHERE Seal_Id__c = :filterId';
        }
        else if(filterId.getSobjectType() == Shipment__c.SObjectType){
            soql += ' WHERE Shipment__c = :filterId';
        }
        else{
            throw new gcException('gcTracking.retrieveBags:  invalid filterId parameter.');
        }
        soql += ' ORDER BY Name';
        soql += ' LIMIT 300';

        return Database.query(soql);
    }

    public static Secure_Bag__c retrieveBag(String barcode){

        if(barcode == null || barcode.isWhitespace())
            throw new gcException('The barcode may not be blank.');

        for(Secure_Bag__c bag : [
            SELECT Id,
                Name,
                Cargo_Type__c,
                Current_Scan_Hub__r.Name,
                Current_Origin_City__c,
                Current_Destination_City__c,
                Destination_Hub__c,
                Seal_Id__c,
                Seal_Id__r.Id,
                Seal_Id__r.Name,
                Secure_Bag__c,
                Secure_Bag__r.Id,
                Secure_Bag__r.Name,
                Shipment__c,
                Shipment__r.Cargo_Type__c,
                Shipment__r.Name,Current_Scan_Loction__c,
                Shipment__r.Shipping_Note_Number__c //SN#
            FROM Secure_Bag__c
            WHERE Secure_Bag__r.Name = :barcode
        ]){
            // added by Imran
            String curUid = userInfo.getUserId();
            List<GroupMember> pgUList = [select Group.Name,UserOrGroupId from GroupMember where Group.Name='TMS Managers' and UserOrGroupId=:curUid];
            
            if(bag.Current_Scan_Loction__c=='Delivered' && pgUList.size()==0)
            {
                throw new gcException('Secure Bag already Delivered. you Have no Right to Edit ');
            }
            else
            {
              return bag; 
            }
		// upto Here
        }
        throw new gcException('A Secure Bag having barcode ['+ barcode + '] was not found in the database.');
    }

    @AuraEnabled
    public static list<Hub__c> retrieveHubs(){
        Id userId = UserInfo.getUserId();

        set<Id> setIdHub = new set<Id>();
        list<Hub__c> listHub = new list<Hub__c>();
        for(FSE_Sales__c hubEmp : [
            SELECT Id,
                    Hub__c,
                    Hub__r.Id,
                    Hub__r.Name,
                    Is_Primary__c 
            FROM FSE_Sales__c
            WHERE Sales_Person__c = :userId 
              AND Type__c = 'Manager'
            ORDER BY Hub__r.Name
        ]){
            if(hubEmp.Hub__c == null || setIdHub.contains(hubEmp.Hub__c)){
                continue;
            }else{
                listHub.add(hubEmp.Hub__r);
                setIdHub.add(hubEmp.Hub__c);
            }
        }

        return listHub;
    }

    @AuraEnabled
    public static list<Transport__c> retrieveTransports(){

        Id userId = UserInfo.getUserId();

        set<Id> setIdTransport = new set<Id>();
        list<Transport__c> listTransport = new list<Transport__c>();
        for(FSE_Sales__c hubEmp : [
            SELECT Id,
                    Hub__r.Airport__c,
                    Hub__r.Airport__r.Id,
                    Hub__r.Airport__r.Name,
                    Is_Primary__c 
            FROM FSE_Sales__c
            WHERE Sales_Person__c = :userId 
              AND Type__c = 'Manager'
            ORDER BY Hub__r.Airport__r.Name
        ]){
            if(hubEmp.Hub__r.Airport__c == null || setIdTransport.contains(hubEmp.Hub__r.Airport__c)){
                continue;
            }else{
                listTransport.add(hubEmp.Hub__r.Airport__r);
                setIdTransport.add(hubEmp.Hub__r.Airport__c);
            }
        }

        return listTransport;
    }

    @AuraEnabled 
    public static Boolean isExecutive(){
        Id profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
        String executiveProfileName = System.Label.ExecutiveProfileName;

        if(profile.Name == executiveProfileName)
            return true;
        else 
            return false;
    }
}