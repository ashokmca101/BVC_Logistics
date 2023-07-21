public class ExceptionMessages 
{
	public class gcException extends Exception{}
    public static void callException1()
    {
        throw new gcException('Complete the Pickup Then Proceeds');
    }
}