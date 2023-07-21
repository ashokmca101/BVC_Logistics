public class Update_Secure_Packaging {
    public static void updateRelatedSecurePackaging(List<Shipment__c> shipmentList){
       Set<String> secureSet = new Set<String>();
        map<string,Shipment__c> shmap = new map<string,Shipment__c>();
        for(Shipment__c s: shipmentList){
            shmap.put(s.Shipping_Note_Number__c,s);
            secureSet.add(s.Shipping_Note_Number__c);
        }
        List<Secure_Packaging__c> secureList = new List<Secure_Packaging__c>();
        if(secureSet.size()>0 && !secureSet.isEmpty()){
            secureList = [SELECT Id,Name,Shipment__c,Status__c FROM Secure_Packaging__c WHERE Name =: secureSet];
        }
        List<Secure_Packaging__c> securenew = new List<Secure_Packaging__c>();
        
        if(secureList != null && !secureList.isEmpty()){
                for(Secure_Packaging__c sc :secureList){
                        sc.Shipment__c = shmap.get(sc.Name).Id;
                        sc.Status__c = 'Consumed';
                        securenew.add(sc);
                }
        }
        
        if(securenew.size()>0 && !securenew.isEmpty()){
            update securenew;
        }
       
    }
}