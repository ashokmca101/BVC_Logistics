public class CRM_ExceptionHandler {
    // Log Exception
    public static void logExceptions (List<ExceptionWrapper> exceprionWrappers) {
        List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();
        for(ExceptionWrapper exceprionWrapper : exceprionWrappers){
            exceptionLogs.add(exceprionWrapper.exceptionLog);
        }
        insert exceptionLogs;
    }

    
    public static void processException(String componentName, String methodName, Exception e){
        system.debug('Enter in Process Exception');
        List<ExceptionWrapper> lstwrapper = new List<ExceptionWrapper>();
        Integer count = 1;
        if(e.getTypeName() == 'System.DmlException')
            count = e.getNumDml();
        
        for (Integer i = 0; i < count; i++) { 
        	// Process exception here System.debug(e.getDmlMessage(i)); 
         	ExceptionWrapper objwrapper = new ExceptionWrapper(componentName, methodName, e);
            lstwrapper.add(objwrapper);
        }
        for(ExceptionWrapper exp: lstwrapper){
            System.debug('componentName>>>>' + exp);
        }
        logExceptions(lstwrapper);
      }
    public static void processAPIFailures(HttpResponse response){
        Exception_Log__c apiException = new Exception_Log__c();
        apiException.API_Status_Code__c = String.valueOf(response.getStatusCode());
        apiException.API_Status__c = response.getStatus();
        insert apiException;
      }
     public static void processKARZAAFailures(String request_id , String status_code){
         Exception_Log__c apiException = new Exception_Log__c();
         apiException.Request_Id__c = request_id;
         apiException.API_Status_Code__c = status_code;
         insert apiException;
      }
    
    
    public class ExceptionWrapper {
        Exception_Log__c exceptionLog;

        public ExceptionWrapper(String componentName, String methodName, Exception e){
            exceptionLog = new Exception_Log__c (
                    Apex_Method__c = methodName,
                    Exception_Message__c = e.getMessage(),
                    Line_Number__c =  e.getLineNumber(),
                    Stack_Trace__c = e.getStackTraceString(),
                    Running_User__c = UserInfo.getUserId()
            );
        }
    }

}