/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TMS_Lookup {
    /**
* Returns JSON of list of ResultWrapper to AURA Component
* @objectName - Name of SObject - e.g. Account
* @fld_API_Text - API name of field to display to user while searching - e.g. ID
* @fld_API_Val - API name of field to be returned by Lookup COmponent - e.g. Name
* @lim   - Total number of record to be returned - LIMIT - 8
* @fld_API_Search - API name of field to be searched - e.g. Name
* @searchText - text to be searched - e.g. Burlingston
* @String AccID - Account id to search Contacts - 001XXXXXXXXXXXX
* @Decimal lat - Latitude of the previous account selected - 
* @Decimal lon - Longitude of the previous account selected - 
* */
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, Integer lim,String fld_API_Search,String searchText,String RecordType, string originPort, string DestPort,String SecPackType){
        Id RecTypeId;
        if(objectName=='Transport__c' && string.isNotBlank(RecordType)){
            RecTypeId = Schema.SObjectType.Transport__c.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        }else if(objectName=='Account' && string.isNotBlank(RecordType)){
            RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordType).getRecordTypeId();
        }
        
        List<sObject> sobjList;                        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val;
        if(objectName=='Flight_Schedule__c'){	
             query += ' ,Origin_Airport__c';	
         }
        query += ' FROM '+objectName ;
        Id Packagingtype;
        if(objectName=='Secure_Packaging__c' && string.isNotBlank(SecPackType)){
            Packagingtype = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get(SecPackType).getRecordTypeId();
        }
        query +=' WHERE ' +fld_API_Search+' LIKE '+searchText;
        string whereClause = '';
                      system.debug('lokkupresp@@ '+originPort +''+ Destport);
        if(objectName=='Secure_Packaging__c' &&string.isNotBlank(Packagingtype)){
            string status = 'Available';
            whereClause += 'AND RecordTypeId=:Packagingtype AND Status__c=:status ';
        }else if(objectName=='Account' && String.isNotBlank(RecTypeId)){
            whereClause += 'AND RecordTypeId =:RecTypeId ';
        }else if(objectName=='Transport__c' && String.isNotBlank(RecTypeId)){
            whereClause += 'AND RecordTypeId =:RecTypeId ';
            if(RecordType =='BVC Vehicle'){
                whereClause += ' AND Is_Inactive__c =false ';
            }
        }else if(objectName=='Flight_Schedule__c' && string.isNotBlank(originPort)){
            whereClause += 'AND origin__c =:originPort ';
            if(string.isNotBlank(DestPort))
                   whereClause += ' AND destination__c =:DestPort';	
        }	
        //available AWB	
        else if(objectName=='Linehaul__c' && string.isNotBlank(originPort) && string.isNotBlank(Destport)){	
            whereClause += 'origin__c =: originport and destination__c =: destport ';
        }
        if(whereClause.left(3)=='AND')
            whereClause = whereClause.substringAfter('AND');
        query += ' AND '+whereClause;
        query=  query.removeEnd('AND ');
        query += ' LIMIT '+lim;
        // System.debug('query ===> '+query);
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
            if(objectName=='Flight_Schedule__c'){	
			obj.text = obj.text+', '+String.valueOf(s.get('Origin_Airport__c'));	
            }
            obj.val = String.valueOf(s.get(fld_API_Val));
            lstRet.add(obj);
        } 
        system.debug('lnokkupresp@@ '+JSON.serialize(lstRet));
        return JSON.serialize(lstRet) ;
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        
    }
}