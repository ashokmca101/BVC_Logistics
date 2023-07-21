public class EmailNotificationBatch implements Database.Batchable<sObject>{
    //system.debug('batch execution');
    //added AccountId,Contact.Email in line 8 
    String query = 'SELECT AccountNumber,Name,Balance_Amount__c,Point_Of_Contact_Email__c,'
        +'Annual_Contract_Balance__c,Active_Contract__c,Consumed_ACR_Amount__c,of_Contract_Consumption__c,'
        +'Active_Contract__r.of_Contract_Consumption__c,Active_Contract__r.Consumed_Amount__c,'
        +'Adjusted_Contract_Amount__c,Contract_Start_Date__c,Contract_Amount__c,'
        +'Consumed_Amount__c,Contract_End_Date__c,ST_Total_Consumable_ACR_Amount__c,'
        +'(SELECT ContactId,Roles,AccountId,Contact.Email FROM AccountContactRelations WHERE Roles = \'Finance\'),'
        +'Email_Sent_at_85_Consumption__c,Email_Sent_at_90_Consumption__c,Email_Sent_at_95_Consumption__c,'
        +'Email_Sent_at_98_Consumption__c,Email_Sent_at_100_Consumption__c'
        +' FROM Account '
        +' WHERE (ST_Pricing_Type__c = \'ACR\''
        +' AND Contracted_ACR_Package__c != null) ';
    public Database.QueryLocator start (Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope){
        system.debug('List Of Accounts'+scope);
        Boolean expiryByDate = true;
        List<Account> sentemailAccounts = new List<Account>();
        List<String> daysToExpiryString = Label.Contract_Expiry_Email_Days_to_send.split(',');
        List<Integer> daysToExpiry = new List<Integer>();
        for(String s : daysToExpiryString){
            system.debug('Days>>>'+Integer.valueOf(s));
            daysToExpiry.add(Integer.valueOf(s));
        }
        for(Account acc : scope){
            system.debug('system.today().daysBetween(acc.Contract_End_Date__c)'+system.today().daysBetween(acc.Contract_End_Date__c));
            system.debug('End Date'+acc.Contract_End_Date__c);
              if(daysToExpiry.contains(system.today().daysBetween(acc.Contract_End_Date__c))
                   && expiryByDate){
                       
                       sentemailAccounts.add(acc);
                       
                   }
        }
       
        List<Messaging.SingleEmailMessage> mailingList = SendEmailUtility.ContractExpiryEmailSender(Label.Contract_Days_to_Expiry_HTML_Template ,sentemailAccounts,expiryByDate);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mailingList);

    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}