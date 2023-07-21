public with sharing class QuoteCloneWithLine {
    private Map<String, ChildRelationshipProps> relationMap;
    private SObjectType OrgObjtype;

    public SObject clone;
   
    public QuoteCloneWithLine(Id toCloneId, String relationshipsToClone) {
        OrgObjtype = toCloneId.getSObjectType();
        QuoteRelations(relationshipsToClone);
        QueryQuote(toCloneId);
    }

    public Id save(){
        Savepoint sp = Database.setSavepoint();

        try {
            system.debug('Cloned Quote:'+clone);
            insert clone;

            for(String relationshipName : this.relationMap.keySet()){
                SObject[] clonedChildren = new SObject[]{};
                ChildRelationshipProps rel = this.relationMap.get(relationshipName);
                for(Sobject child : clone.getSObjects(relationshipName)){
                    SObject childClone = child.clone(false);
                    childClone.put(rel.field, clone.Id);
                    clonedChildren.add(childClone);
                }
                insert clonedChildren;
            }

        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }

        return clone.Id;
    }

    private void QuoteRelations(String relationshipStrings){
        this.relationMap = new Map<string, ChildRelationshipProps>();
        Map<String, ChildRelationship> childRelationMap = new Map<String, ChildRelationship>();
        for(ChildRelationship rel : OrgObjtype.getDescribe().getChildRelationships()){
            String relName = rel.getRelationshipName();
            system.debug('relation Name::'+relName);       
            if(relName != null){ //not sure why this would happen but it does
                 if(relName.contains('SBQQ__'))
                 {
                     //if(relName == 'sbqq__Quoteline__c' || relName == 'SBQQ__QUOTELINE__C' || relName == 'sbqq__Quoteline__r' || relName == 'SBQQ__QUOTELINE__R' )
                      system.debug('SATYA123 '+relName  );
                 }
                if(relName == relationshipStrings){
                    system.debug('SATYA1 '+relName  );    
                  childRelationMap.put(rel.getRelationshipName().toUpperCase(), rel);  
                }
                
            }
        }
        
        system.debug('SATYA12 '+childRelationMap.keyset());
        String relStr = relationshipStrings.toUpperCase();
         system.debug('SATYA2 '+relStr );
        if(childRelationMap.containsKey(relStr)){            
            ChildRelationship rel = childRelationMap.get(relStr);
            relationMap.put(rel.getRelationshipName().toUpperCase(), new ChildRelationshipProps(rel));
        }else{
            throw new DeepCloneException(
                'Child Relationship \'' + relStr + '\' does not exsist on ' + OrgObjtype.getDescribe().getName()
            );
        }

    }

    private void QueryQuote(Id toCloneId){
        // Get a map of field name and field token
        String[] selectFields = getCreatableFields(OrgObjtype);
        //subqueries
        for(String relationName : this.relationMap.keySet()){
            ChildRelationshipProps rel = this.relationMap.get(relationName);
            String[] relationFields = getCreatableFields(rel.sObjectType);
            if(relationFields.size() > 0){
                selectFields.add('(' + buildQuery(relationFields, relationName, null) + ')');
            }
        }

        String qry = buildQuery(
            selectFields,
            OrgObjtype.getDescribe().getName(),
            'ID = \''+String.escapeSingleQuotes(toCloneId)+'\''
        );

        this.clone = ((SObject) Database.query(qry)).clone(false);
    }

    private string buildQuery(String[] fields, String fromObj, string whereClause){
        String qry = 'SELECT ' + String.join(fields, ',') + ' FROM ' + fromObj;
        if(!String.isEmpty(whereClause)){
            qry += ' WHERE ' + whereClause;
        }
        system.debug('Query:'+qry);
        return qry;
    }

    private String[] getCreatableFields(SObjectType objType){
        DescribeSObjectResult describe = objType.getDescribe();

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldMap = describe.Fields.getMap();
        String[] selectFields = new String[]{};

        if (fieldMap != null){
            for (Schema.SObjectField ft : fieldMap.values()){  
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                if (fd.isCreateable()){ 
                    selectFields.add(fd.getName());
                }
            }
        }
        return selectFields;
    }

    private class ChildRelationshipProps{
        public SObjectType sObjectType;
        public SObjectField field;
        public ChildRelationshipProps(ChildRelationship rel){
            this.sObjectType = rel.getChildSObject();
            this.field = rel.getField();
        }
    }

    public class DeepCloneException extends Exception {}
}