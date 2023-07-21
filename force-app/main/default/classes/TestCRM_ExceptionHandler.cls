@isTest
public class TestCRM_ExceptionHandler {
    @isTest
    static void testProcessException(){
        String componentName= 'XYZ'; 
        String methodName = 'ABC';
        try
        {
            Account accObj = new Account();
            accObj.Name = '';
            insert accObj;
        }
        catch (Exception dmx)
        {
            CRM_ExceptionHandler.processException(componentName, methodName, dmx);
        }
        
    }
	@isTest
    static void testProcessAPIFailures(){ 
        HttpResponse response = new HttpResponse();
        response.setStatus('Fail');
        response.setStatusCode(400);
        CRM_ExceptionHandler.processAPIFailures(response);
    }
    @isTest
    static void testProcessKARZAAFailures(){ 
        String request_id = '123';
        String status_code = '123';
        CRM_ExceptionHandler.processKARZAAFailures(request_id, status_code);
    }
}