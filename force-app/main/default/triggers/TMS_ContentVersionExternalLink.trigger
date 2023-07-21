trigger TMS_ContentVersionExternalLink on ContentVersion (after insert) {
    TMS_ContentTriggerHandler.createPublicLinkForFile(trigger.new);
    TMS_ContentTriggerHandler.createContentDocumentLink(trigger.new);
}