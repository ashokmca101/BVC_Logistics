public class NewPickUp1 {
    public List<String> customerAccounts {get;set;} // customerAccounts
    public List<String> ShipperAccounts {get;set;}
    public List<String> ShipperAddresses {get;set;}
    public DateTime s_date    {get;set;}
    public String selectedCustomer{get;set;}
    public String selectedShipAc{get;set;}
    public String selectedShipAdd{get;set;}    
    
    public String textDisplay{get;set;}
    public String CustomerId {get;set;}
    public String Remarks {get;set;}
    private final Pickup__c pkp;
    
    public NewPickUp1(ApexPages.StandardController stdController)
    {
        this.pkp = (Pickup__c)stdController.getRecord();
        customerAccounts = new List<String>();
        ShipperAccounts = new List<String>();
        string key = '%'+selectedCustomer+'%';
        System.debug('123 Search Key :'+selectedCustomer);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        List<Account> ac = [select Id,Name from Account where RecordTypeId=: devRecordTypeId and RecordType.Name=:'Billing' AND  Customer_Status__c='Active' order by CreatedDate desc limit 1000]; 
        System.debug('Ac :'+ac);
        for(Account a:ac)
        {
            customerAccounts.add(a.Name);
        }
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        List<Account> sac = [select Id,Name from Account where RecordTypeId=: devRecordTypeId1 AND Customer_Status__c='Active' order by CreatedDate desc limit 1000 ];
        for(Account ak:sac){
            ShipperAccounts.add(ak.Name);
            System.debug('Ak :'+ak.Name);
        }         
        
    }
    
    public void checkCustomer(){
        if(selectedCustomer.length()>=4){
            string key = '%'+selectedCustomer+'%';
            System.debug('Search Key :'+selectedCustomer);
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
            List<Account> ac = [select Id,Name from Account where RecordTypeId=: devRecordTypeId AND  Customer_Status__c='Active' and Name like : key limit 1000]; 
            System.debug('Ac :'+ac);
            if(ac.size()>0)
            {
                customerAccounts.clear();
                for(Account a:ac)
                {
                    customerAccounts.add(a.Name);
                    System.debug('rotated Account Names'+a.Name);
                }                    
            }
            System.debug('44.After Selection :'+customerAccounts[0]);
            if(selectedCustomer.length()>=20)
            {
                if(selectedCustomer=='TITAN COMPANY LIMITED - Billing AAACT5131A'){
                    Account ac1 = [select ST_Pricing_Type__c from Account where Name='Titan Company Limited Billing AAACT5131A' limit 1];
                    if(ac1.ST_Pricing_Type__c!=null || ac1.ST_Pricing_Type__c!='')
                    {
                        textDisplay = ac1.ST_Pricing_Type__c;    
                    }                        
                }            
                else
                {
                    Account ac1 = [select ST_Pricing_Type__c from Account where Name=: selectedCustomer limit 1];
                    if(ac1.ST_Pricing_Type__c!=null || ac1.ST_Pricing_Type__c!='')
                    {
                        textDisplay = ac1.ST_Pricing_Type__c;    
                    }                    
                }
                
            }
        }
    }
    
    public void checkShipAc() {        
        ShipperAddresses = new List<String>();
        ShipperAccounts = new List<String>();
        System.debug('V :'+selectedShipAc);
        this.selectedShipAdd='';        
        if(!String.isBlank(selectedShipAc) && selectedShipAc.length()>=4){            
            ShipperAccounts.clear();
            System.debug('44.After CLEAR :'+ShipperAccounts);            
            //String Key ='%'+ selectedShipAc+'%'; 
            String Key =selectedShipAc; 
            System.debug('11.Key :'+Key);
            Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
            //List<Account> sac = [select Id,Name from Account where RecordTypeId=: devRecordTypeId1 AND  Customer_Status__c='Active' and Name Like: Key limit 1000 ];
            //System.debug('11.Sac :'+sac);
           
             
for(Account a: [select Id,Name from Account where RecordTypeId=: devRecordTypeId1 AND  Customer_Status__c='Active' and Name Like: Key order by Name])
{
	 ShipperAccounts.add(a.Name);
    System.debug('Ak112 :'+a.Name);
}
             /*
             
            if(sac.size()>0)
            {                
                for(Account ak:sac){
                    ShipperAccounts.add(ak.Name);
                    System.debug('Ak :'+ak.Name);
                }                             
            } 
			*/
            System.debug('44.After Selection :'+ShipperAccounts);            
            if(selectedShipAc.length()>=20){
                ShipperAddresses.clear();
                System.debug('this.selectedShipAc :'+this.selectedShipAc);
                if(this.selectedShipAc =='TITAN COMPANY LIMITED Shipping AAACT5131A'){this.selectedShipAc='TITAN COMPANY LIMITED - Shipping AAACT5131A';}
                Account ac = [select Id from Account where Name =:this.selectedShipAc limit 1];
                System.debug('33<==> AC:'+ac);
                if(ac.Id != null || ac.Id != '')
                {
                    List<AddressBook__c> adList = [select Id,Name from AddressBook__c where Customer__c =: ac.Id];
                    for(AddressBook__c ab: adList){
                        ShipperAddresses.add(ab.Name);
                        System.debug('AB :'+ab.Name);
                    }                      
                }               
            }            
        }
    }
    
    public PageReference  save()
    {
        AddressBook__c abook = new AddressBook__c();
        Account Shipac = new Account();
        Account Custac = new Account();
        Pickup__c pu = new Pickup__c();
        
        if(selectedCustomer=='' || selectedCustomer.length()<=10)
        {    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Select Customer Account'));
            return null;
        }        
        
        if(selectedShipAc=='' || selectedShipAc.length()<=10)
        {    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Select Shipper Account'));
            return null;
        }
        if(selectedShipAdd=='' || selectedShipAdd.length()<=10)
        {    
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Select Shipping Address'));
            return null;
        }        
        if(selectedShipAc.length()>=20){
            System.debug('selectedShipAc :'+selectedShipAc);
            if(selectedShipAc=='TITAN COMPANY LIMITED Shipping AAACT5131A'){
                Shipac = [select Id from Account where Name = 'TITAN COMPANY LIMITED - Shipping AAACT5131A' limit 1];
            }
            else
            {
                Shipac = [select Id from Account where Name =:this.selectedShipAc limit 1];
            }
            
        }
        if(selectedCustomer.length()>=20){
            System.debug('selectedCustomer :'+selectedCustomer);
            if(selectedCustomer=='TITAN COMPANY LIMITED - Billing AAACT5131A'){
                Custac = [select Id from Account where Name ='Titan Company Limited Billing AAACT5131A' limit 1];                
            }
            else
            {
                Custac = [select Id from Account where Name =:this.selectedCustomer limit 1];
            }
            
        }   
        
        if(selectedShipAdd.length()>=20){
            System.debug('selectedShipAdd :'+selectedShipAdd);
            String sub = selectedShipAdd.substring(0,11);
            sub = '%'+sub+'%';
            // abook = [select Id,Name from AddressBook__c where Name =: selectedShipAdd limit 1];
            abook = [select Id,Name from AddressBook__c where Name like : sub limit 1];
        }  
        
        if(abook.id!=null && Custac.id!=null && Shipac.id!=null)        
        {            
            pu.Customer__c = Custac.Id;
            pu.Shipper_Name__c = Shipac.Id;
            pu.Shipper_Address__c = abook.Id;
            if(s_date==null){
                Date tod = system.today();
                Integer d = tod.day();
                Integer mo = tod.month();
                Integer yr = tod.year();                
                pu.Pickup_Date_and_Time__c= DateTime.newInstance(yr, mo, d);
            }
            else
            {
                Integer d = s_date.day();
                Integer mo = s_date.month();
                Integer yr = s_date.year();                
                pu.Pickup_Date_and_Time__c= DateTime.newInstance(yr, mo, d);                                
            }
            pu.Pickup_Date__c = system.today();
            pu.Remarks__c = this.Remarks;
            insert pu;
            PageReference retURL = new PageReference('/lightning/r/Pickup__c/'+pu.Id+'/view');
            retURL.setRedirect(true);
            return retURL;            
        }
        return null;
    }
    public PageReference  Cancel()
    {
        PageReference retURL = new PageReference('/lightning/o/Pickup__c/list?filterName=Recent');
        return retURL;
    }
    public PageReference  savenNew()
    {
        save();
        PageReference retURL = new PageReference('/apex/NewPickupVF?core.apexpages.request.devconsole=1');
        this.selectedCustomer='';
        this.textDisplay='';
        this.selectedShipAc='';
        this.selectedShipAdd='';
        this.Remarks = '';
        return retURL;
    }
    
}