/**
* @description       : 
* @author            : Imran
* @group             : 
* @last modified on  : 05-11-2023
* @last modified by  : Imran
**/
public class TMS_Lookup2 {
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, Integer lim,String fld_API_Search,String searchText,String RecordType, string originPort, string DestPort,String SecPackType,String CusId,String fld_API_Text1){
        Id RecTypeId;
        System.debug('11.CusId :'+CusId);
        System.debug('11.objectName :'+objectName);
        System.debug('11.fld_API_Text :'+fld_API_Text);
        System.debug('11.searchText :'+searchText);
        List<sObject> sobjList; 
            /*
        if(objectName=='Transport__c' && string.isNotBlank(RecordType)){
            RecTypeId = Schema.SObjectType.Transport__c.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        }else */ if(objectName=='Account' && string.isNotBlank(RecordType)){
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        }
        // get Recprd type
        if(objectName=='Account' && RecordType =='Billing')
        {
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        }      
        if(objectName=='Account' && RecordType =='Shipping')
        {
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        }      

                
//        List<sObject> sobjList;                        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val;

        if(objectName=='Account' && RecordType =='Billing')
        {
           query += ' ,'+fld_API_Text1; 
        }         
                
          /*      
        if(objectName=='Flight_Schedule__c'){   
            query += ' ,Origin_Airport__c'; 
        } */
        query += ' FROM '+objectName ;               
        Id Packagingtype;
          /*      
        if(objectName=='Secure_Packaging__c' && string.isNotBlank(SecPackType)){
            Packagingtype = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get(SecPackType).getRecordTypeId();
        } */
        query +=' WHERE ' +fld_API_Search+' LIKE '+searchText;
        
        string whereClause = '';
                if(objectName=='AddressBook__c')
                {
                    whereClause += 'AND Customer__c =\''+CusId+'\' ';
                    //Customer__c =\''+CusId+'\' ';
                }      
                
        system.debug('lokkupresp@@ '+originPort +''+ Destport);
                /*
        if(objectName=='Secure_Packaging__c' &&string.isNotBlank(Packagingtype)){
            string status = 'Available';
            whereClause += 'AND RecordTypeId=:Packagingtype AND Status__c=:status ';
        }else */ if(objectName=='Account' && String.isNotBlank(RecTypeId)){
            whereClause += 'AND RecordTypeId =:RecTypeId ';
        } /*else if(objectName=='Transport__c' && String.isNotBlank(RecTypeId)){
            whereClause += 'AND RecordTypeId =:RecTypeId ';
            if(RecordType =='BVC Vehicle'){
                whereClause += ' AND Is_Inactive__c =false ';
            }
        }else if(objectName=='Flight_Schedule__c' && string.isNotBlank(originPort)){
            whereClause += 'AND origin__c =:originPort ';
            if(string.isNotBlank(DestPort))
                whereClause += ' AND destination__c =:DestPort';    
        }   
        
        else if(objectName=='Linehaul__c' && string.isNotBlank(originPort) && string.isNotBlank(Destport)){ 
            whereClause += 'origin__c =: originport and destination__c =: destport ';
        } */
        if(whereClause.left(3)=='AND')
            whereClause = whereClause.substringAfter('AND');
        query += ' AND '+whereClause;                          
        query=  query.removeEnd('AND ');
        query += ' LIMIT '+lim;
        System.debug('query ===> '+query);
        try{
            sobjList = Database.query(query);
        }
        catch(exception e){
            throw new AuraHandledException('Error: '+e.getMessage());
        }
                
                
            
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)); 
            obj.val = String.valueOf(s.get(fld_API_Val));
            if(objectName=='Account' && RecordType =='Billing'){
                 if(fld_API_Text1!=null){obj.text1 = String.valueOf(s.get(fld_API_Text1));}             
            }
            // if(fld_API_Text1!=null){obj.text1 = String.valueOf(s.get(fld_API_Text1));}            
            System.debug('Obj Val :'+obj.text);
            lstRet.add(obj);
        } 
        system.debug('lnokkupresp@@ '+JSON.serialize(lstRet));
        return JSON.serialize(lstRet) ;
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        public String text1{get;set;}
        
    }
}