/**                                                                             
 * @description       : 
 * @author            : Imran
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Imran
**/
public without sharing class TMS_LinehaulClass2 {
    @AuraEnabled
    public Map<String, String> options;
    @AuraEnabled
    public Map<String, String> BranchOptions;
    
    @AuraEnabled
    public static List<String> SavePickup(String CAId,String SAId,String SAddId,String Remarks,DateTime P_date,boolean stg)
    {
        List<string> res = new List<string>();
        String status='FAIL';
        integer Temp=0;
        System.debug('Inside Save Pickup');
        Pickup__c pu = new Pickup__c();
        // List<Pickup__c> skList = [select In,Name from Pickup__c where Pickup__c=:CAId]
        Date tod1 = system.today();
        Integer d1 = tod1.day();
        Integer mo1 = tod1.month();
        Integer yr1 = tod1.year();  
        DateTime dt = DateTime.newInstance(yr1, mo1, d1);
        List<Pickup__c> pkl = [select Id,Name from Pickup__c where Customer__c =:CAId AND Shipper_Name__c =: SAId AND Shipper_Address__c =: SAddId AND CreatedDate >=: dt];
        System.debug(' Size :'+pkl.size());
        
        if(pkl.size()>0 && stg== false)
        {
           // status=pkl[0].Name;
            Temp=1;
            System.debug(' Size :'+pkl[0].Name);
            res.add(status);
            res.add(pkl[0].Name);
        }
        
        if(CAId != null && SAId != null && SAddId != null && Temp==0)        
        {            
            pu.Customer__c = CAId;
            pu.Shipper_Name__c = SAId;
            pu.Shipper_Address__c = SAddId;
            // 
            if(P_date==null){
                /*
                Date tod = system.today();
                Integer d = tod.day();
                Integer mo = tod.month();
                Integer yr = tod.year();                
                pu.Pickup_Date_and_Time__c= DateTime.newInstance(yr, mo, d);
                System.debug('11. pu.Pickup_Date_and_Time__c :'+pu.Pickup_Date_and_Time__c);
				*/
            }
            else
            {
                /*
                Integer d = P_date.day();
                Integer mo = P_date.month();
                Integer yr = P_date.year();      
                System.debug('22.P_date :'+P_date);
                pu.Pickup_Date_and_Time__c= DateTime.newInstance(yr, mo, d);  
                */
                pu.Pickup_Date_and_Time__c= P_date;  
                System.debug('22.pu.Pickup_Date_and_Time__c :'+pu.Pickup_Date_and_Time__c);
            }
            //pu.Pickup_Date__c = system.today();
            pu.Remarks__c = Remarks;
            pu.RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId();
            insert pu;
            System.debug('PU : '+pu);
            System.debug('PU Name : '+pu.Id);
            Pickup__c pkk = [select Id,Name from Pickup__c where Id=:pu.Id limit 1];
            System.debug('PU Name : '+pkk.Name);
            status='SUCCESS'; 
            res.add(status);
            res.add(pkk.Name);
        }
        //return status;
        return res;
    }
}