trigger OrderItemTrigger on OrderItem (After Insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            system.debug('OrderItem::After Insert::'+trigger.new);
            OrderItemTriggerHandler.orderItemFieldUpdate(trigger.new);
            utilClass.flowSequence++;
            system.debug('flowSequence : Order Item After Insert Trigger'+utilClass.flowSequence);
        }
        
    }
}