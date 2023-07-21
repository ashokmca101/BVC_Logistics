trigger BVC_BotMsgStartTigger on rsplus__SMS_Bucket__c (before insert) {
  if(trigger.isbefore && trigger.isinsert)
  BVC_BotmsgTriggerHandler.relatedsetup(trigger.new); 
}