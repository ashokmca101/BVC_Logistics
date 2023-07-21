/*
 * Created By: PwC
 * Specification:Lead Trigger
 * Date:11/02/2021
*/
trigger LeadTrigger on Lead (after insert,after update) {
    Set<Id> allInsertedIds = trigger.newMap.keySet();
    if(Trigger.isAfter)
    {
        If(Trigger.isInsert){
            BVC_LeadTriggerHandler handler = new BVC_LeadTriggerHandler();
            handler.ProducttoLPSync(Trigger.oldMap,Trigger.NewMap,true,false);
            //LeadRoundRobin.assignTicketRoundRobin(Trigger.NewMap.keySet());
            AutoConvertLeads.LeadAssign(allInsertedIds);
            
        }
        If(Trigger.isUpdate){
            BVC_LeadTriggerHandler handler = new BVC_LeadTriggerHandler();
            handler.ProducttoLPSync(Trigger.oldMap,Trigger.NewMap,false,true);
            if(!Utility.isRun){
                LeadRoundRobin.assignTicketRoundRobin(Trigger.NewMap.keySet());   
            }
            
            AutoConvertLeads.LeadAssign(allInsertedIds);
            handler.convertLeadToOpps(Trigger.New);
        }
       
    }

}