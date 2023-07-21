trigger ACRconsumptionTrigger on ST_ACR_Consumption__c (before delete) {
		Id profileId= UserInfo.getProfileId();
        string profileName=[SELECT Id, name from Profile WHERE Id=:profileId].name;
    		for(ST_ACR_Consumption__c ACRC: trigger.old){
                if(ACRC.X18_Digit_ID__c!=null && profileName!='System Administrator'){
                    ACRC.adderror('You cannot delete the record');
                }
    	}
}