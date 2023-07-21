/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Written by :=Chandrakanth(ValueText)

Description:-it handle the creation of pickup and address from bot answers
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/




public class BVC_botFormTriggerHandler {
    public static boolean stoprecru=false;
    // checking when message came and related-to is account or not
    public static void relatedsetup(list<rsplus__Bot_Form__c> bflist){
        if(stoprecru==false){
            set<string> AccountIDs = new  set<string>();
            set<string> NumbersNotAccount = new  set<string>();
            Map<id,string> pannumberVSac = new  Map<id,string>();
            list<rsplus__Bot_Form__c> filterlist = new  list<rsplus__Bot_Form__c>();
            list<rsplus__Bot_Form__c> updatelistbf = new  list<rsplus__Bot_Form__c>();
            map<id,string> messagebktmap = new map<id,string>();
            
            /************** When Bot is first updating mapping related-to id(if related not there finding account from contacts object based number),
shpping and billing account ************************************************************************************************/
            
            
            for(rsplus__Bot_Form__c b :bflist){
                system.debug('1 '+b.rsplus__Related_To__c + ' two '+b.rsplus__To__c);
                if(string.isNotBlank(b.rsplus__Related_To__c) && b.Shipping_Customer_ID__c==null && b.Billing_Customer_ID__c==null && b.rsplus__Status__c!='Completed'){
                    String sObjName = Id.valueof(b.rsplus__Related_To__c).getSObjectType().getDescribe().getName();
                    system.debug('sObjName '+sObjName);
                    if(sObjName=='Account' || sObjName=='ACCOUNT' || sObjName=='account'){
                        AccountIDs.add(b.rsplus__Related_To__c);
                        filterlist.add(b); 
                    }else if(string.isNotBlank(b.rsplus__To__c)){
                        NumbersNotAccount.add(b.rsplus__To__c.right(10)); 
                        filterlist.add(b); 
                    }
                    
                }else if(string.isBlank(b.rsplus__Related_To__c) && string.isNotBlank(b.rsplus__To__c) && b.Shipping_Customer_ID__c==null && b.Billing_Customer_ID__c==null && b.rsplus__Status__c!='Completed'){
                    NumbersNotAccount.add(b.rsplus__To__c.right(10));
                    filterlist.add(b); 
                }
            } 
            
            
            
            
           /*** related to is account and cheking if it is shipping or not ***/ 
            system.debug('1 '+NumbersNotAccount + ' two '+AccountIDs);
            set<id> filerAccIds = new  set<id>(); 
            if(!AccountIDs.isEmpty()){
                for(Account a :[select Id,Name,PAN_Number_of_Entity__c from account where id=:AccountIDs and RecordType.Name='Shipping']){
                    filerAccIds.add(a.id);
                    pannumberVSac.put(a.id,a.PAN_Number_of_Entity__c);
                } 
            }
          /*******************************************************************************/

  
           /**** going with number in contact to find account *****************/ 
            map<string,Id> IdVsNumber = new map<string,Id>();
            if(!NumbersNotAccount.isEmpty()){
                for(Contact c :[Select Id,Name,MobilePhone,Phone,AccountId From Contact Where MobilePhone=:NumbersNotAccount]){
                  if(c.AccountId!=null) 
                 IdVsNumber.put('91'+c.MobilePhone,c.AccountId);  
                }
            }
           /*******************************************************************************/

          /******* may be account finded from the contact is billing or shipping accounts,addding to set and map*************/
            system.debug('1111 '+IdVsNumber);
           Map<string,id> filerAccIdsTwo = new  Map<string,id>();//shipping accounts
            Map<string,id> filerAccIdsThree = new  Map<string,id>();//billing accounts
             Map<string,id> filerAccIdsFour = new  Map<string,id>();
            if(!IdVsNumber.isEmpty()){
                for(Account a :[select Id,Name,PAN_Number_of_Entity__c,RecordType.Name from account where id=:IdVsNumber.values() ]){
                    if(a.RecordType.Name=='Shipping'){
                      filerAccIdsTwo.put(a.PAN_Number_of_Entity__c,a.id);
                      pannumberVSac.put(a.id,a.PAN_Number_of_Entity__c);
                    }
                    if(a.RecordType.Name=='Billing'){
                     filerAccIdsThree.put(a.PAN_Number_of_Entity__c,a.id);   
                    }
                   
                }     
            }

            /*******************************************************************************/
        

        /******* if shipping account  then finding the billing and if billing finding shipping account,addding to set and map*************/

            system.debug('222 '+filerAccIdsTwo);
            if(!pannumberVSac.isEmpty()){
                for(Account a :[select Id,Name,PAN_Number_of_Entity__c,RecordType.Name from account where PAN_Number_of_Entity__c=:pannumberVSac.Values() ]){
                  if(a.RecordType.Name=='Billing')  
                  filerAccIdsThree.put(a.PAN_Number_of_Entity__c,a.id);
                   if(a.RecordType.Name=='Shipping') 
                   filerAccIdsTwo.put(a.PAN_Number_of_Entity__c,a.id);    
                }     
            }
          /*******************************************************************************/
            system.debug('three '+filerAccIds);
            
            if(filterlist.size() > 0 && stoprecru==false)
                for(rsplus__Bot_Form__c b :filterlist){
                    rsplus__Bot_Form__c btf = new rsplus__Bot_Form__c();
                    if(string.isNotBlank(b.rsplus__Related_To__c) && (!filerAccIds.isEmpty())){
                        system.debug('three '+filerAccIds.contains(b.rsplus__Related_To__c));
                        if(filerAccIds.contains(b.rsplus__Related_To__c)){
                            btf.id=b.id;
                            btf.Shipping_Customer_ID__c=b.rsplus__Related_To__c;
                            messagebktmap.put(b.id,b.rsplus__Related_To__c);
                        }else{
                            btf.id=b.id;
                            btf.rsplus__Related_To__c=null;  
                        }    
                    }
                    
                    if(string.isNotBlank(b.rsplus__To__c)  && (!filerAccIdsTwo.isEmpty())){
                        system.debug('222www '+IdVsNumber.get(b.rsplus__To__c));
                        if(filerAccIdsTwo.containskey(IdVsNumber.get(b.rsplus__To__c))){ 
                            btf.id=b.id;
                            btf.rsplus__Related_To__c =IdVsNumber.get(b.rsplus__To__c);
                            btf.Shipping_Customer_ID__c=IdVsNumber.get(b.rsplus__To__c);
                            system.debug('222 '+btf.rsplus__Related_To__c);
                            messagebktmap.put(b.id,btf.rsplus__Related_To__c);
                        }else if(filerAccIdsTwo.containsKey(pannumberVSac.get(IdVsNumber.get(b.rsplus__To__c)))){
                            btf.id=b.id;
                            btf.rsplus__Related_To__c =filerAccIdsTwo.get(pannumberVSac.get(IdVsNumber.get(b.rsplus__To__c)));
                            btf.Shipping_Customer_ID__c=filerAccIdsTwo.get(pannumberVSac.get(IdVsNumber.get(b.rsplus__To__c)));
                        }else{
                            btf.id=b.id;
                            btf.rsplus__Related_To__c=null;   
                        }
                    }
                    
                    
                    if(!filerAccIdsThree.isEmpty() && !pannumberVSac.isEmpty()){
                        if(filerAccIdsThree.containsKey(pannumberVSac.get(b.rsplus__Related_To__c))){
                            btf.Billing_Customer_ID__c=filerAccIdsThree.get(pannumberVSac.get(b.rsplus__Related_To__c)); 
                        }else{
                            if(filerAccIdsThree.containsKey(pannumberVSac.get(IdVsNumber.get(b.rsplus__To__c)))){
                                btf.Billing_Customer_ID__c=filerAccIdsThree.get(pannumberVSac.get(IdVsNumber.get(b.rsplus__To__c)));     
                            }  
                        }
                    } 
                    
                    
                    
                    system.debug('bbbbbb  '+ btf.Billing_Customer_ID__c);
                    if(btf.id!=null)
                        updatelistbf.add(btf);
                    
                }
            
           
            system.debug('eeeeeeeeeeeeee '+updatelistbf);
            if(updatelistbf.size() > 0 ){
                database.upsert(updatelistbf, false); 
                stoprecru=true;
            }
        }
    }
    
    
    
    
    
