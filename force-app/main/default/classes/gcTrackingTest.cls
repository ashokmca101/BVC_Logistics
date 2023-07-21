@IsTest (SeeAllData=TRUE)
private class gcTrackingTest {

    public class gcException extends Exception{}

    @IsTest
    private static void test1(){

        String strParams;

        Hub__c transitHub;
        Secure_Packaging__c seal;
        Shipment__c shipment;
        list<Id> listIdBag_scanned = new list<Id>();

        for(Secure_Bag__c sbx : [
            SELECT Id,
                    Seal_Id__c,
                    Seal_Id__r.Id,
                    Seal_Id__r.Name,
                    Shipment__c,
                    Shipment__r.Id,
                    Shipment__r.Destination_Hub__c,
                    Shipment__r.Origin_Hub__c
            FROM Secure_Bag__c 
            WHERE Seal_Id__c != null 
              AND CreatedDate < TODAY
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]){
            seal = sbx.Seal_Id__r;
            shipment = sbx.Shipment__r;
        }

        list<Secure_Bag__c> listBag = [
            SELECT Id,
                    Name,
                    Secure_Bag__c,
                    Secure_Bag__r.Id,
                    Secure_Bag__r.Name 
            FROM Secure_Bag__c 
            WHERE Seal_Id__c = :seal.Id 
            LIMIT 10
        ];

        for(Hub__c hubx : [
            SELECT Id 
            FROM Hub__c 
            WHERE Id != :shipment.Destination_Hub__c 
              AND Id != :shipment.Origin_Hub__c 
            LIMIT 1
        ]){
            transitHub = hubx;
        }

        Test.startTest();

        //scan seal
        strParams = '';
        strParams += '{';
        strParams += '"action":"scanSeal",';
        strParams += '"barcode":"'+seal.Name+'",';
        strParams += '"location":"Hub",';
        strParams += '"hubId":"'+shipment.Destination_Hub__c+'",';
        //strParams += '"sealId":"'+seal.Id+'",';
        //strParams += '"transportId":"",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,listIdBag_scanned);
        }catch(exception e){}

        //scan bag (unlock seal)
        strParams = '';
        strParams += '{';
        strParams += '"action":"scanBag",';
        strParams += '"barcode":"'+listBag[0].Secure_Bag__r.Name+'",';
        strParams += '"location":"Hub",';
        strParams += '"hubId":"'+shipment.Destination_Hub__c+'",';
        strParams += '"sealId":"'+seal.Id+'",';
        //strParams += '"transportId":"",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,listIdBag_scanned);
        }catch(exception e){}

        listIdBag_scanned.add(listBag[0].Id);

        //complete (unlock seal - destination)
        strParams = '';
        strParams += '{';
        strParams += '"action":"complete",';
        //strParams += '"barcode":"'+listBag[0].Secure_Bag__r.Name+'",';
        strParams += '"location":"Hub",';
        strParams += '"hubId":"'+shipment.Destination_Hub__c+'",';
        strParams += '"sealId":"'+seal.Id+'",';
        //strParams += '"transportId":"",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,listIdBag_scanned);
        }catch(exception e){}        

        //complete (unlock seal - origin)
        listIdBag_scanned.add(listBag[0].Id);
        strParams = '';
        strParams += '{';
        strParams += '"action":"complete",';
        //strParams += '"barcode":"'+listBag[0].Secure_Bag__r.Name+'",';
        strParams += '"location":"Hub",';
        strParams += '"hubId":"'+shipment.Origin_Hub__c+'",';
        strParams += '"sealId":"'+seal.Id+'",';
        //strParams += '"transportId":"",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,listIdBag_scanned);
        }catch(exception e){} 

        //complete (unlock seal - transit)
        listIdBag_scanned.add(listBag[0].Id);
        strParams = '';
        strParams += '{';
        strParams += '"action":"complete",';
        //strParams += '"barcode":"'+listBag[0].Secure_Bag__r.Name+'",';
        strParams += '"location":"Hub",';
        strParams += '"hubId":"'+transitHub.Id+'",';
        strParams += '"sealId":"'+seal.Id+'",';
        //strParams += '"transportId":"",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,listIdBag_scanned);
        }catch(exception e){} 

    }

    @IsTest
    private static void test2(){
        
        gcTracking.retrieveHubs();
        gcTracking.retrieveTransports();
        gcTracking.isExecutive();

    }

    @IsTest
    private static void test3(){

        //invalid action
        String strParams = '';
        strParams += '{';
        strParams += '"action":"invalidAction",';
        strParams += '"fakeParam":""';
        strParams += '}';
        try{
            gcTracking.process(strParams,new list<Id>());
        }catch(exception e){}

        //blank seal barcode
        try{
            gcTracking.retrieveSeal(null);
        }catch(exception e){}

        //invalid seal barcode
        try{
            gcTracking.retrieveSeal(String.valueOf(Integer.valueOf(1000000*math.random())));
        }catch(exception e){}

        //blank bag barcode
        try{
            gcTracking.retrieveBag(null);
        }catch(exception e){}

        //invalid bag barcode
        try{
            gcTracking.retrieveBag(String.valueOf(Integer.valueOf(1000000*math.random())));
        }catch(exception e){}        
    }
}