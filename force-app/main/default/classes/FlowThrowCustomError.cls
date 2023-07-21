public class FlowThrowCustomError 
{
    public class ThrowCustomException extends Exception{}
    @InvocableMethod
    public static void throwCustomFlowException(FlowInputs[] flowInput)
    {
        throw createCustomException(flowInput[0].errorMessage);
    }
    public class FlowInputs
    {
        @InvocableVariable 
        public string errorMessage;
    }
    static ThrowCustomException createCustomException(String message)
    {
        ThrowCustomException ex = new ThrowCustomException(message);
        ex.setMessage(message);
        return ex;
    }
}