    // creating New address for account.
    public static void NewaddressSetup(list<rsplus__Bot_Form__c> bflistupdate){
        
        /***************after bot completed creating pickups **************************/
        
        
        list<rsplus__Bot_Form__c> botAftrChecks = new list<rsplus__Bot_Form__c>();
        list<rsplus__Bot_Form__c> botChecksPickupOnly = new list<rsplus__Bot_Form__c>();
        Map<string,id> pincodeMap = new  Map<string,id>();
        set<string> Activepincodeids = new  set<string>();
        
        
        
        for(rsplus__Bot_Form__c b :bflistupdate){
            if( b.Shipping_Customer_ID__c!=null &&  b.Billing_Customer_ID__c!=null && string.isNotBlank(b.rsplus__To__c) && b.rsplus__Status__c=='Completed' && b.rsplus__Answer_2__c=='New Address' && string.isnotblank(b.rsplus__Answer_3__c) && string.isnotblank(b.rsplus__Answer_4__c) && string.isnotblank(b.rsplus__Answer_1000_Char__c) && string.isnotblank(b.Answer_5__c)) {
                Activepincodeids.add(b.rsplus__Answer_4__c); 
                botAftrChecks.add(b);
            }
            if( b.Shipping_Customer_ID__c!=null &&  b.Billing_Customer_ID__c!=null && string.isNotBlank(b.rsplus__To__c) && b.rsplus__Status__c=='Completed' && b.rsplus__Answer_2__c!=null && string.isnotblank(b.Answer_5__c) &&  b.rsplus__Answer_2__c!='New Address') {
                botChecksPickupOnly.add(b);
            }
        }
        
        if(!Activepincodeids.isempty()){
            for(Active_Pincode__c pc : [Select Id,Name From Active_Pincode__c where Name=:Activepincodeids]){
                pincodeMap.put(pc.Name,pc.id);
            }
        }
        
        
        /***************inserting address and pickup **************************/
        
        List<AddressBook__c>  addlist = new List<AddressBook__c>(); 
        if(botAftrChecks.size() > 0 ){
            Id shippingRecType = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
            for(rsplus__Bot_Form__c b :botAftrChecks){
                AddressBook__c  a = new AddressBook__c();
                a.Name=b.rsplus__Answer_3__c;
                if(b.Shipping_Customer_ID__c!=null)
                    a.Customer__c=b.Shipping_Customer_ID__c;
                if(pincodeMap.containsKey(b.rsplus__Answer_4__c)){
                    a.Active_Pincode__c=pincodeMap.get(b.rsplus__Answer_4__c);
                }else{
                    // BVC need handle the pincode if not found active pincode based on bot answer pincode         
                }
                if(shippingRecType!=null)
                    a.RecordTypeId=shippingRecType;
                a.ADDRESS1__c=b.rsplus__Answer_1000_Char__c.left(40);
                a.Your_Address_Identifier__c='BOT BVC '+String.valueOf(system.now());
                addlist.add(a);
            }
        } 
        set<id> insrtAdsIds = new set<id>();
        if(addlist.size() > 0){
            List<Database.SaveResult> srList = Database.insert(addlist, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    insrtAdsIds.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() +err.getFields());
                    }
                }
            }
        }
        map<id,id> bookmap = new map<id,id>();
        if(!insrtAdsIds.isempty())        
            for(AddressBook__c a :[Select Id,Name,Customer__c from AddressBook__c where id=:insrtAdsIds]){
                bookmap.put(a.Customer__c,a.id); 
            }
        
        
        
        
        
        List<Pickup__c> pickUps = new List<Pickup__c>(); 
        if(!bookmap.isEmpty() && botAftrChecks.size() > 0)        
            for(rsplus__Bot_Form__c b :botAftrChecks){
                if(b.Shipping_Customer_ID__c!=null && b.Billing_Customer_ID__c!=null && bookmap.containsKey(b.Shipping_Customer_ID__c) && string.isnotblank(b.Answer_5__c)){
                    Pickup__c p = new Pickup__c();
                    p.Customer__c= b.Billing_Customer_ID__c;
                    p.Shipper_Name__c=b.Shipping_Customer_ID__c;
                    integer timepick = integer.valueof(b.Answer_5__c)+15;
                    datetime pckup = datetime.newInstance(system.now().Year() , system.now().month(), system.now().day(), timepick, 0, 0);
                    p.Pickup_Date_and_Time__c=pckup;
                    p.Shipper_Address__c=bookmap.get(b.Shipping_Customer_ID__c);
                    p.Bot_Phone_Number__c=b.rsplus__To__c;
                    pickUps.add(p);
                }
            }
        if(pickUps.size() > 0){
            List<Database.SaveResult> srList = Database.insert(pickUps, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    system.debug('id inserted for pickups '+sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        
        /*********************************************************************************************************************/
        
        
        
        /****************inserting only pickup when customer use exsting record address*************************************/
        List<Pickup__c> pickUpsOnly = new List<Pickup__c>();
        if(botChecksPickupOnly.size() > 0)        
            for(rsplus__Bot_Form__c b :botChecksPickupOnly){
                if(b.Shipping_Customer_ID__c!=null && b.Billing_Customer_ID__c!=null && string.isnotblank(b.Answer_5__c) && b.rsplus__Answer_2__c instanceOf Id){
                    Pickup__c pt = new Pickup__c();
                    pt.Customer__c= b.Billing_Customer_ID__c;
                    pt.Shipper_Name__c=b.Shipping_Customer_ID__c;
                    integer timepick = integer.valueof(b.Answer_5__c)+15;
                    datetime pckup = datetime.newInstance(system.now().Year() , system.now().month(), system.now().day(), timepick, 0, 0);
                    pt.Pickup_Date_and_Time__c=pckup;
                    pt.Shipper_Address__c=b.rsplus__Answer_2__c;
                    pt.Bot_Phone_Number__c=b.rsplus__To__c;
                    pickUpsOnly.add(pt);
                }
            }
        if(pickUpsOnly.size() > 0){
            List<Database.SaveResult> srList = Database.insert(pickUpsOnly, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    system.debug('id inserted for pickups '+sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        /**************************************************************************************************************************/
        
    }
    
}